// mobile/lib/features/auth/screens/login_screen.dart

import 'package:antibet/features/auth/notifiers/auth_notifier.dart';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

class LoginScreen extends StatefulWidget {
  const LoginScreen({super.key});

  @override
  State<LoginScreen> createState() => _LoginScreenState();
}

class _LoginScreenState extends State<LoginScreen> {
  final _emailController = TextEditingController();
  final _passwordController = TextEditingController();
  final _formKey = GlobalKey<FormState>();

  String? _errorMessage;

  @override
  void dispose() {
    _emailController.dispose();
    _passwordController.dispose();
    super.dispose();
  }

  /// Tenta realizar o login chamando o AuthNotifier.
  Future<void> _attemptLogin() async {
    if (!_formKey.currentState!.validate()) {
      return;
    }
    
    // Limpa erros antigos
    setState(() {
      _errorMessage = null;
    });

    // Acessa o Notifier (sem 'watch' no método)
    final authNotifier = context.read<AuthNotifier>();
    
    final success = await authNotifier.login(
      _emailController.text.trim(),
      _passwordController.text.trim(),
    );

    if (!success && mounted) {
      setState(() {
        _errorMessage = 'Falha no login. Verifique seu e-mail ou senha.';
      });
    }
    // Se 'success' for true, o AuthWrapper (em main.dart) 
    // detectará a mudança no 'isAuthenticated' e navegará automaticamente.
  }

  @override
  Widget build(BuildContext context) {
    // Escuta o 'isLoading' do Notifier
    final isLoading = context.watch<AuthNotifier>().isLoading;

    return Scaffold(
      backgroundColor: Colors.blue, // Fundo alinhado com o Splash
      body: Center(
        child: SingleChildScrollView(
          padding: const EdgeInsets.all(32.0),
          child: Card(
            elevation: 8,
            shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
            child: Padding(
              padding: const EdgeInsets.all(24.0),
              child: Form(
                key: _formKey,
                child: Column(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    // Logo (Placeholder)
                    const Icon(
                      Icons.shield,
                      size: 60,
                      color: Colors.blue,
                    ),
                    const SizedBox(height: 8),
                    Text(
                      'AntiBet Login',
                      style: Theme.of(context).textTheme.headlineSmall?.copyWith(fontWeight: FontWeight.bold),
                    ),
                    const SizedBox(height: 24),
                    
                    // Campo de Email
                    TextFormField(
                      controller: _emailController,
                      keyboardType: TextInputType.emailAddress,
                      decoration: const InputDecoration(
                        labelText: 'Email',
                        prefixIcon: Icon(Icons.email_outlined),
                        border: OutlineInputBorder(),
                      ),
                      validator: (value) => (value == null || !value.contains('@'))
                          ? 'Por favor, insira um email válido.'
                          : null,
                    ),
                    const SizedBox(height: 16),
                    
                    // Campo de Senha
                    TextFormField(
                      controller: _passwordController,
                      obscureText: true,
                      decoration: const InputDecoration(
                        labelText: 'Senha',
                        prefixIcon: Icon(Icons.lock_outline),
                        border: OutlineInputBorder(),
                      ),
                      validator: (value) => (value == null || value.length < 6)
                          ? 'A senha deve ter pelo menos 6 caracteres.'
                          : null,
                    ),
                    const SizedBox(height: 24),

                    // Mensagem de Erro
                    if (_errorMessage != null)
                      Padding(
                        padding: const EdgeInsets.only(bottom: 16.0),
                        child: Text(
                          _errorMessage!,
                          style: const TextStyle(color: Colors.red, fontWeight: FontWeight.bold),
                        ),
                      ),
                    
                    // Botão de Login
                    isLoading
                        ? const CircularProgressIndicator()
                        : ElevatedButton(
                            onPressed: _attemptLogin,
                            style: ElevatedButton.styleFrom(
                              minimumSize: const Size(double.infinity, 50),
                              shape: RoundedRectangleBorder(
                                borderRadius: BorderRadius.circular(8),
                              ),
                            ),
                            child: const Text('Entrar', style: TextStyle(fontSize: 16)),
                          ),
                    
                    const SizedBox(height: 16),
                    
                    // Link para Registro (Placeholder)
                    TextButton(
                      onPressed: () {
                        // TODO: Implementar navegação para a Tela de Registro
                      },
                      child: const Text('Não tem uma conta? Registre-se'),
                    ),
                  ],
                ),
              ),
            ),
          ),
        ),
      ),
    );
  }
}