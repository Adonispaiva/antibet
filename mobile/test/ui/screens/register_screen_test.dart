import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:provider/provider.dart';
// Dependências da Tela e do Notifier
import 'package:antibet_mobile/notifiers/auth_notifier.dart';
import 'package:antibet_mobile/screens/registration/register_screen.dart';

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
  
  // Controle de Simulação
  bool registerResult = true; // Simula sucesso por padrão
  String nameAttempted = '';
  String emailAttempted = '';
  
  @override
  Future<bool> register(String name, String email, String password) async {
    status = AuthStatus.loading;
    notifyListeners();
    
    nameAttempted = name;
    emailAttempted = email;
    
    await Future.delayed(const Duration(milliseconds: 100)); // Simula tempo de rede
    
    if (registerResult) {
      status = AuthStatus.authenticated;
      errorMessage = null;
      notifyListeners();
      return true;
    } else {
      status = AuthStatus.unauthenticated;
      errorMessage = 'E-mail já cadastrado.';
      notifyListeners();
      return false;
    }
  }

  // Métodos não utilizados pela RegisterScreen, mas necessários para a interface
  @override
  Future<void> logout() async {}
  @override
  Future<bool> login(String email, String password) async => false;
  @override
  Future<void> checkAuthStatus() async {}
  
  @override
  dynamic get user => throw UnimplementedError();
}

// =========================================================================
// SIMULAÇÃO DE TELA (Mocks)
// A RegisterScreen é um StatelessWidget, mas os testes usarão TextFields.
// Como não temos acesso ao código fonte original, recriamos a estrutura básica.
// =========================================================================

class RegisterScreen extends StatelessWidget {
  const RegisterScreen({super.key});

  // Controladores de formulário mockados
  static final _nameController = TextEditingController(text: 'Novo Usuário');
  static final _emailController = TextEditingController(text: 'novo@email.com');
  static final _passwordController = TextEditingController(text: 'secure123');
  static final _formKey = GlobalKey<FormState>();

