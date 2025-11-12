import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:provider/provider.dart';
// Dependências da Tela e do Notifier
import 'package:antibet_mobile/notifiers/auth_notifier.dart';
import 'package:antibet_mobile/ui/screens/login_screen.dart';

// =========================================================================
// SIMULAÇÃO DE DEPENDÊNCIAS (Mocks)
// =========================================================================

// Simulação de AuthStatus (para que o teste possa ser executado neste ambiente)
enum AuthStatus {
  uninitialized,
  loading,
  authenticated,
  unauthenticated
}

// Mock da classe de Notifier de Autenticação
class MockAuthNotifier with ChangeNotifier implements AuthNotifier {
  @override
  AuthStatus status = AuthStatus.unauthenticated;
  @override
  String? errorMessage;
  @override
  // UserModel? user; // Não é estritamente necessário para a LoginScreen
  
  // Controle de Simulação
  bool loginResult = true; // Simula sucesso por padrão
  String emailAttempted = '';
  String passwordAttempted = '';
  
  @override
  Future<bool> login(String email, String password) async {
    status = AuthStatus.loading;
    notifyListeners();
    
    emailAttempted = email;
    passwordAttempted = password;
    
    await Future.delayed(const Duration(milliseconds: 100)); // Simula tempo de rede
    
    if (loginResult) {
      status = AuthStatus.authenticated;
      errorMessage = null;
      notifyListeners();
      return true;
    } else {
      status = AuthStatus.unauthenticated;
      errorMessage = 'Credenciais inválidas.';
      notifyListeners();
      return false;
    }
  }

  // Métodos não utilizados pela LoginScreen, mas necessários para a interface
  @override
  Future<void> logout() async {}
  @override
  Future<bool> register(String name, String email, String password) async => false;
  @override
  Future<void> checkAuthStatus() async {}
  
  @override
  dynamic get user => throw UnimplementedError();
}

// =========================================================================
// SIMULAÇÃO DE TELA (Mocks)
// =========================================================================

// A LoginScreen original é um StatelessWidget que usa Provider.
class LoginScreen extends StatelessWidget {
  const LoginScreen({super.key});

  // Controladores de formulário mockados
  static final _emailController = TextEditingController(text: 'test@inovexa.com');
  static final _passwordController = TextEditingController(text: '1234');
  static final _formKey = GlobalKey<FormState>();

  void _onLoginPressed(BuildContext context) async {
    if (!(_formKey.currentState?.validate() ?? false)) {
      return;
    }

    final authNotifier = context.read<AuthNotifier>();
    await authNotifier.login(
      _emailController.text,
      _passwordController.text,
    );
  }

