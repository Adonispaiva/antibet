import 'package:flutter/material.dart';

/// Tela de Login (LoginScreen)
///
/// Este componente é o ponto de entrada para a autenticação do usuário.
/// Por ser um componente crítico, ele deve ser robusto e reativo a estados
/// de autenticação (AuthNotifier) e de bloqueio (LockdownNotifier,
/// que é gerenciado em AppRouter, mas a tela de login precisa se comportar
/// corretamente se o usuário for deslogado em um estado pós-bloqueio, por exemplo).
class LoginScreen extends StatelessWidget {
  const LoginScreen({super.key});

  @override
  Widget build(BuildContext context) {
    // Nota: A lógica de navegação reativa a Auth/Lockdown já está em AppRouter.
    // Esta tela se concentra na UI e na captura de credenciais.
    return Scaffold(
      appBar: AppBar(
        title: const Text('Acesso AntiBet'),
        centerTitle: true,
      ),
      body: Center(
        child: Padding(
          padding: const EdgeInsets.all(32.0),
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: <Widget>[
              // Placeholder para o logotipo ou imagem principal
              const Icon(
                Icons.security_rounded,
                size: 80,
                color: Colors.blueGrey,
              ),
              const SizedBox(height: 48),

              // Campo de Email
              TextFormField(
                keyboardType: TextInputType.emailAddress,
                decoration: const InputDecoration(
                  labelText: 'Email',
                  border: OutlineInputBorder(),
                  prefixIcon: Icon(Icons.email),
                ),
                // Lógica de controle (controller, validator) será adicionada
                // na fase de integração com Auth/Formz
              ),
              const SizedBox(height: 16),

              // Campo de Senha
              TextFormField(
                obscureText: true,
                decoration: const InputDecoration(
                  labelText: 'Senha',
                  border: OutlineInputBorder(),
                  prefixIcon: Icon(Icons.lock),
                ),
                // Lógica de controle (controller, validator) será adicionada
              ),
              const SizedBox(height: 32),

              // Botão de Login
              ElevatedButton(
                onPressed: () {
                  // TODO: Implementar a chamada ao AuthService.login()
                  // Após o login bem-sucedido, o AppRouter fará o redirecionamento
                  // para a HomeScreen ou a LockdownScreen (se o risco for High).
                  print('Tentativa de Login...');
                },
                style: ElevatedButton.styleFrom(
                  minimumSize: const Size(double.infinity, 50),
                  padding: const EdgeInsets.symmetric(vertical: 16.0),
                ),
                child: const Text(
                  'Entrar',
                  style: TextStyle(fontSize: 18),
                ),
              ),
              const SizedBox(height: 24),

              // Opção de Cadastro
              TextButton(
                onPressed: () {
                  // TODO: Implementar navegação para a tela de cadastro
                  print('Navegar para Cadastro...');
                },
                child: const Text('Não tem conta? Cadastre-se'),
              ),
            ],
          ),
        ),
      ),
    );
  }
}