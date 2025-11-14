// mobile/lib/features/user/screens/user_profile_screen.dart

import 'package:antibet/features/auth/notifiers/auth_notifier.dart';
import 'package:antibet/features/user/models/user_model.dart';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart'; 

class UserProfileScreen extends StatelessWidget {
  const UserProfileScreen({super.key});

  @override
  Widget build(BuildContext context) {
    // Escuta as mudanças no AuthNotifier
    final authNotifier = context.watch<AuthNotifier>();
    final user = authNotifier.user;

    return Scaffold(
      appBar: AppBar(
        title: const Text('Meu Perfil'),
        centerTitle: true,
      ),
      body: authNotifier.isLoading
          ? const Center(child: CircularProgressIndicator())
          : user == null
              ? const Center(child: Text('Erro: Dados do usuário não carregados.'))
              : _buildProfileContent(context, authNotifier, user),
    );
  }

  Widget _buildProfileContent(BuildContext context, AuthNotifier notifier, UserModel user) {
    return SingleChildScrollView(
      padding: const EdgeInsets.all(24.0),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Center(
            child: Column(
              children: [
                const CircleAvatar(
                  radius: 40,
                  child: Icon(Icons.person, size: 40),
                ),
                const SizedBox(height: 8),
                Text(
                  user.name ?? 'Usuário AntiBet',
                  style: Theme.of(context).textTheme.headlineSmall?.copyWith(fontWeight: FontWeight.bold),
                ),
                Text(
                  user.email,
                  style: Theme.of(context).textTheme.bodyLarge?.copyWith(color: Colors.grey.shade600),
                ),
                const SizedBox(height: 20),
                _buildPremiumStatusCard(context, user.isPremiumActive),
              ],
            ),
          ),
          
          const SizedBox(height: 30),
          _buildInfoSection(context, Icons.email, 'Email', user.email),
          _buildInfoSection(context, Icons.currency_exchange, 'Moeda Padrão', user.currency ?? 'BRL (Padrão)'),
          
          const Divider(height: 40),
          
          // Ação Principal: Atualizar Perfil
          ListTile(
            leading: const Icon(Icons.edit, color: Colors.blue),
            title: const Text('Editar Dados de Perfil'),
            trailing: const Icon(Icons.chevron_right),
            onTap: () => _showEditProfileDialog(context, notifier, user),
          ),
          
          // Ação Secundária: Configurações/Ajuda (Placeholder)
          ListTile(
            leading: const Icon(Icons.settings, color: Colors.grey),
            title: const Text('Configurações do Aplicativo'),
            trailing: const Icon(Icons.chevron_right),
            onTap: () { /* TODO: Navegar para Configurações */ },
          ),
          
          const Divider(height: 40),

          // Ação Crítica: Logout
          Center(
            child: ElevatedButton.icon(
              onPressed: () => notifier.logout(),
              icon: const Icon(Icons.logout),
              label: const Text('Sair da Conta'),
              style: ElevatedButton.styleFrom(
                backgroundColor: Colors.red,
                foregroundColor: Colors.white,
                padding: const EdgeInsets.symmetric(horizontal: 30, vertical: 15),
              ),
            ),
          ),
        ],
      ),
    );
  }
  
  Widget _buildPremiumStatusCard(BuildContext context, bool isPremium) {
    final color = isPremium ? Colors.yellow.shade800 : Colors.blue.shade700;
    final icon = isPremium ? Icons.star : Icons.workspace_premium;
    final text = isPremium ? 'Assinatura Premium Ativa' : 'Plano Básico (Free Tier)';

    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
      decoration: BoxDecoration(
        color: color.withOpacity(0.1),
        borderRadius: BorderRadius.circular(8),
        border: Border.all(color: color, width: 1.5),
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          Icon(icon, color: color, size: 20),
          const SizedBox(width: 8),
          Text(
            text,
            style: TextStyle(color: color, fontWeight: FontWeight.bold),
          ),
        ],
      ),
    );
  }
  
  Widget _buildInfoSection(BuildContext context, IconData icon, String title, String value) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 8.0),
      child: Row(
        children: [
          Icon(icon, color: Colors.blue.shade700),
          const SizedBox(width: 16),
          Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(title, style: Theme.of(context).textTheme.bodySmall),
              Text(value, style: Theme.of(context).textTheme.titleMedium),
            ],
          ),
        ],
      ),
    );
  }
  
  void _showEditProfileDialog(BuildContext context, AuthNotifier notifier, UserModel user) {
    final nameController = TextEditingController(text: user.name);
    final currencyController = TextEditingController(text: user.currency);

    showDialog(
      context: context,
      builder: (ctx) => AlertDialog(
        title: const Text('Editar Perfil'),
        content: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            TextField(
              controller: nameController,
              decoration: const InputDecoration(labelText: 'Nome'),
            ),
            TextField(
              controller: currencyController,
              decoration: const InputDecoration(labelText: 'Moeda Padrão (Ex: BRL)'),
            ),
            // TODO: Adicionar campos de senha (requer validação no Backend: senha atual + nova senha)
          ],
        ),
        actions: [
          TextButton(onPressed: () => Navigator.of(ctx).pop(), child: const Text('Cancelar')),
          TextButton(
            onPressed: () async {
              // Simulação de atualização (em produção, chamaria UserService.updateProfile)
              final updatedUser = user.copyWith(
                name: ValueGetter(() => nameController.text.trim().isEmpty ? null : nameController.text.trim()),
                currency: ValueGetter(() => currencyController.text.trim().isEmpty ? null : currencyController.text.trim()),
              );
              
              // 1. Atualiza localmente via Notifier
              notifier.updateLocalProfile(updatedUser);
              
              // 2. Chama a API para persistir (Simulação)
              // await notifier.userService.updateProfile(updatedUser); 
              
              Navigator.of(ctx).pop();
            },
            child: const Text('Salvar'),
          ),
        ],
      ),
    );
  }
}