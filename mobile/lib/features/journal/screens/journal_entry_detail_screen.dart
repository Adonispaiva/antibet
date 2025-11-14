// mobile/lib/features/journal/screens/journal_entry_detail_screen.dart

import 'package:antibet/features/journal/models/journal_entry_model.dart';
import 'package:antibet/features/journal/notifiers/journal_notifier.dart';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

class JournalEntryDetailScreen extends StatefulWidget {
  final JournalEntryModel entry;

  const JournalEntryDetailScreen({super.key, required this.entry});

  @override
  State<JournalEntryDetailScreen> createState() => _JournalEntryDetailScreenState();
}

class _JournalEntryDetailScreenState extends State<JournalEntryDetailScreen> {
  final _formKey = GlobalKey<FormState>();
  bool _isLoading = false;

  // Controladores pré-preenchidos
  late TextEditingController _strategyController;
  late TextEditingController _stakeController;
  late TextEditingController _finalResultController;
  late TextEditingController _preAnalysisController;
  late TextEditingController _postAnalysisController;

  @override
  void initState() {
    super.initState();
    // Inicializa os controladores com os dados da entrada recebida
    _strategyController = TextEditingController(text: widget.entry.strategyName);
    _stakeController = TextEditingController(text: widget.entry.stake.toStringAsFixed(2));
    _finalResultController = TextEditingController(text: widget.entry.finalResult.toStringAsFixed(2));
    _preAnalysisController = TextEditingController(text: widget.entry.preAnalysis);
    _postAnalysisController = TextEditingController(text: widget.entry.postAnalysis ?? '');
  }

  @override
  void dispose() {
    _strategyController.dispose();
    _stakeController.dispose();
    _finalResultController.dispose();
    _preAnalysisController.dispose();
    _postAnalysisController.dispose();
    super.dispose();
  }

  /// Tenta atualizar a entrada no diário.
  Future<void> _submitUpdate() async {
    if (!_formKey.currentState!.validate()) {
      return; // Falha na validação
    }

    setState(() {
      _isLoading = true;
    });

    try {
      // Cria um novo modelo com os dados atualizados (baseado no ID da entrada original)
      final updatedEntry = widget.entry.copyWith(
        strategyName: _strategyController.text,
        stake: double.parse(_stakeController.text),
        finalResult: double.parse(_finalResultController.text),
        preAnalysis: _preAnalysisController.text,
        // Usa ValueGetter para permitir a passagem de null (se o campo for limpo)
        postAnalysis: ValueGetter(() => 
          _postAnalysisController.text.isEmpty ? null : _postAnalysisController.text
        )(), 
      );

      // Acessa o Notifier
      final journalNotifier = context.read<JournalNotifier>();
      await journalNotifier.updateEntry(updatedEntry);

      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text('Entrada atualizada com sucesso!')),
        );
        Navigator.of(context).pop(); // Volta para a JournalScreen
      }
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('Erro ao atualizar entrada: $e')),
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
        title: const Text('Editar Entrada'),
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
                  onPressed: _submitUpdate,
                  tooltip: 'Salvar Alterações',
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