import 'package:flutter/material.dart';

// Este Widget representa a tela de Login da aplicação.
// É um StatefulWidget para gerenciar o estado do formulário e dos inputs.

class LoginScreen extends StatefulWidget {
  const LoginScreen({super.key});

  // O caminho estático para navegação.
  static const routeName = '/login';

  @override
  State<LoginScreen> createState() => _LoginScreenState();
}

class _LoginScreenState extends State<LoginScreen> {
  // Chave global para o formulário, essencial para validação e reset.
  final GlobalKey<FormState> _formKey = GlobalKey<FormState>();

  // Controladores para os campos de texto.
  final TextEditingController _emailController = TextEditingController();
  final TextEditingController _passwordController = TextEditingController();

  @override
  void dispose() {
    _emailController.dispose();
    _passwordController.dispose();
    super.dispose();
  }

  // Função simulada para o processo de login. Será implementada a lógica de API aqui.
  void _submitLogin() {
    if (_formKey.currentState?.validate() ?? false) {
      // Aqui será integrada a lógica de chamada de API/Autenticação
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Tentativa de Login em progresso...')),
      );
      // Por enquanto, apenas loga os valores no console.
      debugPrint('Email: ${_emailController.text}');
      debugPrint('Senha: ${_passwordController.text}');
    }
  }

  @override
  Widget build(BuildContext context) {
    // Para obter as dimensões da tela e adaptar o layout, se necessário.
    // final size = MediaQuery.of(context).size;

    return Scaffold(
      appBar: AppBar(
        title: const Text('AntiBet - Login'),
        // Sem botão de voltar, pois será a tela inicial após o splash.
        automaticallyImplyLeading: false,
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
                // Título/Logo
                const Text(
                  'Bem-vindo(a) de volta!',
                  style: TextStyle(
                    fontSize: 24,
                    fontWeight: FontWeight.bold,
                  ),
                  textAlign: TextAlign.center,
                ),
                const SizedBox(height: 40),

                // Campo de E-mail
                TextFormField(
                  controller: _emailController,
                  keyboardType: TextInputType.emailAddress,
                  decoration: const InputDecoration(
                    labelText: 'E-mail',
                    border: OutlineInputBorder(),
                    prefixIcon: Icon(Icons.email),
                  ),
                  validator: (value) {
                    if (value == null || value.isEmpty) {
                      return 'Por favor, insira seu e-mail.';
                    }
                    // Validação de formato de e-mail básica
                    if (!value.contains('@') || !value.contains('.')) {
                      return 'E-mail inválido.';
                    }
                    return null;
                  },
                ),
                const SizedBox(height: 20),

                // Campo de Senha
                TextFormField(
                  controller: _passwordController,
                  obscureText: true,
                  decoration: const InputDecoration(
                    labelText: 'Senha',
                    border: OutlineInputBorder(),
                    prefixIcon: Icon(Icons.lock),
                  ),
                  validator: (value) {
                    if (value == null || value.isEmpty) {
                      return 'Por favor, insira sua senha.';
                    }
                    if (value.length < 6) {
                      return 'A senha deve ter pelo menos 6 caracteres.';
                    }
                    return null;
                  },
                ),
                const SizedBox(height: 30),

                // Botão de Login
                ElevatedButton(
                  onPressed: _submitLogin,
                  style: ElevatedButton.styleFrom(
                    padding: const EdgeInsets.symmetric(vertical: 15),
                    textStyle: const TextStyle(fontSize: 18),
                  ),
                  child: const Text('Entrar'),
                ),

                const SizedBox(height: 20),

                // Opção para redefinição de senha
                TextButton(
                  onPressed: () {
                    // Lógica para navegação para tela de redefinição de senha
                    debugPrint('Redefinir Senha pressionado');
                  },
                  child: const Text('Esqueceu sua senha?'),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}