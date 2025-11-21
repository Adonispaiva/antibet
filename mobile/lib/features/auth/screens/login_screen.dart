import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:antibet/core/ui/feedback_manager.dart';
import 'package:antibet/features/auth/providers/auth_provider.dart';
import 'package:antibet/features/journal/screens/journal_screen.dart'; // Tela de destino após o login

class LoginScreen extends ConsumerStatefulWidget {
  const LoginScreen({super.key});

  @override
  ConsumerState<LoginScreen> createState() => _LoginScreenState();
}

class _LoginScreenState extends ConsumerState<LoginScreen> {
  final _emailController = TextEditingController(text: 'teste@inovexa.com.br');
  final _passwordController = TextEditingController(text: 'senha123');
  final _formKey = GlobalKey<FormState>();

  @override
  void dispose() {
    _emailController.dispose();
    _passwordController.dispose();
    super.dispose();
  }

  void _submitLogin() async {
    if (_formKey.currentState?.validate() != true) {
      return;
    }

    // O estado de loading será refletido pelo watch/listen abaixo
    final notifier = ref.read(authProvider.notifier);

    try {
      // Chama o método de login. O Notifier lida com o AsyncValue.loading/error/data
      await notifier.login(_emailController.text.trim(), _passwordController.text.trim());
      
      // O ref.listen abaixo lidará com a navegação em caso de sucesso
      
    } catch (e) {
      // O AuthNotifier re-lança uma exceção genérica ('Login falhou.') para esta camada capturar
      FeedbackManager.showError(context, 'Falha no Login. Verifique suas credenciais.');
    }
  }

  @override
  Widget build(BuildContext context) {
    // Observa o estado de autenticação para gerenciar a navegação
    ref.listen<AsyncValue>(authProvider, (previous, next) {
      next.whenOrNull(
        data: (user) {
          // Navega apenas se o login foi bem-sucedido (UserModel não é nulo)
          if (user != null) {
            // Usa pushReplacement para que o usuário não possa voltar à tela de login
            Navigator.of(context).pushReplacement(
              MaterialPageRoute(builder: (context) => const JournalScreen()),
            );
          }
        },
        // O tratamento de erro já foi feito no try-catch do _submitLogin
      );
    });

    // Observa o estado de loading para desabilitar o botão
    final authStatus = ref.watch(authProvider);
    final isLoading = authStatus.isLoading;

    return Scaffold(
      appBar: AppBar(
        title: const Text('Login - AntiBet'),
        automaticallyImplyLeading: false, // Login geralmente é a raiz
      ),
      body: Center(
        child: SingleChildScrollView(
          padding: const EdgeInsets.all(32.0),
          child: Form(
            key: _formKey,
            child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              crossAxisAlignment: CrossAxisAlignment.stretch,
              children: [
                Text(
                  'Acesse sua conta',
                  style: Theme.of(context).textTheme.headlineMedium,
                  textAlign: TextAlign.center,
                ),
                const SizedBox(height: 40),
                
                TextFormField(
                  controller: _emailController,
                  keyboardType: TextInputType.emailAddress,
                  decoration: const InputDecoration(
                    labelText: 'E-mail',
                    prefixIcon: Icon(Icons.email_outlined),
                  ),
                  validator: (value) {
                    if (value == null || !value.contains('@')) {
                      return 'Por favor, insira um e-mail válido.';
                    }
                    return null;
                  },
                ),
                const SizedBox(height: 20),
                
                TextFormField(
                  controller: _passwordController,
                  obscureText: true,
                  decoration: const InputDecoration(
                    labelText: 'Senha',
                    prefixIcon: Icon(Icons.lock_outline),
                  ),
                  validator: (value) {
                    if (value == null || value.length < 6) {
                      return 'A senha deve ter pelo menos 6 caracteres.';
                    }
                    return null;
                  },
                ),
                const SizedBox(height: 40),
                
                ElevatedButton(
                  onPressed: isLoading ? null : _submitLogin,
                  style: ElevatedButton.styleFrom(
                    minimumSize: const Size(double.infinity, 50),
                  ),
                  child: isLoading
                      ? const SizedBox(
                          height: 20,
                          width: 20,
                          child: CircularProgressIndicator(color: Colors.white, strokeWidth: 2),
                        )
                      : const Text('Entrar', style: TextStyle(fontSize: 18)),
                ),
                const SizedBox(height: 20),
                
                // Exemplo de link para tela de registro futura
                TextButton(
                  onPressed: () {
                    // TODO: Implementar navegação para a tela de Registro
                  },
                  child: const Text('Não tem conta? Registre-se'),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}