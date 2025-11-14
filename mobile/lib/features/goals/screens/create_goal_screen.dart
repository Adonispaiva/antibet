// mobile/lib/features/goals/screens/create_goal_screen.dart

import 'package.antibet/features/goals/models/goal_model.dart';
import 'package:antibet/features/goals/notifiers/goals_notifier.dart';
import 'package.flutter/material.dart';
import 'package.provider/provider.dart';
import 'package.intl/intl.dart'; // Para formatação de data

class CreateGoalScreen extends StatefulWidget {
  const CreateGoalScreen({super.key});

  @override
  State<CreateGoalScreen> createState() => _CreateGoalScreenState();
}

class _CreateGoalScreenState extends State<CreateGoalScreen> {
  final _formKey = GlobalKey<FormState>();
  bool _isLoading = false;

  // Controladores para o formulário
  final _titleController = TextEditingController();
  final _descriptionController = TextEditingController();
  final _targetAmountController = TextEditingController();
  DateTime _targetDate = DateTime.now().add(const Duration(days: 90)); // Padrão: 90 dias

  @override
  void dispose() {
    _titleController.dispose();
    _descriptionController.dispose();
    _targetAmountController.dispose();
    super.dispose();
  }

  /// Exibe o seletor de data.
  Future<void> _selectTargetDate() async {
    final DateTime? picked = await showDatePicker(
      context: context,
      initialDate: _targetDate,
      firstDate: DateTime.now(),
      lastDate: DateTime(2101),
    );
    if (picked != null && picked != _targetDate) {
      setState(() {
        _targetDate = picked;
      });
    }
  }

  /// Tenta salvar a nova meta.
  Future<void> _submitForm() async {
    if (!_formKey.currentState!.validate()) {
      return; // Falha na validação
    }

    setState(() {
      _isLoading = true;
    });

    try {
      final newGoal = GoalModel(
        // ID é nulo (será definido pelo Backend)
        title: _titleController.text,
        description: _descriptionController.text.isEmpty
            ? null
            : _descriptionController.text,
        targetAmount: double.parse(_targetAmountController.text),
        currentAmount: 0.0, // Sempre começa com 0
        targetDate: _targetDate,
        creationDate: DateTime.now(),
        isCompleted: false,
      );

      // Acessa o Notifier
      final goalsNotifier = context.read<GoalsNotifier>();
      await goalsNotifier.addGoal(newGoal);

      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text('Meta criada com sucesso!')),
        );
        Navigator.of(context).pop(); // Volta para a GoalsScreen
      }
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('Erro ao salvar meta: $e')),
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
        title: const Text('Nova Meta Financeira'),
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
                  tooltip: 'Salvar Meta',
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
                controller: _titleController,
                decoration: const InputDecoration(labelText: 'Título da Meta (Ex: Fundo de Férias)'),
                validator: (value) => (value == null || value.isEmpty)
                    ? 'O título é obrigatório.'
                    : null,
              ),
              const SizedBox(height: 16),
              TextFormField(
                controller: _targetAmountController,
                decoration: const InputDecoration(labelText: 'Valor Alvo (R\$)'),
                keyboardType: const TextInputType.numberWithOptions(decimal: true),
                validator: (value) => (value == null || double.tryParse(value) == null || double.parse(value) <= 0)
                    ? 'Valor alvo inválido (deve ser > 0).'
                    : null,
              ),
              const SizedBox(height: 16),
              TextFormField(
                controller: _descriptionController,
                decoration: const InputDecoration(labelText: 'Descrição (Opcional)'),
                maxLines: 3,
                keyboardType: TextInputType.multiline,
              ),
              const SizedBox(height: 24),
              // Seletor de Data
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  Text(
                    'Data Alvo: ${DateFormat('dd/MM/yyyy').format(_targetDate)}',
                    style: Theme.of(context).textTheme.titleMedium,
                  ),
                  TextButton(
                    onPressed: _selectTargetDate,
                    child: const Text('Alterar Data'),
                  ),
                ],
              ),
            ],
          ),
        ),
      ),
    );
  }
}