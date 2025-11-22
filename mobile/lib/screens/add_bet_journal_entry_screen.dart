import 'package:antibet_mobile/models/bet_journal_entry_model.dart';
import 'package:antibet_mobile/models/strategy_model.dart';
import 'package:antibet_mobile/notifiers/bet_journal_notifier.dart';
import 'package:antibet_mobile/notifiers/bet_strategy_notifier.dart';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

/// Tela de Adição de Nova Entrada ao Diário de Apostas.
///
/// Permite ao usuário registrar uma nova aposta, associando-a a uma estratégia
/// e definindo o valor e o status.
class AddBetJournalEntryScreen extends StatefulWidget {
  const AddBetJournalEntryScreen({super.key});

  @override
  State<AddBetJournalEntryScreen> createState() => _AddBetJournalEntryScreenState();
}

class _AddBetJournalEntryScreenState extends State<AddBetJournalEntryScreen> {
  final _formKey = GlobalKey<FormState>();
  final _stakeController = TextEditingController();
  final _profitController = TextEditingController();
  final _notesController = TextEditingController();

  StrategyModel? _selectedStrategy;
  BetStatus _selectedStatus = BetStatus.pending;

  @override
  void dispose() {
    _stakeController.dispose();
    _profitController.dispose();
    _notesController.dispose();
    super.dispose();
  }

