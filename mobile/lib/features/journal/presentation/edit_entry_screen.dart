import 'package:antibet/features/journal/models/journal_entry_model.dart';
import 'package:antibet/features/journal/providers/journal_provider.dart';
import 'package:antibet/utils/widgets/custom_button.dart';
import 'package:antibet/utils/widgets/custom_textfield.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:intl/intl.dart';

/// [EditEntryScreen] é a tela responsável por permitir ao usuário
/// editar uma aposta (Journal Entry) existente.
class EditEntryScreen extends ConsumerStatefulWidget {
  const EditEntryScreen({
    super.key,
    required this.entry,
  });

  final JournalEntryModel entry;

  @override
  ConsumerState<EditEntryScreen> createState() => _EditEntryScreenState();
}

class _EditEntryScreenState extends ConsumerState<EditEntryScreen> {
  final _formKey = GlobalKey<FormState>();
  final _descriptionController = TextEditingController();
  final _platformController = TextEditingController();
  final _investmentController = TextEditingController();
  final _oddsController = TextEditingController();
  final _returnAmountController = TextEditingController();

  BetResult? _selectedResult;

  @override
  void initState() {
    super.initState();
    // Preenche os controladores com os dados da entrada existente
    _descriptionController.text = widget.entry.description;
    _platformController.text = widget.entry.platform;
    _investmentController.text = widget.entry.investment.toString();
    _oddsController.text = widget.entry.odds.toString();
    _returnAmountController.text = widget.entry.returnAmount.toString();
    _selectedResult = widget.entry.result;
  }

  @override
  void dispose() {
    _descriptionController.dispose();
    _platformController.dispose();
    _investmentController.dispose();
    _oddsController.dispose();
    _returnAmountController.dispose();
    super.dispose();
  }

  /// Converte a string de resultado (enum name) para uma string amigável.
  String _getFriendlyResultName(BetResult result) {
    switch (result) {
      case BetResult.win:
        return 'Ganho Total';
      case BetResult.loss:
        return 'Perda Total';
      case BetResult.pending:
        return 'Pendente';
      case BetResult.halfWin:
        return 'Meio Ganho';
      case BetResult.halfLoss:
        return 'Meia Perda';
    }
  }

