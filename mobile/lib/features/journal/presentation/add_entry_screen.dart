import 'package:antibet/features/journal/models/journal_entry_model.dart';
import 'package:antibet/features/journal/providers/journal_provider.dart';
import 'package:antibet/utils/widgets/custom_button.dart';
import 'package:antibet/utils/widgets/custom_textfield.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:intl/intl.dart';

/// [AddEntryScreen] é a tela responsável por permitir ao usuário
/// cadastrar uma nova aposta (Journal Entry).
class AddEntryScreen extends ConsumerStatefulWidget {
  const AddEntryScreen({super.key});

  @override
  ConsumerState<AddEntryScreen> createState() => _AddEntryScreenState();
}

class _AddEntryScreenState extends ConsumerState<AddEntryScreen> {
  final _formKey = GlobalKey<FormState>();
  final _descriptionController = TextEditingController();
  final _platformController = TextEditingController();
  final _investmentController = TextEditingController();
  final _oddsController = TextEditingController();
  final _returnAmountController = TextEditingController();

  BetResult? _selectedResult;

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

  /// Submete o formulário, criando a nova entrada.
  void _submitEntry() async {
    if (!(_formKey.currentState?.validate() ?? false)) return;
    if (_selectedResult == null) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Por favor, selecione o resultado da aposta.')),
      );
      return;
    }

    // Cria o modelo de entrada com os dados do formulário
    final newEntry = JournalEntryModel(
      // ATENÇÃO: ID e journalId serão definidos pela API
      id: '', 
      journalId: '', 
      investment: double.tryParse(_investmentController.text) ?? 0.0,
      odds: double.tryParse(_oddsController.text) ?? 0.0,
      returnAmount: double.tryParse(_returnAmountController.text) ?? 0.0,
      result: _selectedResult!,
      platform: _platformController.text.trim(),
      description: _descriptionController.text.trim(),
      createdAt: DateTime.now(), 
    );

    // 1. Chama a criação da entrada (o provider faz a chamada à API)
    await ref.read(journalProvider.notifier).createEntry(newEntry);
    
    // 2. Verifica se a operação foi bem-sucedida (o estado mudou para Loaded)
    final currentState = ref.read(journalProvider);
    if (currentState is JournalLoaded) {
      // Navega de volta para a JournalScreen
      if (mounted) Navigator.of(context).pop();
    }
    // Se o estado for JournalError, o ref.listen abaixo trata o SnackBar.
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
        title: const Text('Nova Aposta'),
        backgroundColor: theme.scaffoldBackgroundColor,
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(16.0),
        child: Form(
          key: _formKey,
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: [
              // Campo 1: Descrição
              CustomTextField(
                controller: _descriptionController,
                labelText: 'Descrição (Ex: Futebol - Vitória Time A)',
                icon: Icons.title,
                validator: (v) => v!.isEmpty ? 'Obrigatório.' : null,
              ),
              const SizedBox(height: 16),
              
              // Campo 2: Plataforma
              CustomTextField(
                controller: _platformController,
                labelText: 'Plataforma (Ex: Bet365)',
                icon: Icons.public,
                validator: (v) => v!.isEmpty ? 'Obrigatório.' : null,
              ),
              const SizedBox(height: 16),
              
              // Campo 3: Investimento
              CustomTextField(
                controller: _investmentController,
                labelText: 'Investimento (R\$)',
                icon: Icons.money,
                keyboardType: TextInputType.number,
                validator: (v) => v!.isEmpty ? 'Obrigatório.' : null,
              ),
              const SizedBox(height: 16),
              
              // Campo 4: ODDS
              CustomTextField(
                controller: _oddsController,
                labelText: 'ODDS (Ex: 1.85)',
                icon: Icons.numbers,
                keyboardType: TextInputType.number,
                validator: (v) => v!.isEmpty ? 'Obrigatório.' : null,
              ),
              const SizedBox(height: 16),
              
              // Campo 5: Retorno (apenas para resultados consolidados)
              CustomTextField(
                controller: _returnAmountController,
                labelText: 'Valor de Retorno (R\$)',
                icon: Icons.attach_money,
                keyboardType: TextInputType.number,
                validator: (v) => v!.isEmpty ? 'Obrigatório.' : null,
              ),
              const SizedBox(height: 24),
              
              // Campo 6: Resultado (Dropdown ou Radio Buttons)
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
                    onChanged: (BetResult? newValue) {
                      setState(() {
                        _selectedResult = newValue;
                      });
                    },
                  ),
                ),
              ),
              const SizedBox(height: 40),
              
              // Botão de Submissão
              CustomButton(
                text: 'Registrar Aposta',
                isLoading: isLoading,
                onPressed: isLoading ? null : _submitEntry,
              ),
            ],
          ),
        ),
      ),
    );
  }
}