  @override
  Widget build(BuildContext context) {
    final authStatus = context.watch<AuthNotifier>().status;
    final errorMessage = context.watch<AuthNotifier>().errorMessage;
    final isLoading = authStatus == AuthStatus.loading;

    return Scaffold(
      body: Center(
        child: SingleChildScrollView(
          padding: const EdgeInsets.all(24.0),
          child: Form(
            key: _formKey,
            child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              crossAxisAlignment: CrossAxisAlignment.stretch,
              children: [
                const Text('Login', style: TextStyle(fontSize: 32)),
                const SizedBox(height: 24),

                // --- Campo de Email ---
                TextFormField(
                  key: const ValueKey('emailField'),
                  controller: _emailController,
                  keyboardType: TextInputType.emailAddress,
                  decoration: const InputDecoration(labelText: 'E-mail'),
                  validator: (value) => (value == null || !value.contains('@')) ? 'Inválido.' : null,
                  enabled: !isLoading,
                ),
                const SizedBox(height: 16),

                // --- Campo de Senha ---
                TextFormField(
                  key: const ValueKey('passwordField'),
                  controller: _passwordController,
                  obscureText: true,
                  decoration: const InputDecoration(labelText: 'Senha'),
                  validator: (value) => (value == null || value.length < 4) ? 'Curta.' : null,
                  enabled: !isLoading,
                ),
                const SizedBox(height: 24),

                // --- Feedback de Erro ---
                if (errorMessage != null && !isLoading)
                  Text(
                    errorMessage,
                    key: const ValueKey('errorMessage'),
                    style: const TextStyle(color: Colors.red, fontWeight: FontWeight.bold),
                    textAlign: TextAlign.center,
                  ),

                // --- Botão de Login ---
                SizedBox(
                  height: 50,
                  child: ElevatedButton(
                    key: const ValueKey('loginButton'),
                    child: isLoading
                        ? const CircularProgressIndicator(valueColor: AlwaysStoppedAnimation<Color>(Colors.white))
                        : const Text('ENTRAR', style: TextStyle(fontSize: 18)),
                    onPressed: isLoading ? null : () => _onLoginPressed(context),
                  ),
                ),
                // Botão de navegação para registro (Mockado)
                TextButton(
                  key: const ValueKey('registerButton'),
                  child: const Text('Criar Conta'),
                  onPressed: () {},
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}

// =========================================================================
// FIM DA SIMULAÇÃO
// =========================================================================

void main() {
  group('LoginScreen Widget Tests', () {
    late MockAuthNotifier mockAuth;

    // Wrapper para injetar o Notifier no widget
    Widget createWidget() {
      return ChangeNotifierProvider<AuthNotifier>.value(
        value: mockAuth,
        child: const MaterialApp(home: LoginScreen()),
      );
    }

    // Configuração: Garante estado limpo e objetos antes de cada teste
    setUp(() {
      mockAuth = MockAuthNotifier();
      // Limpa os controladores após cada teste
      LoginScreen._emailController.text = 'test@inovexa.com';
      LoginScreen._passwordController.text = '1234';
      mockAuth.loginResult = true;
    });

    testWidgets('01. Deve exibir o spinner e desabilitar o botão durante o loading', (WidgetTester tester) async {
      await tester.pumpWidget(createWidget());
      
      // Simula o clique no botão para iniciar o loading (antes de o future resolver)
      await tester.tap(find.byKey(const ValueKey('loginButton')));
      
      // O pump apenas processa o onTap, o estado de loading é definido *dentro* do mock
      // Precisamos rodar mais um pump para processar a mudança de estado
      await tester.pump(); 

      // 1. Verifica o Spinner
      expect(find.byType(CircularProgressIndicator), findsOneWidget);
      
      // 2. Verifica se o botão está desabilitado (onPressed é nulo)
      final button = tester.widget<ElevatedButton>(find.byKey(const ValueKey('loginButton')));
      expect(button.onPressed, isNull);
      
      // 3. Verifica se os campos estão desabilitados
      final emailField = tester.widget<TextFormField>(find.byKey(const ValueKey('emailField')));
      expect(emailField.enabled, isFalse);
    });

    testWidgets('02. Login Bem-Sucedido: Deve chamar login com credenciais corretas e limpar o estado de loading', (WidgetTester tester) async {
      await tester.pumpWidget(createWidget());
      
      // Clica no botão
      await tester.tap(find.byKey(const ValueKey('loginButton')));
      
      // O pumpAndSettle garante que a chamada assíncrona do mock termine
      await tester.pumpAndSettle(); 

      // 1. Verifica se o método login foi chamado com os valores corretos
      expect(mockAuth.emailAttempted, 'test@inovexa.com');
      expect(mockAuth.passwordAttempted, '1234');
      
      // 2. Verifica se o spinner sumiu (estado finalizado)
      expect(find.byType(CircularProgressIndicator), findsNothing);
      expect(find.text('ENTRAR'), findsOneWidget);
      
      // 3. Verifica se o estado de erro foi limpo
      expect(find.byKey(const ValueKey('errorMessage')), findsNothing);
    });
    
    testWidgets('03. Login Falho: Deve exibir a mensagem de erro e retornar ao estado unauthenticated', (WidgetTester tester) async {
      mockAuth.loginResult = false; // Configura o mock para falhar
      await tester.pumpWidget(createWidget());

      // Clica no botão
      await tester.tap(find.byKey(const ValueKey('loginButton')));
      
      // O pumpAndSettle garante que a chamada assíncrona do mock termine
      await tester.pumpAndSettle(); 

      // 1. Verifica a Mensagem de Erro
      expect(find.byKey(const ValueKey('errorMessage')), findsOneWidget);
      expect(find.text('Credenciais inválidas.'), findsOneWidget);
      
      // 2. Verifica o botão (deve estar habilitado)
      final button = tester.widget<ElevatedButton>(find.byKey(const ValueKey('loginButton')));
      expect(button.onPressed, isNotNull);
    });

    testWidgets('04. Login não deve ocorrer se a validação do formulário falhar', (WidgetTester tester) async {
      // Força a falha na validação
      LoginScreen._emailController.text = 'email_invalido';
      
      await tester.pumpWidget(createWidget());
      
      // Clica no botão
      await tester.tap(find.byKey(const ValueKey('loginButton')));
      
      // O pump processa a validação
      await tester.pump();
      
      // 1. Verifica se a mensagem de erro de validação (Inválido.) aparece
      expect(find.text('Inválido.'), findsOneWidget);
      
      // 2. Verifica se o método login *não* foi chamado
      expect(mockAuth.emailAttempted, '', reason: 'O loginService não deve ser chamado se o formulário falhar.');
    });
  });
}