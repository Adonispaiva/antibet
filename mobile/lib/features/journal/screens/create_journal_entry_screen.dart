// mobile/lib/features/journal/screens/create_journal_entry_screen.dart

import 'package.antibet/features/journal/models/journal_entry_model.dart';
import 'package:antibet/features/journal/notifiers/journal_notifier.dart';
import 'package:flutter/material.dart';
import 'package.provider/provider.dart';

class CreateJournalEntryScreen extends StatefulWidget {
  const CreateJournalEntryScreen({super.key});

  @override
  State<CreateJournalEntryScreen> createState() => _CreateJournalEntryScreenState();
}

class _CreateJournalEntryScreenState extends State<CreateJournalEntryScreen> {
  final _formKey = GlobalKey<FormState>();
  bool _isLoading = false;

  // Controladores para o formulário
  final _strategyController = TextEditingController();
  final _stakeController = TextEditingController();
  final _finalResultController = TextEditingController();
  final _preAnalysisController = TextEditingController();
  final _postAnalysisController = TextEditingController();

  @override
  void dispose() {
    _strategyController.dispose();
    _stakeController.dispose();
    _finalResultController.dispose();
    _preAnalysisController.dispose();
    _postAnalysisController.dispose();
    super.dispose();
  }

  /// Tenta salvar a nova entrada no diário.
  Future<void> _submitForm() async {
    if (!_formKey.currentState!.validate()) {
      return; // Falha na validação
    }

    setState(() {
      _isLoading = true;
    });

    try {
      final newEntry = JournalEntryModel(
        // ID é nulo (será definido pelo Backend)
        strategyName: _strategyController.text,
        stake: double.parse(_stakeController.text),
        finalResult: double.parse(_finalResultController.text),
        preAnalysis: _preAnalysisController.text,
        postAnalysis: _postAnalysisController.text.isEmpty
            ? null
            : _postAnalysisController.text,
        entryDate: DateTime.now(), // Data de criação
      );

      // Acessa o Notifier (sem 'watch')
      final journalNotifier = context.read<JournalNotifier>();
      await journalNotifier.addEntry(newEntry);

      // Se a submissão foi bem-sucedida (sem exceções)
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text('Entrada salva com sucesso!')),
        );
        Navigator.of(context).pop(); // Volta para a JournalScreen
      }
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('Erro ao salvar entrada: $e')),
        );
      }
    } finally {
      if (mounted) {
        setState(() {
          _isLoading = false;
        });
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Nova Entrada no Diário'),
        actions: [
          _isLoading
              ? const Padding(
                  padding: EdgeInsets.all(16.0),
                  child: SizedBox(
                    width: 20,
                    height: 20,
                    child: CircularProgressIndicator(
                      color: Colors.white,
                      strokeWidth: 2,
                    ),
                  ),
                )
              : IconButton(
                  icon: const Icon(Icons.save),
                  onPressed: _submitForm,
                  tooltip: 'Salvar Entrada',
                ),
        ],
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(24.0),
        child: Form(
          key: _formKey,
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              TextFormField(
                controller: _strategyController,
                decoration: const InputDecoration(labelText: 'Estratégia Utilizada'),
                validator: (value) => (value == null || value.isEmpty)
                    ? 'A estratégia é obrigatória.'
                    : null,
              ),
              const SizedBox(height: 16),
              Row(
                children: [
                  Expanded(
                    child: TextFormField(
                      controller: _stakeController,
                      decoration: const InputDecoration(labelText: 'Valor (R\$)'),
                      keyboardType: const TextInputType.numberWithOptions(decimal: true),
                      validator: (value) => (value == null || double.tryParse(value) == null)
                          ? 'Valor inválido.'
                          : null,
                    ),
                  ),
                  const SizedBox(width: 16),
                  Expanded(
                    child: TextFormField(
                      controller: _finalResultController,
                      decoration: const InputDecoration(labelText: 'Resultado (+/- R\$)'),
                      keyboardType: const TextInputType.numberWithOptions(decimal: true, signed: true),
                      validator: (value) => (value == null || double.tryParse(value) == null)
                          ? 'Resultado inválido.'
                          : null,
                    ),
                  ),
                ],
              ),
              const SizedBox(height: 16),
              TextFormField(
                controller: _preAnalysisController,
                decoration: const InputDecoration(labelText: 'Pré-Análise (Obrigatório)'),
                maxLines: 5,
                keyboardType: TextInputType.multiline,
                validator: (value) => (value == null || value.isEmpty)
                    ? 'A pré-análise é obrigatória.'
                    : null,
              ),
              const SizedBox(height: 16),
              TextFormField(
                controller: _postAnalysisController,
                decoration: const InputDecoration(labelText: 'Pós-Análise (Opcional)'),
                maxLines: 5,
                keyboardType: TextInputType.multiline,
              ),
            ],
          ),
        ),
      ),
    );
  }
}