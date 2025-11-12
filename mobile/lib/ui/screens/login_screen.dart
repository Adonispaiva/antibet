import 'package:antibet_mobile/notifiers/auth_notifier.dart';
import 'package:antibet_mobile/ui/screens/register_screen.dart';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

/// Tela de Autenticação (Login).
///
/// Esta tela é 'Stateless' e consome o [AuthNotifier] para
/// gerenciar o estado de login, exibindo feedback (loading/erro)
/// e tratando a submissão do formulário.
class LoginScreen extends StatelessWidget {
  const LoginScreen({super.key});

  // Controladores para os campos de texto
  // (Eles são a única exceção de 'estado' permitida em um StatelessWidget)
  static final _emailController = TextEditingController();
  static final _passwordController = TextEditingController();
  static final _formKey = GlobalKey<FormState>();

  /// Função de callback para tentar o login.
  /// Usamos 'context.read' aqui pois estamos disparando uma *ação*.
  void _onLoginPressed(BuildContext context) async {
    // 1. Valida o formulário
    if (!(_formKey.currentState?.validate() ?? false)) {
      return;
    }

    // 2. Chama a *ação* no Notifier
    final authNotifier = context.read<AuthNotifier>();
    await authNotifier.login(
      _emailController.text,
      _passwordController.text,
    );
    
    // 3. O 'home' no main.dart (Consumer) tratará a navegação
    // se o login for bem-sucedido. Se falhar, o 'watch'
    // abaixo exibirá a mensagem de erro.
  }

  /// Navega para a tela de registro.
  void _onRegisterPressed(BuildContext context) {
    Navigator.of(context).push(
      MaterialPageRoute(builder: (_) => const RegisterScreen()),
    );
  }

  @override
  Widget build(BuildContext context) {
    // Usamos 'context.watch' para *observar* mudanças de estado.
    final authStatus = context.watch<AuthNotifier>().status;
    final errorMessage = context.watch<AuthNotifier>().errorMessage;
    final isLoading = authStatus == AuthStatus.loading;

    return Scaffold(
      appBar: AppBar(
        title: const Text('AntiBet Login'),
        centerTitle: true,
      ),
      body: Center(
        child: SingleChildScrollView(
          padding: const EdgeInsets.all(24.0),
          child: Form(
            key: _formKey,
            child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              crossAxisAlignment: CrossAxisAlignment.stretch,
              children: [
                // TODO: Adicionar Logo
                const Icon(Icons.shield_outlined, size: 80),
                const SizedBox(height: 24),

                // --- Campo de Email ---
                TextFormField(
                  controller: _emailController,
                  keyboardType: TextInputType.emailAddress,
                  decoration: const InputDecoration(
                    labelText: 'E-mail',
                    border: OutlineInputBorder(),
                    prefixIcon: Icon(Icons.email_outlined),
                  ),
                  validator: (value) =>
                      (value == null || !value.contains('@'))
                          ? 'Por favor, insira um e-mail válido.'
                          : null,
                  enabled: !isLoading, // Desativa campos durante o loading
                ),
                const SizedBox(height: 16),

                // --- Campo de Senha ---
                TextFormField(
                  controller: _passwordController,
                  obscureText: true,
                  decoration: const InputDecoration(
                    labelText: 'Senha',
                    border: OutlineInputBorder(),
                    prefixIcon: Icon(Icons.lock_outline),
                  ),
                  validator: (value) => (value == null || value.length < 4)
                      ? 'Senha deve ter no mínimo 4 caracteres.'
                      : null,
                  enabled: !isLoading, // Desativa campos durante o loading
                ),
                const SizedBox(height: 24),

                // --- Feedback de Erro ---
                if (errorMessage != null && !isLoading)
                  Padding(
                    padding: const EdgeInsets.only(bottom: 16.0),
                    child: Text(
                      errorMessage,
                      style: TextStyle(
                        color: Theme.of(context).colorScheme.error,
                        fontWeight: FontWeight.bold,
                      ),
                      textAlign: TextAlign.center,
                    ),
                  ),

                // --- Botão de Login ---
                SizedBox(
                  height: 50,
                  child: ElevatedButton(
                    // Se estiver carregando, mostra o spinner, senão, o texto.
                    child: isLoading
                        ? const CircularProgressIndicator(
                            valueColor:
                                AlwaysStoppedAnimation<Color>(Colors.white),
                          )
                        : const Text(
                            'ENTRAR',
                            style: TextStyle(fontSize: 18),
                          ),
                    onPressed: isLoading ? null : () => _onLoginPressed(context),
                  ),
                ),
                const SizedBox(height: 16),

                // --- Botão de Registro ---
                TextButton(
                  child: const Text('Não tem conta? Registre-se'),
                  onPressed: isLoading ? null : () => _onRegisterPressed(context),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}