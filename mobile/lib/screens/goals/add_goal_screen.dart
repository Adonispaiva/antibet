import 'package:flutter/material.dart';
import 'package:inovexa_antibet/models/goal.model.dart';
import 'package:inovexa_antibet/providers/goals_provider.dart';
import 'package:provider/provider.dart';

/// Tela (Modal) para Adicionar ou Editar uma Meta.
class AddGoalScreen extends StatefulWidget {
  // Se 'goal' for nulo, está em modo 'Criar'.
  // Se 'goal' for fornecido, está em modo 'Editar'.
  final Goal? goal;

  const AddGoalScreen({super.key, this.goal});

  @override
  State<AddGoalScreen> createState() => _AddGoalScreenState();
}

class _AddGoalScreenState extends State<AddGoalScreen> {
  final _formKey = GlobalKey<FormState>();
  late TextEditingController _titleController;
  late TextEditingController _descriptionController;
  // TODO: Implementar seletor de data (dueDate)

  bool _isLoading = false;

  @override
  void initState() {
    super.initState();
    // Preenche o formulário se estiver em modo de edição
    _titleController = TextEditingController(text: widget.goal?.title ?? '');
    _descriptionController =
        TextEditingController(text: widget.goal?.description ?? '');
  }

  @override
  void dispose() {
    _titleController.dispose();
    _descriptionController.dispose();
    super.dispose();
  }

  Future<void> _submitForm() async {
    if (!_formKey.currentState!.validate()) {
      return;
    }

    setState(() { _isLoading = true; });

    final goalsProvider = Provider.of<GoalsProvider>(context, listen: false);
    final Map<String, dynamic> goalData = {
      'title': _titleController.text.trim(),
      'description': _descriptionController.text.trim(),
    };

    bool success;
    if (widget.goal == null) {
      // Modo Criar (POST)
      success = await goalsProvider.addGoal(goalData);
    } else {
      // Modo Editar (PATCH)
      success = await goalsProvider.updateGoal(widget.goal!.id, goalData);
    }

    if (mounted) {
      if (success) {
        Navigator.of(context).pop(); // Fecha o modal
      } else {
        // Exibe erro do provider
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text(goalsProvider.error ?? 'Falha ao salvar meta.'),
            backgroundColor: Colors.red,
          ),
        );
      }
      setState(() { _isLoading = false; });
    }
  }

  @override
  Widget build(BuildContext context) {
    final bool isEditing = widget.goal != null;

    return Padding(
      padding: EdgeInsets.only(
        bottom: MediaQuery.of(context).viewInsets.bottom,
        top: 24,
        left: 24,
        right: 24,
      ),
      child: Form(
        key: _formKey,
        child: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            Text(
              isEditing ? 'Editar Meta' : 'Nova Meta',
              style: Theme.of(context).textTheme.headlineMedium,
              textAlign: TextAlign.center,
            ),
            const SizedBox(height: 24),
            TextFormField(
              controller: _titleController,
              decoration: const InputDecoration(labelText: 'Título da Meta'),
              validator: (value) => (value == null || value.trim().isEmpty)
                  ? 'O título é obrigatório.'
                  : null,
            ),
            const SizedBox(height: 16),
            TextFormField(
              controller: _descriptionController,
              decoration: const InputDecoration(labelText: 'Descrição (Opcional)'),
              maxLines: 3,
            ),
            const SizedBox(height: 24),
            _isLoading
                ? const Center(child: CircularProgressIndicator())
                : ElevatedButton(
                    onPressed: _submitForm,
                    child: Text(isEditing ? 'Salvar Alterações' : 'Criar Meta'),
                  ),
            const SizedBox(height: 16),
          ],
        ),
      ),
    );
  }
}