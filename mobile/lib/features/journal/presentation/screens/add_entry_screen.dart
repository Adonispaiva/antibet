import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:antibet/core/utils/snackbar_utils.dart';
import 'package:antibet/features/journal/presentation/providers/journal_provider.dart';
import 'package:go_router/go_router.dart';

class AddEntryScreen extends ConsumerStatefulWidget {
  const AddEntryScreen({super.key});

  @override
  ConsumerState<AddEntryScreen> createState() => _AddEntryScreenState();
}

class _AddEntryScreenState extends ConsumerState<AddEntryScreen> {
  final _formKey = GlobalKey<FormState>();
  final TextEditingController _descriptionController = TextEditingController();
  final TextEditingController _amountController = TextEditingController();
  bool _isWin = false;

  @override
  void dispose() {
    _descriptionController.dispose();
    _amountController.dispose();
    super.dispose();
  }

  void _saveEntry() {
    if (_formKey.currentState!.validate()) {
      final description = _descriptionController.text;
      final amount = double.tryParse(_amountController.text);

      if (amount == null) {
        SnackBarUtils.showError(context, 'Valor da aposta inválido.');
        return;
      }

      // Evita múltiplos cliques
      if (ref.read(journalProvider).isLoading) return;

      final provider = ref.read(journalProvider.notifier);

      provider.createEntry(description, amount, _isWin).then((success) {
        if (mounted) {
          if (success) {
            SnackBarUtils.showSuccess(context, 'Nova entrada registrada com sucesso!');
            context.go('/journal');
          } else {
            SnackBarUtils.showError(context, 'Falha ao registrar a entrada.');
          }
        }
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    final state = ref.watch(journalProvider);

    return Scaffold(
      appBar: AppBar(
        title: const Text('Adicionar Nova Aposta'),
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(16.0),
        child: Form(
          key: _formKey,
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: <Widget>[
              TextFormField(
                key: const Key('description_field'),
                controller: _descriptionController,
                decoration: const InputDecoration(
                  labelText: 'Descrição da Aposta',
                  border: OutlineInputBorder(),
                ),
                validator: (value) {
                  if (value == null || value.isEmpty) {
                    return 'A descrição não pode ser vazia.';
                  }
                  return null;
                },
              ),
              const SizedBox(height: 16),
              TextFormField(
                key: const Key('amount_field'),
                controller: _amountController,
                keyboardType: TextInputType.number,
                decoration: const InputDecoration(
                  labelText: 'Valor Apostado',
                  border: OutlineInputBorder(),
                ),
                validator: (value) {
                  if (value == null || double.tryParse(value) == null) {
                    return 'Insira um valor numérico válido.';
                  }
                  if (double.parse(value) <= 0) {
                    return 'O valor deve ser maior que zero.';
                  }
                  return null;
                },
              ),
              const SizedBox(height: 24),
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  const Text(
                    'Resultado da Aposta:',
                    style: TextStyle(fontSize: 16),
                  ),
                  Row(
                    children: [
                      const Text('Perdeu'),
                      Switch(
                        key: const Key('is_win_switch'),
                        value: _isWin,
                        onChanged: (bool newValue) {
                          setState(() {
                            _isWin = newValue;
                          });
                        },
                        activeColor: Colors.green,
                        inactiveThumbColor: Colors.red,
                        inactiveTrackColor: Colors.red[100],
                      ),
                      const Text('Ganhou'),
                    ],
                  ),
                ],
              ),
              const SizedBox(height: 32),
              ElevatedButton(
                key: const Key('save_entry_button'),
                onPressed: state.isLoading ? null : _saveEntry,
                style: ElevatedButton.styleFrom(
                  minimumSize: const Size(double.infinity, 50),
                ),
                child: state.isLoading
                    ? const SizedBox(
                        height: 24,
                        width: 24,
                        child: CircularProgressIndicator(
                          strokeWidth: 2,
                          color: Colors.white,
                        ),
                      )
                    : const Text('REGISTRAR ENTRADA', style: TextStyle(fontSize: 18)),
              ),
            ],
          ),
        ),
      ),
    );
  }
}