  /// Tenta salvar a nova entrada do diário.
  Future<void> _onSavePressed(BuildContext context) async {
    if (!(_formKey.currentState?.validate() ?? false)) {
      return;
    }

    if (_selectedStrategy == null) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Por favor, selecione uma estratégia.'), backgroundColor: Colors.orange),
      );
      return;
    }

    final journalNotifier = context.read<BetJournalNotifier>();

    // Validação de lucro: se for PENDENTE ou PERDA, deve ser negativo/zero
    double profit = double.tryParse(_profitController.text) ?? 0.0;
    if (_selectedStatus == BetStatus.loss && profit > 0) {
        profit = -profit; // Garante que a perda seja negativa se inserida como positiva
    } else if (_selectedStatus == BetStatus.win && profit < 0) {
        profit = 0.0; // Lucro não pode ser negativo em vitória (em lucro total, sim, mas não neste campo)
    }

    final newEntry = BetJournalEntryModel(
      id: DateTime.now().millisecondsSinceEpoch.toString(), // ID temporário
      strategyId: _selectedStrategy!.id,
      status: _selectedStatus,
      stake: double.tryParse(_stakeController.text) ?? 0.0,
      profit: profit,
      entryDate: DateTime.now(),
      notes: _notesController.text.trim(),
    );

    final success = await journalNotifier.addEntry(newEntry);

    if (mounted) {
      if (success) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text('Aposta registrada com sucesso!'), backgroundColor: Colors.green),
        );
        Navigator.of(context).pop(); // Volta para a tela do diário
      } else {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text(journalNotifier.errorMessage ?? 'Falha desconhecida ao salvar.')),
        );
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    // Observa o Notifier para estado de loading (apenas durante o save)
    final isSaving = context.watch<BetJournalNotifier>().isLoading;
    
    // Lista de estratégias para o Dropdown (não precisa assistir, apenas ler)
    final strategies = context.read<BetStrategyNotifier>().strategies;

    return Scaffold(
      appBar: AppBar(
        title: const Text('Registrar Nova Aposta'),
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(24.0),
        child: Form(
          key: _formKey,
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: [
              // --- Seletor de Estratégia ---
              _buildStrategyDropdown(strategies),
              const SizedBox(height: 16),

              // --- Campo Stake (Valor Apostado) ---
              TextFormField(
                controller: _stakeController,
                keyboardType: const TextInputType.numberWithOptions(decimal: true),
                decoration: const InputDecoration(
                  labelText: 'Valor Apostado (Stake) R\$',
                  border: OutlineInputBorder(),
                  prefixIcon: Icon(Icons.attach_money),
                ),
                validator: (value) {
                  if (value == null || double.tryParse(value) == null || double.parse(value) <= 0) {
                    return 'Insira um valor válido > R\$ 0.00';
                  }
                  return null;
                },
                enabled: !isSaving,
              ),
              const SizedBox(height: 16),

              // --- Seletor de Status ---
              _buildStatusDropdown(),
              const SizedBox(height: 16),
              
              // --- Campo Lucro (Apenas se não for Pendente) ---
              if (_selectedStatus != BetStatus.pending && _selectedStatus != BetStatus.voided)
                Padding(
                  padding: const EdgeInsets.only(bottom: 16.0),
                  child: TextFormField(
                    controller: _profitController,
                    keyboardType: const TextInputType.numberWithOptions(decimal: true, signed: true),
                    decoration: InputDecoration(
                      labelText: 'Lucro/Prejuízo (Profit) R\$',
                      border: const OutlineInputBorder(),
                      prefixIcon: Icon(_selectedStatus == BetStatus.win ? Icons.arrow_upward : Icons.arrow_downward),
                      hintText: _selectedStatus == BetStatus.loss ? "Ex: -10.00" : "Ex: 25.00",
                    ),
                    validator: (value) {
                        if (_selectedStatus == BetStatus.win && (double.tryParse(value ?? '0') ?? 0) < 0) {
                            return 'Lucro não deve ser negativo se o status é VITÓRIA.';
                        }
                        return null;
                    },
                    enabled: !isSaving,
                  ),
                ),

              // --- Campo Notas ---
              TextFormField(
                controller: _notesController,
                maxLines: 3,
                decoration: const InputDecoration(
                  labelText: 'Notas / Comentários',
                  border: OutlineInputBorder(),
                  prefixIcon: Icon(Icons.edit_note),
                ),
                enabled: !isSaving,
              ),
              const SizedBox(height: 24),

              // --- Botão de Salvar ---
              SizedBox(
                height: 50,
                child: ElevatedButton(
                  onPressed: isSaving ? null : () => _onSavePressed(context),
                  child: isSaving
                      ? const CircularProgressIndicator(
                          valueColor: AlwaysStoppedAnimation<Color>(Colors.white),
                        )
                      : const Text(
                          'REGISTRAR APOSTA',
                          style: TextStyle(fontSize: 18),
                        ),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  /// Constrói o Dropdown para seleção de Estratégia.
  Widget _buildStrategyDropdown(List<StrategyModel> strategies) {
    return DropdownButtonFormField<StrategyModel>(
      decoration: const InputDecoration(
        labelText: 'Estratégia Utilizada',
        border: OutlineInputBorder(),
        prefixIcon: Icon(Icons.emoji_objects_outlined),
      ),
      initialValue: _selectedStrategy,
      items: strategies.map((strategy) {
        return DropdownMenuItem(
          value: strategy,
          child: Text('${strategy.title} (${strategy.riskLevel.name.toUpperCase()})'),
        );
      }).toList(),
      onChanged: (StrategyModel? newValue) {
        setState(() {
          _selectedStrategy = newValue;
        });
      },
      validator: (value) => value == null ? 'Selecione uma estratégia.' : null,
    );
  }
  
  /// Constrói o Dropdown para seleção de Status.
  Widget _buildStatusDropdown() {
    return DropdownButtonFormField<BetStatus>(
      decoration: const InputDecoration(
        labelText: 'Status da Aposta',
        border: OutlineInputBorder(),
        prefixIcon: Icon(Icons.check_circle_outline),
      ),
      initialValue: _selectedStatus,
      items: BetStatus.values.where((s) => s != BetStatus.unknown).map((status) {
        return DropdownMenuItem(
          value: status,
          child: Text(_statusToText(status)),
        );
      }).toList(),
      onChanged: (BetStatus? newValue) {
        setState(() {
          _selectedStatus = newValue!;
        });
      },
      validator: (value) => value == null ? 'Selecione um status.' : null,
    );
  }
  
  /// Helper para formatar o Enum BetStatus para texto amigável.
  String _statusToText(BetStatus status) {
    switch(status) {
      case BetStatus.win: return 'VITÓRIA';
      case BetStatus.loss: return 'PERDA';
      case BetStatus.pending: return 'PENDENTE';
      case BetStatus.voided: return 'NULA / VOID';
      default: return 'Desconhecido';
    }
  }
}