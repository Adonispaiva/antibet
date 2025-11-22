import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

// Importações das dependências para consumo
import '../../notifiers/auth_notifier.dart'; 

class RegisterView extends StatefulWidget {
  const RegisterView({super.key});

  @override
  State<RegisterView> createState() => _RegisterViewState();
}

class _RegisterViewState extends State<RegisterView> {
  final _formKey = GlobalKey<FormState>();
  final TextEditingController _emailController = TextEditingController();
  final TextEditingController _passwordController = TextEditingController();
  final TextEditingController _confirmPasswordController = TextEditingController();
  
  bool _isLoading = false; 

  @override
  void dispose() {
    _emailController.dispose();
    _passwordController.dispose();
    _confirmPasswordController.dispose();
    super.dispose();
  }

  /// Manipulador de registro agora utiliza o AuthNotifier.
  Future<void> _handleRegister() async {
    if (_formKey.currentState!.validate()) {
      setState(() {
        _isLoading = true;
      });

      // Obtém a instância do AuthNotifier sem escutar (context.read)
      final authNotifier = context.read<AuthNotifier>();

      try {
        // Chama o método register no Notifier
        await authNotifier.register(
          _emailController.text,
          _passwordController.text,
        );
        
        // Se o registro for bem-sucedido (e resulta em login automático):
        // 1. O AuthNotifier muda para 'authenticated'.
        // 2. O AuthGate (main.dart) navega para HomeView.
        // 3. Exibimos um feedback ao usuário e mantemos a navegação automática via AuthGate.
        
        // Exibe o diálogo de sucesso, que também irá desempilhar a tela de registro.
        _showSuccessDialog('Sucesso!', 'Conta criada e login realizado com sucesso!');


      } on AuthException catch (e) {
        // Trata exceções específicas da autenticação
        _showErrorDialog('Falha no Registro', e.message);
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

  void _showSuccessDialog(String title, String message) {
    showDialog(
      context: context,
      builder: (ctx) => AlertDialog(
        title: Text(title),
        content: Text(message),
        actions: <Widget>[
          TextButton(
            child: const Text('OK'),
            onPressed: () {
              Navigator.of(ctx).pop(); // Fecha o diálogo
              // Não precisa mais do pop() externo, o AuthGate cuida da navegação.
            },
          )
        ],
      ),
    );
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
      appBar: AppBar(title: const Text('Criar Nova Conta')),
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
                    if (value == null || value.isEmpty || value.length < 8) {
                      return 'A senha deve ter pelo menos 8 caracteres';
                    }
                    return null;
                  },
                ),
                const SizedBox(height: 16),
                // Campo de Confirmação de Senha
                TextFormField(
                  controller: _confirmPasswordController,
                  decoration: const InputDecoration(labelText: 'Confirme a Senha'),
                  obscureText: true,
                  validator: (value) {
                    if (value == null || value.isEmpty) {
                      return 'Confirme a senha';
                    }
                    if (value != _passwordController.text) {
                      return 'As senhas não coincidem';
                    }
                    return null;
                  },
                ),
                const SizedBox(height: 32),
                // Botão de Registro
                ElevatedButton(
                  onPressed: _isLoading ? null : _handleRegister, 
                  child: _isLoading 
                      ? const CircularProgressIndicator(color: Colors.white)
                      : const Text('Registrar'),
                ),
                const SizedBox(height: 16),
                // Botão de retorno
                 TextButton(
                  onPressed: _isLoading 
                    ? null 
                    : () {
                      Navigator.of(context).pop(); // Volta para a tela de Login
                    },
                  child: const Text('Já tenho uma conta'),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}