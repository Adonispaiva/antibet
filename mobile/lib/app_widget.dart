import 'package:flutter/material.dart';
import 'package:get_it/get_it.dart';
import 'package:antibet/di/injection_container.dart'; 
import 'package:antibet/core/routing/app_router.dart'; 
import 'package:antibet/core/styles/app_theme.dart'; // Importação do tema finalizado

// Inicialização da instância global do Service Locator (GetIt)
final getIt = GetIt.instance;

/// Widget raiz da aplicação.
/// Define as configurações globais (tema, roteamento) e inicializa o acesso
/// aos serviços e provedores injetados.
class AppWidget extends StatelessWidget {
  const AppWidget({super.key});

  @override
  Widget build(BuildContext context) {
    // Assumimos que o AppRouter é registrado no GetIt
    final appRouter = getIt<AppRouter>();

    return MaterialApp.router(
      // Configuration Geral
      title: 'AntiBet',
      debugShowCheckedModeBanner: false,

      // --- Injeção do Tema Global ---
      theme: AppTheme.lightTheme, 

      // --- Configuração de Roteamento Declarativo ---
      routerConfig: appRouter.config(), 
    );
  }
}