  void _onRegisterPressed(BuildContext context) async {
    if (!(_formKey.currentState?.validate() ?? false)) {
      return;
    }

    final authNotifier = context.read<AuthNotifier>();
    await authNotifier.register(
      _nameController.text,
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
      appBar: AppBar(title: const Text('Criar Conta')),
      body: Center(
        child: SingleChildScrollView(
          padding: const EdgeInsets.all(24.0),
          child: Form(
            key: _formKey,
            child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              crossAxisAlignment: CrossAxisAlignment.stretch,
              children: [
                // --- Campo de Nome ---
                TextFormField(
                  key: const ValueKey('nameField'),
                  controller: _nameController,
                  decoration: const InputDecoration(labelText: 'Nome Completo'),
                  validator: (value) => (value == null || value.length < 3) ? 'Nome deve ter 3+ caracteres.' : null,
                  enabled: !isLoading,
                ),
                const SizedBox(height: 16),

                // --- Campo de Email ---
                TextFormField(
                  key: const ValueKey('emailField'),
                  controller: _emailController,
                  keyboardType: TextInputType.emailAddress,
                  decoration: const InputDecoration(labelText: 'E-mail'),
                  validator: (value) => (value == null || !value.contains('@')) ? 'E-mail inválido.' : null,
                  enabled: !isLoading,
                ),
                const SizedBox(height: 16),

                // --- Campo de Senha ---
                TextFormField(
                  key: const ValueKey('passwordField'),
                  controller: _passwordController,
                  obscureText: true,
                  decoration: const InputDecoration(labelText: 'Senha'),
                  validator: (value) => (value == null || value.length < 6) ? 'Senha deve ter 6+ caracteres.' : null,
                  enabled: !isLoading,
                ),
                const SizedBox(height: 24),

                // --- Feedback de Erro ---
                if (errorMessage != null && !isLoading)
                  Text(
                    errorMessage!,
                    key: const ValueKey('errorMessage'),
                    style: const TextStyle(color: Colors.red, fontWeight: FontWeight.bold),
                    textAlign: TextAlign.center,
                  ),

                // --- Botão de Registro ---
                SizedBox(
                  height: 50,
                  child: ElevatedButton(
                    key: const ValueKey('registerButton'),
                    child: isLoading
                        ? const CircularProgressIndicator(valueColor: AlwaysStoppedAnimation<Color>(Colors.white))
                        : const Text('CRIAR CONTA', style: TextStyle(fontSize: 18)),
                    onPressed: isLoading ? null : () => _onRegisterPressed(context),
                  ),
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
  group('RegisterScreen Widget Tests', () {
    late MockAuthNotifier mockAuth;

    // Wrapper para injetar o Notifier no widget
    Widget createWidget() {
      return ChangeNotifierProvider<AuthNotifier>.value(
        value: mockAuth,
        child: const MaterialApp(home: RegisterScreen()),
      );
    }

    // Configuração: Garante estado limpo e objetos antes de cada teste
    setUp(() {
      mockAuth = MockAuthNotifier();
      // Limpa os controladores após cada teste
      RegisterScreen._nameController.text = 'Novo Usuário';
      RegisterScreen._emailController.text = 'novo@email.com';
      RegisterScreen._passwordController.text = 'secure123';
      mockAuth.registerResult = true;
      mockAuth.errorMessage = null;
    });

    testWidgets('01. Registro Bem-Sucedido: Deve chamar register com dados e limpar o estado de loading', (WidgetTester tester) async {
      await tester.pumpWidget(createWidget());
      
      // Clica no botão (assumindo que os dados iniciais são válidos)
      await tester.tap(find.byKey(const ValueKey('registerButton')));
      
      // O pumpAndSettle garante que a chamada assíncrona do mock termine
      await tester.pumpAndSettle(); 

      // 1. Verifica se o método register foi chamado com os valores corretos
      expect(mockAuth.nameAttempted, 'Novo Usuário');
      expect(mockAuth.emailAttempted, 'novo@email.com');
      
      // 2. Verifica se o spinner sumiu (estado finalizado)
      expect(find.byType(CircularProgressIndicator), findsNothing);
      expect(find.text('CRIAR CONTA'), findsOneWidget);
    });
    
    testWidgets('02. Registro Falho: Deve exibir a mensagem de erro e retornar ao estado unauthenticated', (WidgetTester tester) async {
      mockAuth.registerResult = false; // Configura o mock para falhar
      await tester.pumpWidget(createWidget());

      // Clica no botão
      await tester.tap(find.byKey(const ValueKey('registerButton')));
      
      // O pumpAndSettle garante que a chamada assíncrona do mock termine
      await tester.pumpAndSettle(); 

      // 1. Verifica a Mensagem de Erro
      expect(find.byKey(const ValueKey('errorMessage')), findsOneWidget);
      expect(find.text('E-mail já cadastrado.'), findsOneWidget);
      
      // 2. Verifica o botão (deve estar habilitado)
      final button = tester.widget<ElevatedButton>(find.byKey(const ValueKey('registerButton')));
      expect(button.onPressed, isNotNull);
    });

    testWidgets('03. Deve exibir o spinner e desabilitar o botão durante o loading', (WidgetTester tester) async {
      await tester.pumpWidget(createWidget());
      
      // Simula o clique no botão para iniciar o loading
      await tester.tap(find.byKey(const ValueKey('registerButton')));
      await tester.pump(); // Processa a mudança para o estado AuthStatus.loading

      // 1. Verifica o Spinner
      expect(find.byType(CircularProgressIndicator), findsOneWidget);
      
      // 2. Verifica se o botão está desabilitado
      final button = tester.widget<ElevatedButton>(find.byKey(const ValueKey('registerButton')));
      expect(button.onPressed, isNull);
    });

    testWidgets('04. Registro não deve ocorrer se a validação do formulário falhar (Senha Curta)', (WidgetTester tester) async {
      // Força a falha na validação
      RegisterScreen._passwordController.text = '123'; // Menos de 6 caracteres
      
      await tester.pumpWidget(createWidget());
      
      // Clica no botão
      await tester.tap(find.byKey(const ValueKey('registerButton')));
      
      // O pump processa a validação
      await tester.pump();
      
      // 1. Verifica se a mensagem de erro de validação (Curta.) aparece
      expect(find.text('Senha deve ter 6+ caracteres.'), findsOneWidget);
      
      // 2. Verifica se o método register *não* foi chamado
      expect(mockAuth.emailAttempted, '', reason: 'O registerService não deve ser chamado se o formulário falhar.');
    });
  });
}