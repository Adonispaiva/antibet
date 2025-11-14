import 'package:antibet/core/models/bet_journal_entry_model.dart'; // Assumindo o modelo
import 'package:antibet/core/notifiers/bet_journal_notifier.dart';
import 'package:antibet/core/notifiers/bet_strategy_notifier.dart'; // Para selecionar a estratégia
import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:provider/provider.dart';

class AddBetJournalEntryScreen extends StatefulWidget {
  const AddBetJournalEntryScreen({super.key});

  @override
  State<AddBetJournalEntryScreen> createState() => _AddBetJournalEntryScreenState();
}

class _AddBetJournalEntryScreenState extends State<AddBetJournalEntryScreen> {
  final _formKey = GlobalKey<FormState>();
  final TextEditingController _descriptionController = TextEditingController();
  final TextEditingController _stakeController = TextEditingController();
  final TextEditingController _payoutController = TextEditingController();

  String? _selectedResult = 'Win';
  String? _selectedStrategyId;

  // Lista de resultados possíveis
  final List<String> _results = ['Win', 'Loss', 'Push'];

  @override
  void dispose() {
    _descriptionController.dispose();
    _stakeController.dispose();
    _payoutController.dispose();
    super.dispose();
  }

  void _submit() async {
    if (_formKey.currentState!.validate()) {
      if (_selectedStrategyId == null) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text('Please select a strategy.')),
        );
        return;
      }
      
      final journalNotifier = context.read<BetJournalNotifier>();
      
      final newEntry = BetJournalEntryModel(
        id: DateTime.now().millisecondsSinceEpoch.toString(), // ID Simples
        date: DateTime.now(),
        strategyId: _selectedStrategyId!,
        description: _descriptionController.text.trim(),
        stake: double.tryParse(_stakeController.text) ?? 0.0,
        result: _selectedResult!,
        payout: double.tryParse(_payoutController.text) ?? 0.0,
      );
      
      final success = await journalNotifier.addEntry(newEntry);

      if (success && mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text('Bet entry added successfully!')),
        );
        context.pop(); // Volta para a tela anterior (HomeScreen)
      } else if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text('Failed to add bet entry.')),
        );
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    final strategyNotifier = context.watch<BetStrategyNotifier>();
    final strategies = strategyNotifier.strategies;
    
    // Define o ID da primeira estratégia como padrão se não houver seleção
    if (_selectedStrategyId == null && strategies.isNotEmpty) {
      _selectedStrategyId = strategies.first.id;
    }

    return Scaffold(
      appBar: AppBar(
        title: const Text('Add New Bet Entry'),
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(16.0),
        child: Form(
          key: _formKey,
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: [
              // Campo Descrição
              TextFormField(
                controller: _descriptionController,
                decoration: const InputDecoration(
                  labelText: 'Description',
                  hintText: 'e.g., Chelsea vs Arsenal - Over 2.5 goals',
                  border: OutlineInputBorder(),
                ),
                validator: (value) => value == null || value.isEmpty ? 'Description is required.' : null,
              ),
              const SizedBox(height: 16),
              
              // Seletor de Estratégia
              DropdownButtonFormField<String>(
                decoration: const InputDecoration(
                  labelText: 'Strategy',
                  border: OutlineInputBorder(),
                ),
                value: _selectedStrategyId,
                items: strategies.map((strategy) {
                  return DropdownMenuItem<String>(
                    value: strategy.id,
                    child: Text(strategy.name),
                  );
                }).toList(),
                onChanged: (String? newValue) {
                  setState(() {
                    _selectedStrategyId = newValue;
                  });
                },
                validator: (value) => value == null ? 'Please select a strategy.' : null,
              ),
              const SizedBox(height: 16),
              
              // Campo Stake (Aposta)
              TextFormField(
                controller: _stakeController,
                keyboardType: TextInputType.number,
                decoration: const InputDecoration(
                  labelText: 'Stake (Amount Wagered)',
                  prefixText: 'R\$ ',
                  border: OutlineInputBorder(),
                ),
                validator: (value) {
                  if (value == null || double.tryParse(value) == null || double.parse(value) <= 0) {
                    return 'Please enter a valid amount > 0.';
                  }
                  return null;
                },
                key: const Key('stake_field'),
              ),
              const SizedBox(height: 16),
              
              // Seletor de Resultado
              DropdownButtonFormField<String>(
                decoration: const InputDecoration(
                  labelText: 'Result',
                  border: OutlineInputBorder(),
                ),
                value: _selectedResult,
                items: _results.map((String value) {
                  return DropdownMenuItem<String>(
                    value: value,
                    child: Text(value),
                  );
                }).toList(),
                onChanged: (String? newValue) {
                  setState(() {
                    _selectedResult = newValue;
                });
                },
                key: const Key('result_dropdown'),
              ),
              const SizedBox(height: 16),
              
              // Campo Payout
              TextFormField(
                controller: _payoutController,
                keyboardType: TextInputType.number,
                decoration: const InputDecoration(
                  labelText: 'Total Payout (Including Stake)',
                  prefixText: 'R\$ ',
                  border: OutlineInputBorder(),
                ),
                validator: (value) {
                  if (value == null || double.tryParse(value) == null) {
                    return 'Please enter a valid payout amount.';
                  }
                  return null;
                },
              ),
              const SizedBox(height: 30),
              
              // Botão de Submissão
              ElevatedButton.icon(
                onPressed: _submit,
                icon: const Icon(Icons.save),
                label: const Text('Save Entry', style: TextStyle(fontSize: 18)),
                style: ElevatedButton.styleFrom(
                  padding: const EdgeInsets.symmetric(vertical: 15),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}