  /// Submete o formulário, atualizando a entrada.
  void _submitEdit() async {
    if (!(_formKey.currentState?.validate() ?? false)) return;
    if (_selectedResult == null) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Por favor, selecione o resultado da aposta.')),
      );
      return;
    }

    // Cria o modelo de entrada atualizado
    final updatedEntry = widget.entry.copyWith(
      investment: double.tryParse(_investmentController.text),
      odds: double.tryParse(_oddsController.text),
      returnAmount: double.tryParse(_returnAmountController.text),
      result: _selectedResult,
      platform: _platformController.text.trim(),
      description: _descriptionController.text.trim(),
    );

    // 1. Chama a atualização da entrada (o provider faz a chamada à API)
    await ref.read(journalProvider.notifier).updateEntry(updatedEntry);

    // 2. Verifica se a operação foi bem-sucedida (o estado mudou para Loaded)
    final currentState = ref.read(journalProvider);
    if (currentState is JournalLoaded) {
      // Navega de volta para a JournalScreen
      if (mounted) Navigator.of(context).pop();
    }
  }

  /// Exibe um diálogo de confirmação e, se confirmado, deleta a entrada.
  void _deleteEntry() async {
    final confirmed = await showDialog<bool>(
      context: context,
      builder: (ctx) => AlertDialog(
        title: const Text('Confirmar Exclusão'),
        content: const Text('Tem certeza de que deseja deletar esta aposta? Esta ação não pode ser desfeita.'),
        actions: [
          TextButton(
            onPressed: () => Navigator.of(ctx).pop(false),
            child: const Text('Cancelar'),
          ),
          TextButton(
            onPressed: () => Navigator.of(ctx).pop(true),
            child: Text(
              'Deletar',
              style: TextStyle(color: Theme.of(context).colorScheme.error),
            ),
          ),
        ],
      ),
    );

    if (confirmed == true) {
      // Deleta a entrada
      await ref.read(journalProvider.notifier).deleteEntry(widget.entry.id);
      
      // Verifica se a operação foi bem-sucedida (o estado mudou para Loaded)
      final currentState = ref.read(journalProvider);
      if (currentState is JournalLoaded) {
        if (mounted) Navigator.of(context).pop();
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);

    // Escuta o estado para side-effects (SnackBar em caso de erro)
    ref.listen<JournalState>(journalProvider, (previous, next) {
      if (next is JournalError) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text(next.message),
            backgroundColor: theme.colorScheme.error,
          ),
        );
      }
    });

    final isLoading = ref.watch(journalProvider) is JournalLoading;

    return Scaffold(
      appBar: AppBar(
        title: const Text('Editar Aposta'),
        backgroundColor: theme.scaffoldBackgroundColor,
      ),
      body: Center(
        child: SingleChildScrollView(
          padding: const EdgeInsets.all(16.0),
          child: Form(
            key: _formKey,
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.stretch,
              children: [
                // Campos do Formulário
                CustomTextField(
                  controller: _descriptionController,
                  labelText: 'Descrição (Ex: Futebol - Vitória Time A)',
                  icon: Icons.title,
                  validator: (v) => v!.isEmpty ? 'Obrigatório.' : null,
                ),
                const SizedBox(height: 16),
                
                CustomTextField(
                  controller: _platformController,
                  labelText: 'Plataforma (Ex: Bet365)',
                  icon: Icons.public,
                  validator: (v) => v!.isEmpty ? 'Obrigatório.' : null,
                ),
                const SizedBox(height: 16),
                
                CustomTextField(
                  controller: _investmentController,
                  labelText: 'Investimento (R\$)',
                  icon: Icons.money,
                  keyboardType: TextInputType.number,
                  validator: (v) => v!.isEmpty ? 'Obrigatório.' : null,
                ),
                const SizedBox(height: 16),
                
                CustomTextField(
                  controller: _oddsController,
                  labelText: 'ODDS (Ex: 1.85)',
                  icon: Icons.numbers,
                  keyboardType: TextInputType.number,
                  validator: (v) => v!.isEmpty ? 'Obrigatório.' : null,
                ),
                const SizedBox(height: 16),
                
                CustomTextField(
                  controller: _returnAmountController,
                  labelText: 'Valor de Retorno (R\$)',
                  icon: Icons.attach_money,
                  keyboardType: TextInputType.number,
                  validator: (v) => v!.isEmpty ? 'Obrigatório.' : null,
                ),
                const SizedBox(height: 24),
                
                // Resultado (Dropdown)
                InputDecorator(
                  decoration: InputDecoration(
                    labelText: 'Resultado da Aposta',
                    border: OutlineInputBorder(
                      borderRadius: BorderRadius.circular(12.0),
                    ),
                    prefixIcon: Icon(Icons.check_circle_outline, color: theme.colorScheme.primary),
                  ),
                  child: DropdownButtonHideUnderline(
                    child: DropdownButton<BetResult>(
                      value: _selectedResult,
                      isDense: true,
                      dropdownColor: theme.colorScheme.surface,
                      style: const TextStyle(color: Colors.white),
                      hint: const Text('Selecione o resultado'),
                      items: BetResult.values.map((BetResult result) {
                        return DropdownMenuItem<BetResult>(
                          value: result,
                          child: Text(_getFriendlyResultName(result)),
                        );
                      }).toList(),
                      onChanged: isLoading ? null : (BetResult? newValue) {
                        setState(() {
                          _selectedResult = newValue;
                        });
                      },
                    ),
                  ),
                ),
                const SizedBox(height: 40),
                
                // Botão de Submissão (Atualizar)
                CustomButton(
                  key: const ValueKey('saveEntryButton'),
                  text: 'Salvar Alterações',
                  isLoading: isLoading,
                  onPressed: isLoading ? null : _submitEdit,
                ),
                const SizedBox(height: 24),

                // Botão de Excluir
                TextButton.icon(
                  key: const ValueKey('deleteEntryButton'),
                  icon: Icon(Icons.delete_forever, color: theme.colorScheme.error),
                  label: Text(
                    'Deletar Aposta',
                    style: TextStyle(color: theme.colorScheme.error),
                  ),
                  onPressed: isLoading ? null : _deleteEntry,
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}