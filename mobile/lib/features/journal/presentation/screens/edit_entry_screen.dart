import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:antibet/core/utils/snackbar_utils.dart';
import 'package:antibet/features/journal/data/models/journal_entry_model.dart';
import 'package:antibet/features/journal/presentation/providers/journal_provider.dart';

class EditEntryScreen extends ConsumerStatefulWidget {
  final JournalEntryModel entry;

  const EditEntryScreen({super.key, required this.entry});

  @override
  ConsumerState<EditEntryScreen> createState() => _EditEntryScreenState();
}

class _EditEntryScreenState extends ConsumerState<EditEntryScreen> {
  final _formKey = GlobalKey<FormState>();
  late TextEditingController _descriptionController;
  late TextEditingController _amountController;
  late bool _isWin;

  @override
  void initState() {
    super.initState();
    _descriptionController = TextEditingController(text: widget.entry.description);
    _amountController = TextEditingController(text: widget.entry.amount.toString());
    _isWin = widget.entry.isWin;
  }

  @override
  void dispose() {
    _descriptionController.dispose();
    _amountController.dispose();
    super.dispose();
  }

  void _saveEntry() {
    if (_formKey.currentState!.validate()) {
      // Evita múltiplos cliques se já estiver carregando
      if (ref.read(journalProvider).isLoading) return;

      final updatedEntry = widget.entry.copyWith(
        description: _descriptionController.text,
        amount: double.parse(_amountController.text),
        isWin: _isWin,
      );

      final provider = ref.read(journalProvider.notifier);
      
      provider.updateEntry(updatedEntry).then((success) {
        if (mounted) {
          if (success) {
            SnackBarUtils.showSuccess(context, 'Entrada atualizada com sucesso!');
            context.go('/journal');
          } else {
            SnackBarUtils.showError(context, 'Falha ao atualizar a entrada.');
          }
        }
      });
    }
  }

  Future<void> _deleteEntry() async {
    final bool? confirm = await showDialog<bool>(
      context: context,
      builder: (BuildContext context) {
        return AlertDialog(
          title: const Text('Confirmação'),
          content: const Text('Tem certeza que deseja excluir esta entrada?'),
          actions: <Widget>[
            TextButton(
              onPressed: () => context.pop(false),
              child: const Text('CANCELAR'),
            ),
            TextButton(
              key: const Key('confirm_delete_button'),
              onPressed: () => context.pop(true),
              child: const Text('CONFIRMAR'),
            ),
          ],
        );
      },
    );

    if (confirm == true) {
      if (mounted) {
        // Evita chamadas se o widget foi desmontado
        final provider = ref.read(journalProvider.notifier);
        
        provider.deleteEntry(widget.entry.id).then((success) {
          if (mounted) {
            if (success) {
              SnackBarUtils.showSuccess(context, 'Entrada excluída com sucesso!');
              context.go('/journal');
            } else {
              SnackBarUtils.showError(context, 'Falha ao excluir a entrada.');
            }
          }
        });
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    final state = ref.watch(journalProvider);

    return Scaffold(
      appBar: AppBar(
        title: const Text('Editar Entrada'),
        actions: [
          IconButton(
            key: const Key('delete_entry_button'),
            icon: const Icon(Icons.delete),
            onPressed: state.isLoading ? null : _deleteEntry,
            tooltip: 'Deletar Entrada',
          ),
        ],
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
              const SizedBox(height: 16),
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
                key: const Key('save_edit_button'),
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
                    : const Text('SALVAR ALTERAÇÕES', style: TextStyle(fontSize: 18)),
              ),
            ],
          ),
        ),
      ),
    );
  }
}