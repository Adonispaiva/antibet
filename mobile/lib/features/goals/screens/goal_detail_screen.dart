// mobile/lib/features/goals/screens/goal_detail_screen.dart

import 'package:antibet/features/goals/models/goal_model.dart';
import 'package:antibet/features/goals/notifiers/goals_notifier.dart';
import 'package.flutter/material.dart';
import 'package.provider/provider.dart';
import 'package.intl/intl.dart'; // Para formatação de data

class GoalDetailScreen extends StatefulWidget {
  final GoalModel goal;

  const GoalDetailScreen({super.key, required this.goal});

  @override
  State<GoalDetailScreen> createState() => _GoalDetailScreenState();
}

class _GoalDetailScreenState extends State<GoalDetailScreen> {
  final _formKey = GlobalKey<FormState>();
  bool _isLoading = false;

  // Controladores pré-preenchidos
  late TextEditingController _titleController;
  late TextEditingController _descriptionController;
  late TextEditingController _targetAmountController;
  late TextEditingController _currentAmountController; // O progresso pode ser editado
  late DateTime _targetDate;
  late bool _isCompleted;

  @override
  void initState() {
    super.initState();
    // Inicializa os controladores com os dados da meta recebida
    _titleController = TextEditingController(text: widget.goal.title);
    _descriptionController = TextEditingController(text: widget.goal.description ?? '');
    _targetAmountController = TextEditingController(text: widget.goal.targetAmount.toStringAsFixed(2));
    _currentAmountController = TextEditingController(text: widget.goal.currentAmount.toStringAsFixed(2));
    _targetDate = widget.goal.targetDate;
    _isCompleted = widget.goal.isCompleted;
  }

  @override
  void dispose() {
    _titleController.dispose();
    _descriptionController.dispose();
    _targetAmountController.dispose();
    _currentAmountController.dispose();
    super.dispose();
  }

  /// Exibe o seletor de data.
  Future<void> _selectTargetDate() async {
    final DateTime? picked = await showDatePicker(
      context: context,
      initialDate: _targetDate,
      firstDate: DateTime(2020), // Permite datas passadas para edição
      lastDate: DateTime(2101),
    );
    if (picked != null && picked != _targetDate) {
      setState(() {
        _targetDate = picked;
      });
    }
  }

  /// Tenta atualizar a meta.
  Future<void> _submitUpdate() async {
    if (!_formKey.currentState!.validate()) {
      return; // Falha na validação
    }

    setState(() {
      _isLoading = true;
    });

    try {
      // Cria um novo modelo com os dados atualizados (baseado no ID da meta original)
      final updatedGoal = widget.goal.copyWith(
        title: _titleController.text,
        description: ValueGetter(() => 
          _descriptionController.text.isEmpty ? null : _descriptionController.text
        )(),
        targetAmount: double.parse(_targetAmountController.text),
        currentAmount: double.parse(_currentAmountController.text),
        targetDate: _targetDate,
        isCompleted: _isCompleted,
        completionDate: _isCompleted ? (widget.goal.completionDate ?? DateTime.now()) : const ValueGetter(() => null)(),
      );

      // Acessa o Notifier
      final goalsNotifier = context.read<GoalsNotifier>();
      await goalsNotifier.updateGoal(updatedGoal);

      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text('Meta atualizada com sucesso!')),
        );
        Navigator.of(context).pop(); // Volta para a GoalsScreen
      }
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('Erro ao atualizar meta: $e')),
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
        title: const Text('Editar Meta'),
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
                controller: _titleController,
                decoration: const InputDecoration(labelText: 'Título da Meta'),
                validator: (value) => (value == null || value.isEmpty)
                    ? 'O título é obrigatório.'
                    : null,
              ),
              const SizedBox(height: 16),
              Row(
                children: [
                  Expanded(
                    child: TextFormField(
                      controller: _targetAmountController,
                      decoration: const InputDecoration(labelText: 'Valor Alvo (R\$)'),
                      keyboardType: const TextInputType.numberWithOptions(decimal: true),
                      validator: (value) => (value == null || double.tryParse(value) == null || double.parse(value) <= 0)
                          ? 'Valor alvo inválido (deve ser > 0).'
                          : null,
                    ),
                  ),
                  const SizedBox(width: 16),
                  Expanded(
                    child: TextFormField(
                      controller: _currentAmountController,
                      decoration: const InputDecoration(labelText: 'Progresso Atual (R\$)'),
                      keyboardType: const TextInputType.numberWithOptions(decimal: true),
                      validator: (value) => (value == null || double.tryParse(value) == null || double.parse(value) < 0)
                          ? 'Valor inválido (deve ser >= 0).'
                          : null,
                    ),
                  ),
                ],
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
              // Switch de Conclusão
              SwitchListTile(
                title: const Text('Meta Concluída'),
                value: _isCompleted,
                onChanged: (bool value) {
                  setState(() {
                    _isCompleted = value;
                  });
                },
              ),
            ],
          ),
        ),
      ),
    );
  }
}