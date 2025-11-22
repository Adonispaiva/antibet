import 'package.antibet_app/models/advertorial_detector_models.dart';
import 'package:antibet_app/providers/advertorial_detector_provider.dart';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

/// O Widget principal do Card 3.
///
/// Exibe o resultado da análise de advertorial, escutando
/// as mudanças do [AdvertorialDetectorProvider].
class AdvertorialWarningCard extends StatelessWidget {
  const AdvertorialWarningCard({super.key});

  @override
  Widget build(BuildContext context) {
    // Consome o provider para reagir às mudanças de estado
    return Consumer<AdvertorialDetectorProvider>(
      builder: (context, provider, child) {
        // 1. Estado de Carregamento
        if (provider.isLoading) {
          return const Center(
            child: Padding(
              padding: EdgeInsets.all(24.0),
              child: CircularProgressIndicator(),
            ),
          );
        }

        // 2. Estado de Erro
        if (provider.hasError) {
          return _buildErrorCard(context, provider.errorMessage!);
        }

        // 3. Estado de Sucesso (Resultado disponível)
        if (provider.hasResult) {
          // O provider tem um resultado, mas a API pode não ter
          // detectado nada (ex: SPA autorizado).
          final result = provider.analysisResult!;
          
          // A UI só deve aparecer se for advertorial OU 
          // se for um SPA não autorizado.
          // Se for um SPA autorizado (is_authorized = true), não mostramos nada.
          if (result.spa.isAuthorized) {
            return const SizedBox.shrink(); // Não é advertorial, não mostre nada.
          }
          
          // Se for advertorial (is_advertorial = true) OU
          // se for um SPA não autorizado (!is_authorized), mostramos o card.
          // O conteúdo educativo (result.education) é o nosso foco (Card 3).
          return _buildWarningCard(context, result);
        }

        // 4. Estado Inicial (Sem resultado, sem erro, sem loading)
        // Não exibe nada até que a verificação seja disparada.
        return const SizedBox.shrink();
      },
    );
  }

  /// Constrói o widget para o estado de erro.
  Widget _buildErrorCard(BuildContext context, String errorMessage) {
    final theme = Theme.of(context);
    return Card(
      elevation: 4,
      margin: const EdgeInsets.symmetric(vertical: 8, horizontal: 16),
      color: theme.colorScheme.errorContainer,
      child: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Row(
          children: [
            Icon(
              Icons.error_outline,
              color: theme.colorScheme.onErrorContainer,
              size: 28,
            ),
            const SizedBox(width: 16),
            Expanded(
              child: Text(
                errorMessage,
                style: theme.textTheme.bodyMedium?.copyWith(
                  color: theme.colorScheme.onErrorContainer,
                  fontWeight: FontWeight.bold,
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }

  /// Constrói o widget principal de aviso (Resultado do Card 3)
  Widget _buildWarningCard(BuildContext context, AdvertorialDetectorResponse result) {
    final theme = Theme.of(context);
    final education = result.education; // Foco do Card 3

    // Determina a cor e o ícone com base na prioridade do Card 3
    final Color cardColor;
    final Color contentColor;
    final IconData iconData;

    if (education.priority >= 2) { // Alta prioridade (Advertorial)
      cardColor = theme.colorScheme.errorContainer;
      contentColor = theme.colorScheme.onErrorContainer;
      iconData = Icons.warning_amber_rounded;
    } else { // Prioridade baixa/média (SPA não autorizado)
      cardColor = theme.colorScheme.tertiaryContainer;
      contentColor = theme.colorScheme.onTertiaryContainer;
      iconData = Icons.info_outline_rounded;
    }

    return Card(
      elevation: 4,
      margin: const EdgeInsets.symmetric(vertical: 8, horizontal: 16),
      color: cardColor,
      child: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // 1. Cabeçalho (Título e Ícone)
            Row(
              children: [
                Icon(
                  iconData,
                  color: contentColor,
                  size: 28,
                ),
                const SizedBox(width: 12),
                Expanded(
                  child: Text(
                    education.cardTitle, // Título do Card 3
                    style: theme.textTheme.titleMedium?.copyWith(
                      color: contentColor,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                ),
              ],
            ),
            const SizedBox(height: 12),
            
            // 2. Corpo (Descrição)
            Text(
              education.cardBody, // Corpo do Card 3
              style: theme.textTheme.bodyMedium?.copyWith(
                color: contentColor,
              ),
            ),
            
            // 3. (Opcional) Detalhes técnicos para depuração (Cards 1 e 2)
            // Podemos remover isso na produção.
            if (result.detector.isAdvertorial) ...[
              const Divider(height: 24),
              Text(
                "Info (Card 1): Pontuação ${result.detector.score}. Gatilhos: ${result.detector.matchedKeywords.join(', ')}",
                style: theme.textTheme.bodySmall?.copyWith(
                  color: contentColor.withOpacity(0.8),
                ),
              ),
            ]
          ],
        ),
      ),
    );
  }
}