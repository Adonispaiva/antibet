import 'package:flutter/material.dart';
import 'package:auto_route/auto_route.dart';
import 'package:get_it/get_it.dart';
import 'package:intl/intl.dart';

import 'package:antibet/features/journal/models/journal_entry_model.dart';
import 'package:antibet/features/journal/providers/journal_provider.dart';
import 'package:antibet/features/shared/widgets/app_layout.dart'; // Importação do AppLayout
import 'package:antibet/features/shared/widgets/action_separator.dart'; // Importação do ActionSeparator


// O decorator @RoutePage é exigido pelo auto_route
@RoutePage()
class JournalEntryDetailScreen extends StatelessWidget {
  // O ID da entrada é um parâmetro obrigatório na rota
  final String entryId; 

  const JournalEntryDetailScreen({super.key, required this.entryId});

  @override
  Widget build(BuildContext context) {
    final JournalProvider journalProvider = GetIt.I<JournalProvider>();
    
    // Procura a entrada na lista carregada no Provider
    // Usamos ListenableBuilder para reagir a mudanças no estado (ex: após deleção ou atualização)
    return ListenableBuilder(
      listenable: journalProvider,
      builder: (context, child) {
        final entry = journalProvider.entries.firstWhere(
          (e) => e.id == entryId,
          // Fallback simples (em uma aplicação real, faríamos um fetch por ID)
          orElse: () => throw Exception('Entrada do diário não encontrada.'), 
        ); 
        
        final currencyFormat = NumberFormat.currency(locale: 'pt_BR', symbol: 'R\$');
        final dateFormat = DateFormat('dd/MM/yyyy HH:mm');
        final isPositive = entry.pnl >= 0;

        return AppLayout( // Substitui o Scaffold principal
          appBar: AppBar(
            title: Text('${entry.instrument} - Detalhes'),
            actions: [
              // Botão de Editar
              IconButton(
                icon: const Icon(Icons.edit),
                onPressed: () {
                  // context.router.push(EditJournalEntryRoute(entry: entry)); // Rota futura
                },
              ),
              // Botão de Excluir
              IconButton(
                icon: const Icon(Icons.delete),
                onPressed: () => _confirmDelete(context, entryId, journalProvider),
              ),
            ],
          ),
          child: SingleChildScrollView(
            // Padding removido, agora está no AppLayout
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                const SizedBox(height: 24),

                // --- Resumo de P&L ---
                Center(
                  child: Text(
                    currencyFormat.format(entry.pnl),
                    style: TextStyle(
                      fontSize: 36,
                      fontWeight: FontWeight.bold,
                      color: isPositive ? Colors.green[700] : Colors.red[700],
                    ),
                  ),
                ),
                Center(
                  child: Text(
                    'Resultado Final (${entry.direction})',
                    style: Theme.of(context).textTheme.bodyLarge,
                  ),
                ),
                const ActionSeparator(), // Separador padronizado

                // --- Dados Principais ---
                _buildDetailRow(context, 'Ativo Negociado:', entry.instrument),
                _buildDetailRow(context, 'Estratégia ID:', entry.strategyId, isMonospace: true),
                
                const SizedBox(height: 20),
                _buildDetailRow(context, 'Preço de Entrada:', currencyFormat.format(entry.entryPrice)),
                _buildDetailRow(context, 'Preço de Saída:', currencyFormat.format(entry.exitPrice)),
                _buildDetailRow(context, 'Volume/Tamanho:', entry.volume.toString()),
                
                const SizedBox(height: 20),
                _buildDetailRow(context, 'Data de Entrada:', dateFormat.format(entry.entryDate)),
                _buildDetailRow(context, 'Data de Saída:', dateFormat.format(entry.exitDate)),
                
                const ActionSeparator(), // Separador padronizado

                // --- Notas e Lições ---
                Text('Notas do Trade:', style: Theme.of(context).textTheme.titleMedium),
                const SizedBox(height: 8),
                Container(
                  width: double.infinity,
                  padding: const EdgeInsets.all(12),
                  decoration: BoxDecoration(
                    color: Colors.grey[100],
                    borderRadius: BorderRadius.circular(8),
                  ),
                  child: Text(
                    entry.notes ?? 'Nenhuma nota registrada.',
                    style: Theme.of(context).textTheme.bodyMedium,
                  ),
                ),
                const SizedBox(height: 20),
              ],
            ),
          ),
        );
      },
    );
  }
  
  /// Widget utilitário para formatar uma linha de detalhe.
  Widget _buildDetailRow(BuildContext context, String label, String value, {bool isMonospace = false}) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 4.0),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          Text(label, style: Theme.of(context).textTheme.titleSmall),
          Text(
            value,
            style: isMonospace ? const TextStyle(fontFamily: 'monospace', fontWeight: FontWeight.w600) : Theme.of(context).textTheme.titleMedium,
          ),
        ],
      ),
    );
  }

  /// Exibe um diálogo de confirmação antes de excluir.
  void _confirmDelete(BuildContext context, String entryId, JournalProvider provider) {
    showDialog(
      context: context,
      builder: (ctx) => AlertDialog(
        title: const Text('Confirmar Exclusão'),
        content: const Text('Tem certeza de que deseja excluir permanentemente este lançamento do diário?'),
        actions: [
          TextButton(
            onPressed: () => context.router.pop(),
            child: const Text('Cancelar'),
          ),
          TextButton(
            onPressed: () async {
              context.router.pop(); // Fecha o diálogo
              await provider.deleteEntry(entryId); // Chama a exclusão
              context.router.pop(); // Retorna para a lista
            },
            child: const Text('Excluir', style: TextStyle(color: Colors.red)),
          ),
        ],
      ),
    );
  }
}