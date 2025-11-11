import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

import 'package:mobile/notifiers/auth_notifier.dart';
// Importação para navegação
// import 'package:go_router/go_router.dart';

class RegisterScreen extends StatelessWidget {
  const RegisterScreen({super.key});

  // O caminho estático para navegação.
  static const String routeName = '/register';

  @override
  Widget build(BuildContext context) {
    // Chave global para o formulário.
    final GlobalKey<FormState> formKey = GlobalKey<FormState>();

    // Controladores para os campos de texto.
    final TextEditingController nameController = TextEditingController();
    final TextEditingController emailController = TextEditingController();
    final TextEditingController passwordController = TextEditingController();
    final TextEditingController confirmPasswordController = TextEditingController();

    // Watcher no AuthNotifier para gerenciar o estado (loading, erros)
    final authNotifier = context.watch<AuthNotifier>();

    // Função de submissão integrada com o Notifier
    void submitRegistration() async {
      if (formKey.currentState?.validate() ?? false) {
        // Esconde qualquer SnackBar anterior
        ScaffoldMessenger.of(context).hideCurrentSnackBar();

        // Implementação da chamada ao AuthNotifier.register no futuro
        // await authNotifier.register(
        //   name: nameController.text.trim(),
        //   email: emailController.text.trim(),
        //   password: passwordController.text,
        // );

        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text('Tentativa de Cadastro em progresso...')),
        );
        
        // Simulação do log para teste
        debugPrint('Nome: ${nameController.text}');
        debugPrint('Email: ${emailController.text}');
      }
    }

    return Scaffold(
      appBar: AppBar(
        title: const Text('AntiBet - Cadastro'),
      ),
      body: Center(
        child: SingleChildScrollView(
          padding: const EdgeInsets.all(32.0),
          child: Form(
            key: formKey,
            child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              crossAxisAlignment: CrossAxisAlignment.stretch,
              children: <Widget>[
                // Título
                const Text(
                  'Crie sua conta AntiBet',
                  style: TextStyle(
                    fontSize: 28,
                    fontWeight: FontWeight.bold,
                    color: Color(0xFF1E88E5),
                  ),
                  textAlign: TextAlign.center,
                ),
                const SizedBox(height: 40),

                // Campo de Nome
                TextFormField(
                  controller: nameController,
                  keyboardType: TextInputType.text,
                  decoration: const InputDecoration(
                    labelText: 'Nome Completo',
                    prefixIcon: Icon(Icons.person),
                  ),
                  validator: (value) {
                    if (value == null || value.isEmpty) {
                      return 'O nome é obrigatório.';
                    }
                    return null;
                  },
                ),
                const SizedBox(height: 20),
                
                // Campo de E-mail
                TextFormField(
                  controller: emailController,
                  keyboardType: TextInputType.emailAddress,
                  decoration: const InputDecoration(
                    labelText: 'E-mail',
                    prefixIcon: Icon(Icons.email),
                  ),
                  validator: (value) {
                    if (value == null || value.isEmpty) {
                      return 'O e-mail é obrigatório.';
                    }
                    if (!RegExp(r'^[^@]+@[^@]+\.[^@]+').hasMatch(value)) {
                      return 'Por favor, insira um e-mail válido.';
                    }
                    return null;
                  },
                ),
                const SizedBox(height: 20),

                // Campo de Senha
                TextFormField(
                  controller: passwordController,
                  obscureText: true,
                  decoration: const InputDecoration(
                    labelText: 'Senha',
                    prefixIcon: Icon(Icons.lock),
                  ),
                  validator: (value) {
                    if (value == null || value.length < 6) {
                      return 'A senha deve ter pelo menos 6 caracteres.';
                    }
                    return null;
                  },
                ),
                const SizedBox(height: 20),

                // Campo de Confirmação de Senha
                TextFormField(
                  controller: confirmPasswordController,
                  obscureText: true,
                  decoration: const InputDecoration(
                    labelText: 'Confirmar Senha',
                    prefixIcon: Icon(Icons.lock_reset),
                  ),
                  validator: (value) {
                    if (value == null || value.isEmpty) {
                      return 'Confirme sua senha.';
                    }
                    if (value != passwordController.text) {
                      return 'As senhas não coincidem.';
                    }
                    return null;
                  },
                ),
                const SizedBox(height: 30),

                // Botão de Cadastro
                ElevatedButton(
                  // Desabilita o botão se já estiver em loading
                  onPressed: authNotifier.isLoading ? null : submitRegistration,
                  style: ElevatedButton.styleFrom(
                    padding: const EdgeInsets.symmetric(vertical: 15),
                    textStyle: const TextStyle(fontSize: 18),
                  ),
                  child: authNotifier.isLoading
                      ? const SizedBox(
                          width: 24,
                          height: 24,
                          child: CircularProgressIndicator(
                            color: Colors.white,
                            strokeWidth: 2.0,
                          ),
                        )
                      : const Text('Cadastrar'),
                ),

                const SizedBox(height: 20),

                // Opção para retornar ao Login
                TextButton(
                  onPressed: () {
                    // Navegação será implementada pelo AppRouter para voltar ao Login
                    Navigator.of(context).pop(); 
                  },
                  child: const Text('Já tenho uma conta. Voltar ao Login.'),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}