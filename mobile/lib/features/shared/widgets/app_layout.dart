import 'package:flutter/material.dart';

/// Um widget de layout base reutilizável para envolver a maioria das telas
/// do aplicativo que precisam de uma estrutura padrão (AppBar, Safe Area, Background).
class AppLayout extends StatelessWidget {
  final Widget child;
  final Widget? appBar;
  final bool useSafeArea;
  final bool isLoading;

  const AppLayout({
    super.key,
    required this.child,
    this.appBar,
    this.useSafeArea = true,
    this.isLoading = false,
  });

  @override
  Widget build(BuildContext context) {
    Widget content = Padding(
      padding: const EdgeInsets.symmetric(horizontal: 16.0),
      child: child,
    );

    // Envolve o conteúdo com Safe Area se solicitado
    if (useSafeArea) {
      content = SafeArea(child: content);
    }

    // Retorna a estrutura final (Scaffold)
    return Scaffold(
      appBar: appBar != null ? (appBar as PreferredSizeWidget) : null,
      body: Stack(
        children: [
          content,
          // Indicador de Loading Global (Opcional)
          if (isLoading)
            Container(
              color: Colors.black.withOpacity(0.3),
              child: const Center(
                child: CircularProgressIndicator(),
              ),
            ),
        ],
      ),
    );
  }
}