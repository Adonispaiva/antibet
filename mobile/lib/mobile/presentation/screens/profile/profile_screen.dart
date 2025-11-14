import 'package:antibet/core/notifiers/auth_notifier.dart';
import 'package:antibet/core/notifiers/user_profile_notifier.dart';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

class ProfileScreen extends StatelessWidget {
  const ProfileScreen({super.key});

  @override
  Widget build(BuildContext context) {
    final userProfileNotifier = context.watch<UserProfileNotifier>();
    final authNotifier = context.read<AuthNotifier>();
    final userProfile = userProfileNotifier.userProfile;
    final isLoading = userProfileNotifier.isLoading;

    return Scaffold(
      appBar: AppBar(
        title: const Text('Profile'),
      ),
      body: isLoading
          ? const Center(child: CircularProgressIndicator())
          : SingleChildScrollView(
              padding: const EdgeInsets.all(20.0),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.center,
                children: [
                  // Ícone/Avatar do Usuário
                  const CircleAvatar(
                    radius: 50,
                    child: Icon(Icons.person, size: 50),
                  ),
                  const SizedBox(height: 16),
                  
                  // Nome e Email do Usuário
                  Text(
                    userProfile?.name ?? 'Orion Software Architect',
                    style: Theme.of(context).textTheme.headlineSmall?.copyWith(fontWeight: FontWeight.bold),
                  ),
                  const SizedBox(height: 4),
                  Text(
                    userProfile?.email ?? 'orion@inovexa.com',
                    style: Theme.of(context).textTheme.titleMedium,
                  ),
                  const SizedBox(height: 30),

                  // Cartão de Informações
                  Card(
                    elevation: 1,
                    child: Padding(
                      padding: const EdgeInsets.all(16.0),
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          _buildProfileInfoRow(context, Icons.calendar_today, 'Member Since', userProfile?.memberSince.toString().split(' ')[0] ?? '2025-01-01'),
                          const Divider(),
                          _buildProfileInfoRow(context, Icons.track_changes, 'Total Strategies', '5'), // Mocked data
                          const Divider(),
                          _buildProfileInfoRow(context, Icons.history, 'Total Bets Logged', '250'), // Mocked data
                        ],
                      ),
                    ),
                  ),
                  const SizedBox(height: 30),
                  
                  // Botão de Logout
                  SizedBox(
                    width: double.infinity,
                    child: ElevatedButton.icon(
                      onPressed: () {
                        // Chama a lógica de logout no Notifier
                        authNotifier.logout(context);
                      },
                      icon: const Icon(Icons.logout),
                      label: const Text('Logout'),
                      style: ElevatedButton.styleFrom(
                        backgroundColor: Colors.red,
                        foregroundColor: Colors.white,
                        padding: const EdgeInsets.symmetric(vertical: 15),
                      ),
                    ),
                  ),
                ],
              ),
            ),
    );
  }

  Widget _buildProfileInfoRow(BuildContext context, IconData icon, String label, String value) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 8.0),
      child: Row(
        children: [
          Icon(icon, color: Theme.of(context).primaryColor),
          const SizedBox(width: 12),
          Expanded(
            child: Text(
              label,
              style: const TextStyle(fontWeight: FontWeight.w600),
            ),
          ),
          Text(value),
        ],
      ),
    );
  }
}