import 'package:antibet_mobile/models/user_model.dart';
import 'package:antibet_mobile/notifiers/user_profile_notifier.dart';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

/// Tela de Perfil do Usuário.
///
/// Permite ao usuário visualizar e editar suas informações de perfil,
/// como nome e e-mail.
class ProfileScreen extends StatefulWidget {
  const ProfileScreen({super.key});

  @override
  State<ProfileScreen> createState() => _ProfileScreenState();
}

class _ProfileScreenState extends State<ProfileScreen> {
  final _formKey = GlobalKey<FormState>();
  late TextEditingController _nameController;
  late TextEditingController _emailController;

  @override
  void initState() {
    super.initState();
    // Pega o usuário atual do Notifier (read, pois estamos no initState)
    final currentUser = context.read<UserProfileNotifier>().user;

    // Inicializa os controladores com os dados existentes
    _nameController = TextEditingController(text: currentUser?.name ?? '');
    _emailController = TextEditingController(text: currentUser?.email ?? '');
  }

  @override
  void dispose() {
    _nameController.dispose();
    _emailController.dispose();
    super.dispose();
  }

  /// Tenta salvar as alterações do perfil.
  Future<void> _onSavePressed(BuildContext context) async {
    if (!(_formKey.currentState?.validate() ?? false)) {
      return;
    }

    final notifier = context.read<UserProfileNotifier>();
    final currentUser = notifier.user;

    if (currentUser == null) return; // Não deve acontecer se logado

    // Cria o novo objeto UserModel com os dados atualizados (imutabilidade)
    final updatedUser = currentUser.copyWith(
      name: _nameController.text,
      email: _emailController.text,
    );

    // Chama a ação no Notifier
    final success = await notifier.updateProfile(updatedUser);

    if (mounted && success) {
      // Feedback de sucesso
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('Perfil atualizado com sucesso!'),
          backgroundColor: Colors.green,
        ),
      );
      // Opcional: fechar a tela
      // Navigator.of(context).pop(); 
    }
  }

  @override
  Widget build(BuildContext context) {
    // Observa o Notifier para estados de loading e erro
    final notifierState = context.watch<UserProfileNotifier>();
    final isLoading = notifierState.isLoading;
    final errorMessage = notifierState.errorMessage;

    return Scaffold(
      appBar: AppBar(
        title: const Text('Meu Perfil'),
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(24.0),
        child: Form(
          key: _formKey,
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: [
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

              // --- Botão de Salvar ---
              SizedBox(
                height: 50,
                child: ElevatedButton(
                  onPressed: isLoading ? null : () => _onSavePressed(context),
                  child: isLoading
                      ? const CircularProgressIndicator(
                          valueColor:
                              AlwaysStoppedAnimation<Color>(Colors.white),
                        )
                      : const Text(
                          'SALVAR ALTERAÇÕES',
                          style: TextStyle(fontSize: 18),
                        ),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}