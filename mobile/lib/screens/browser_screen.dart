import 'package:antibet_app/providers/advertorial_detector_provider.dart';
import 'package:antibet_app/widgets/advertorial_warning_card.dart';
import 'package:flutter/material.dart';
import 'package:flutter_inappwebview/flutter_inappwebview.dart';
import 'package:provider/provider.dart';

// (OBS: Assumindo que este arquivo já existe e contém um InAppWebView)

class BrowserScreen extends StatefulWidget {
  // Rota ou configuração existente
  const BrowserScreen({Key? key}) : super(key: key);

  @override
  _BrowserScreenState createState() => _BrowserScreenState();
}

class _BrowserScreenState extends State<BrowserScreen> {
  InAppWebViewController? _webViewController;
  final String _initialUrl = "https://www.google.com"; // URL inicial exemplo

  // ... (Outras variáveis de estado existentes, como _searchController, etc.)

  @override
  Widget build(BuildContext context) {
    // O provider é lido aqui, mas não é escutado (read vs watch)
    // As chamadas de disparo (onLoadStop/onLoadStart) usam context.read
    // O AdvertorialWarningCard (dentro do Column) usa context.watch (via Consumer)
    
    return Scaffold(
      appBar: _buildAppBar(), // (AppBar existente)
      body: Stack(
        children: [
          // 1. O Navegador Web
          InAppWebView(
            initialUrlRequest: URLRequest(url: Uri.parse(_initialUrl)),
            onWebViewCreated: (controller) {
              _webViewController = controller;
            },
            
            onLoadStart: (controller, url) {
              // Limpa o card de aviso anterior ao iniciar uma nova navegação
              try {
                context.read<AdvertorialDetectorProvider>().clearAnalysis();
              } catch (e) {
                debugPrint("Erro ao limpar provider (onLoadStart): $e");
              }
              // ... (Atualizar UI da barra de endereço, etc.)
            },
            
            onLoadStop: (controller, url) async {
              // Página terminou de carregar. Hora de disparar a análise.
              if (url != null) {
                // 1. Pega o conteúdo de texto da página via JavaScript
                String? content;
                try {
                  content = await controller.evaluateJavascript(
                    source: "document.body.innerText"
                  ) as String?;
                } catch (e) {
                  debugPrint("Erro ao injetar JS para obter innerText: $e");
                  content = ""; // Continua mesmo sem conteúdo
                }

                // 2. Dispara o provider (sem escutar)
                // O Consumer (no WarningCard) irá reagir à mudança.
                if (mounted) {
                  await context.read<AdvertorialDetectorProvider>().checkUrl(
                        url.toString(),
                        content ?? "", // Garante que não é nulo
                      );
                }
              }
              // ... (Parar indicador de progresso, etc.)
            },
            // ... (Outras configurações existentes: onProgressChanged, etc.)
          ),

          // 2. O Card de Aviso (UI do Card 3)
          // Fica no topo do Stack, sobrepondo o InAppWebView
          const Positioned(
            top: 0,
            left: 0,
            right: 0,
            child: AdvertorialWarningCard(),
          ),
        ],
      ),
      // ... (Restante do Scaffold, se houver, como BottomNavigationBar)
    );
  }

  // --- Widgets existentes (exemplo) ---
  AppBar _buildAppBar() {
    return AppBar(
      title: const Text("AntiBet Browser"),
      // ... (Ações existentes, barra de endereço, etc.)
    );
  }

  // ... (Outros métodos existentes)
}