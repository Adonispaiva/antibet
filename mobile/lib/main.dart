// mobile/lib/main.dart

import 'package:antibet/core/routing/app_router.dart';
import 'package:antibet/core/routing/auth_wrapper.dart';
import 'package:antibet/features/auth/notifiers/auth_notifier.dart';
import 'package:antibet/providers/app_providers.dart'; // Importação do novo container de DI
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

void main() async {
  // Garante que o binding do Flutter esteja inicializado para que os plugins nativos funcionem.
  WidgetsFlutterBinding.ensureInitialized();
  
  // TODO: (Fase 5) Inicializar Firebase e Notificações Push aqui.

  // O StorageService (shared_preferences) é inicializado no providers.dart (lazy: false).
  
  runApp(const AntiBetApp());
}

class AntiBetApp extends StatelessWidget {
  const AntiBetApp({super.key});

  @override
  Widget build(BuildContext context) {
    // MultiProvider é o coração do DI container, usando a lista corrigida de providers.
    return MultiProvider(
      providers: globalProviders, // Lista de providers vindo de app_providers.dart
      child: Consumer<AuthNotifier>(
        builder: (context, authNotifier, child) {
          return MaterialApp.router(
            title: 'AntiBet - Inovexa Software',
            theme: ThemeData(
              primarySwatch: Colors.blue,
              visualDensity: VisualDensity.adaptivePlatformDensity,
            ),
            routerConfig: AppRouter.router,
            
            // O AuthWrapper deve ser o widget raiz para gerenciar a navegação inicial
            // dependendo do estado de autenticação (Splash -> Login ou Home).
            builder: (context, child) => AuthWrapper(child: child!),
          );
        },
      ),
    );
  }
}