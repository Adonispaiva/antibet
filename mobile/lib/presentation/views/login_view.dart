import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

// Importação do Notifier da Camada de Apresentação
import '../../notifiers/auth_notifier.dart'; 
// Importação para tratamento de exceção
import '../../infra/services/auth_service.dart'; 
// Importação da View de Registro
import 'register_view.dart'; 

class LoginView extends StatefulWidget {
  const LoginView({super.key});

  @override
  State<LoginView> createState() => _LoginViewState();
}

class _LoginViewState extends State<LoginView> {
  final _formKey = GlobalKey<FormState>();
  final TextEditingController _emailController = TextEditingController();
  final TextEditingController _passwordController = TextEditingController();
  
  // Variável de estado local para controle visual (Feedback do usuário)
  bool _isLoading = false; 

  @override
  void dispose() {
    _emailController.dispose();
    _passwordController.dispose();
    super.dispose();
  }

  /// Refatorado: Não navega mais. Apenas chama o Notifier e gerencia o estado local.
  Future<void> _handleLogin() async {
    if (_formKey.currentState!.validate()) {
      setState(() {
        _isLoading = true;
      });

      // Obtém a instância do AuthNotifier sem escutar (context.read)
      final authNotifier = context.read<AuthNotifier>();

      try {
        // Chama o método login no Notifier, que orquestra a chamada de serviço
        await authNotifier.login(
          _emailController.text,
          _passwordController.text,
        );
        
        // Se o login for bem-sucedido, o AuthNotifier mudará o estado para 'authenticated'.
        // O widget AuthGate (em main.dart) observará esta mudança e fará a navegação automaticamente para HomeView.

      } on AuthException catch (e) {
        // Trata exceções específicas da autenticação
        _showErrorDialog('Falha no Login', e.message);
      } catch (e) {
        // Trata outras exceções genéricas
        _showErrorDialog('Erro', 'Ocorreu um erro inesperado. Tente novamente.');
      } finally {
        // O estado de carregamento é redefinido
        if (mounted) {
          setState(() {
            _isLoading = false;
          });
        }
      }
    }
  }

  void _showErrorDialog(String title, String message) {
    showDialog(
      context: context,
      builder: (ctx) => AlertDialog(
        title: Text(title),
        content: Text(message),
        actions: <Widget>[
          TextButton(
            child: const Text('OK'),
            onPressed: () {
              Navigator.of(ctx).pop();
            },
          )
        ],
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('Login - AntiBet Mobile')),
      body: Center(
        child: SingleChildScrollView(
          padding: const EdgeInsets.all(16.0),
          child: Form(
            key: _formKey,
            child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              children: <Widget>[
                // Campo de Email
                TextFormField(
                  controller: _emailController,
                  decoration: const InputDecoration(labelText: 'Email'),
                  keyboardType: TextInputType.emailAddress,
                  validator: (value) {
                    if (value == null || value.isEmpty || !value.contains('@')) {
                      return 'Digite um email válido';
                    }
                    return null;
                  },
                ),
                const SizedBox(height: 16),
                // Campo de Senha
                TextFormField(
                  controller: _passwordController,
                  decoration: const InputDecoration(labelText: 'Senha'),
                  obscureText: true,
                  validator: (value) {
                    if (value == null || value.isEmpty || value.length < 6) {
                      return 'A senha deve ter pelo menos 6 caracteres';
                    }
                    return null;
                  },
                ),
                const SizedBox(height: 32),
                // Botão de Login
                ElevatedButton(
                  onPressed: _isLoading ? null : _handleLogin, // Desabilita durante o carregamento
                  child: _isLoading 
                      ? const CircularProgressIndicator(color: Colors.white)
                      : const Text('Entrar'),
                ),
                const SizedBox(height: 16),
                // Botão para Tela de Cadastro (Prioridade 3)
                TextButton(
                  onPressed: _isLoading 
                    ? null 
                    : () {
                      // Implementação da navegação para a View de Registro
                      Navigator.of(context).push(
                        MaterialPageRoute(builder: (context) => const RegisterView()),
                      );
                    },
                  child: const Text('Não tem conta? Cadastre-se'),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}