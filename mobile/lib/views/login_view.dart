// lib/views/login_view.dart

import 'package:flutter/material.dart';
import 'package:antibet_mobile/services/auth_service.dart';
import 'package:antibet_mobile/views/home_view.dart'; 

class LoginView extends StatefulWidget {
  const LoginView({super.key});

  @override
  State<LoginView> createState() => _LoginViewState();
}

class _LoginViewState extends State<LoginView> {
  // Chave global para o formulário para validação
  final _formKey = GlobalKey<FormState>(); 
  
  // Controladores de texto para os campos do formulário
  final TextEditingController _emailController = TextEditingController();
  final TextEditingController _passwordController = TextEditingController();
  
  // Estado de carregamento para desabilitar o botão durante a requisição
  bool _isLoading = false;
  
  // Instância do serviço de autenticação (Singleton)
  final AuthService _authService = AuthService();

  @override
  void dispose() {
    _emailController.dispose();
    _passwordController.dispose();
    super.dispose();
  }

  // Lógica de submissão de login
  Future<void> _handleLogin() async {
    if (_formKey.currentState!.validate()) {
      setState(() {
        _isLoading = true;
      });

      try {
        await _authService.login(
          _emailController.text,
          _passwordController.text,
        );
        
        // Navegação de sucesso (Substituindo a tela de Login pela HomeView)
        if (mounted) {
          Navigator.of(context).pushReplacement(
            MaterialPageRoute(builder: (context) => const HomeView()),
          );
        }

      } catch (e) {
        // Exibir erro (pode ser via SnackBar ou Dialog)
        if (mounted) {
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(content: Text('Falha no Login: ${e.toString()}')),
          );
        }
      } finally {
        if (mounted) {
          setState(() {
            _isLoading = false;
          });
        }
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Acesso AntiBet'),
        backgroundColor: Theme.of(context).primaryColor,
      ),
      body: Center(
        child: SingleChildScrollView(
          padding: const EdgeInsets.all(32.0),
          child: Form(
            key: _formKey,
            child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              crossAxisAlignment: CrossAxisAlignment.stretch,
              children: <Widget>[
                const Text(
                  'Bem-vindo. Faça seu Login.',
                  textAlign: TextAlign.center,
                  style: TextStyle(fontSize: 24, fontWeight: FontWeight.bold),
                ),
                const SizedBox(height: 40),
                
                // Campo de Email
                TextFormField(
                  controller: _emailController,
                  decoration: const InputDecoration(
                    labelText: 'E-mail',
                    border: OutlineInputBorder(),
                    prefixIcon: Icon(Icons.email),
                  ),
                  keyboardType: TextInputType.emailAddress,
                  validator: (value) {
                    if (value == null || value.isEmpty) {
                      return 'Por favor, insira seu e-mail.';
                    }
                    return null;
                  },
                ),
                const SizedBox(height: 16),
                
                // Campo de Senha
                TextFormField(
                  controller: _passwordController,
                  decoration: const InputDecoration(
                    labelText: 'Senha',
                    border: OutlineInputBorder(),
                    prefixIcon: Icon(Icons.lock),
                  ),
                  obscureText: true,
                  validator: (value) {
                    if (value == null || value.isEmpty) {
                      return 'Por favor, insira sua senha.';
                    }
                    return null;
                  },
                ),
                const SizedBox(height: 32),
                
                // Botão de Login
                ElevatedButton(
                  onPressed: _isLoading ? null : _handleLogin,
                  style: ElevatedButton.styleFrom(
                    minimumSize: const Size(double.infinity, 50), 
                  ),
                  child: _isLoading
                      ? const SizedBox(
                          width: 24,
                          height: 24,
                          child: CircularProgressIndicator(strokeWidth: 2.0),
                        )
                      : const Text(
                          'Entrar',
                          style: TextStyle(fontSize: 18),
                        ),
                ),
                
                // Placeholder para Registro/Esqueci Senha
                TextButton(
                  onPressed: () {
                    // Implementar navegação para Registro
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