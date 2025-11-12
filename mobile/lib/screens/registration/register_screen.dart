import 'package:antibet_mobile/notifiers/auth_notifier.dart';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

/// Tela de Registro de Novo Usuário.
///
/// Esta tela é 'Stateless' e consome o [AuthNotifier] para
/// gerenciar o estado de registro, exibindo feedback (loading/erro)
/// e tratando a submissão do formulário.
class RegisterScreen extends StatelessWidget {
  const RegisterScreen({super.key});

  // Controladores para os campos de texto e chave do formulário
  static final _nameController = TextEditingController();
  static final _emailController = TextEditingController();
  static final _passwordController = TextEditingController();
  static final _formKey = GlobalKey<FormState>();

  /// Função de callback para tentar o registro.
  /// Usamos 'context.read' aqui pois estamos disparando uma *ação*.
  void _onRegisterPressed(BuildContext context) async {
    // 1. Valida o formulário
    if (!(_formKey.currentState?.validate() ?? false)) {
      return;
    }

    // 2. Chama a *ação* no Notifier
    final authNotifier = context.read<AuthNotifier>();
    await authNotifier.register(
      _nameController.text,
      _emailController.text,
      _passwordController.text,
    );

    // 3. O 'home' no main.dart (Consumer) tratará a navegação
    // para a HomeScreen se o registro for bem-sucedido.
    // Se falhar, o 'watch' abaixo exibirá a mensagem de erro.
  }

  @override
  Widget build(BuildContext context) {
    // Usamos 'context.watch' para *observar* mudanças de estado.
    final authStatus = context.watch<AuthNotifier>().status;
    final errorMessage = context.watch<AuthNotifier>().errorMessage;
    final isLoading = authStatus == AuthStatus.loading;

    return Scaffold(
      appBar: AppBar(
        title: const Text('Criar Conta'),
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
                const Icon(Icons.person_add_alt_1_outlined, size: 80),
                const SizedBox(height: 24),

                // --- Campo de Nome ---
                TextFormField(
                  controller: _nameController,
                  keyboardType: TextInputType.name,
                  decoration: const InputDecoration(
                    labelText: 'Nome Completo',
                    border: OutlineInputBorder(),
                    prefixIcon: Icon(Icons.person_outline),
                  ),
                  validator: (value) =>
                      (value == null || value.trim().length < 3)
                          ? 'Nome deve ter no mínimo 3 caracteres.'
                          : null,
                  enabled: !isLoading,
                ),
                const SizedBox(height: 16),

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
                  enabled: !isLoading,
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
                  enabled: !isLoading,
                ),
                const SizedBox(height: 24),

                // --- Feedback de Erro ---
                if (errorMessage != null && !isLoading)
                  Padding(
                    padding: const EdgeInsets.only(bottom: 16.0),
                    child: Text(
                      errorMessage, // Ex: "E-mail já cadastrado."
                      style: TextStyle(
                        color: Theme.of(context).colorScheme.error,
                        fontWeight: FontWeight.bold,
                      ),
                      textAlign: TextAlign.center,
                    ),
                  ),

                // --- Botão de Registro ---
                SizedBox(
                  height: 50,
                  child: ElevatedButton(
                    child: isLoading
                        ? const CircularProgressIndicator(
                            valueColor:
                                AlwaysStoppedAnimation<Color>(Colors.white),
                          )
                        : const Text(
                            'CRIAR CONTA',
                            style: TextStyle(fontSize: 18),
                          ),
                    onPressed:
                        isLoading ? null : () => _onRegisterPressed(context),
                  ),
                ),
                const SizedBox(height: 16),

                // --- Botão de Voltar (Login) ---
                TextButton(
                  child: const Text('Já tem conta? Fazer Login'),
                  onPressed:
                      isLoading ? null : () => Navigator.of(context).pop(),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}