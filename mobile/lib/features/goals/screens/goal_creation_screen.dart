import 'package:flutter/material.dart';
import 'package:auto_route/auto_route.dart';
import 'package:get_it/get_it.dart';
import 'package:intl/intl.dart'; 

import 'package:antibet/features/goals/models/goal_model.dart'; 
import 'package:antibet/features/goals/providers/goals_provider.dart';
import 'package:antibet/features/shared/widgets/app_layout.dart'; 
import 'package:antibet/features/shared/widgets/loading_button.dart'; // Importação do LoadingButton

// O decorator @RoutePage é exigido pelo auto_route
@RoutePage()
class GoalCreationScreen extends StatefulWidget {
  const GoalCreationScreen({super.key});

  @override
  State<GoalCreationScreen> createState() => _GoalCreationScreenState();
}

class _GoalCreationScreenState extends State<GoalCreationScreen> {
  final _formKey = GlobalKey<FormState>();
  
  // Controladores
  final _titleController = TextEditingController();
  final _targetValueController = TextEditingController();
  final _descriptionController = TextEditingController();
  
  // Campos de Data
  DateTime? _startDate;
  DateTime? _endDate;
  
  // Dependência (Provider)
  final GoalsProvider _goalsProvider = GetIt.I<GoalsProvider>();

  @override
  void dispose() {
    _titleController.dispose();
    _targetValueController.dispose();
    _descriptionController.dispose();
    super.dispose();
  }

  /// Abre o seletor de data.
  Future<void> _selectDate(BuildContext context, bool isStart) async {
    final DateTime? picked = await showDatePicker(
      context: context,
      initialDate: DateTime.now(),
      firstDate: DateTime(2023),
      lastDate: DateTime(2030),
    );
    if (picked != null && mounted) {
      setState(() {
        if (isStart) {
          _startDate = picked;
        } else {
          _endDate = picked;
        }
      });
    }
  }

  /// Constrói o modelo e chama o Provider para persistir a nova meta.
  Future<void> _submitForm() async {
    if (_formKey.currentState?.validate() ?? false) {
      if (_startDate == null || _endDate == null) {
        if (mounted) {
          ScaffoldMessenger.of(context).showSnackBar(
            const SnackBar(content: Text('Por favor, selecione as datas de início e fim.')),
          );
        }
        return;
      }
      
      try {
        final newGoal = GoalModel(
          id: 'temp_id-${DateTime.now().millisecondsSinceEpoch}', 
          title: _titleController.text,
          description: _descriptionController.text,
          targetValue: double.parse(_targetValueController.text),
          currentValue: 0.0, 
          startDate: _startDate!,
          endDate: _endDate!,
          status: 'ACTIVE',
        );
        
        await _goalsProvider.createGoal(newGoal);
        
        if (mounted) context.router.pop();
        
      } catch (e) {
        if (mounted) {
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(content: Text('Falha ao definir meta: ${e.toString()}')),
          );
        }
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    return ListenableBuilder(
      listenable: _goalsProvider,
      builder: (context, child) {
        return AppLayout(
          isLoading: false, // O loading agora é tratado pelo botão
          appBar: AppBar(
            title: const Text('Definir Nova Meta'),
          ),
          child: SingleChildScrollView(
            child: Form(
              key: _formKey,
              child: Column(
                children: [
                  // --- Title Input ---
                  TextFormField(
                    controller: _titleController,
                    decoration: const InputDecoration(labelText: 'Nome da Meta'),
                    validator: (v) => v!.isEmpty ? 'Campo obrigatório.' : null,
                  ),
                  const SizedBox(height: 16),
    
                  // --- Target Value Input ---
                  TextFormField(
                    controller: _targetValueController,
                    decoration: const InputDecoration(labelText: 'Valor Alvo (Ex: 5000.00)'),
                    keyboardType: const TextInputType.numberWithOptions(decimal: true),
                    validator: (v) => v!.isEmpty ? 'Obrigatório.' : null,
                  ),
                  const SizedBox(height: 16),
                  
                  // --- Date Pickers ---
                  Row(
                    children: [
                      Expanded(
                        child: InkWell(
                          onTap: () => _selectDate(context, true),
                          child: InputDecorator(
                            decoration: const InputDecoration(labelText: 'Data de Início'),
                            child: Text(
                              _startDate == null ? 'Selecionar' : DateFormat('dd/MM/yyyy').format(_startDate!),
                            ),
                          ),
                        ),
                      ),
                      const SizedBox(width: 16),
                      Expanded(
                        child: InkWell(
                          onTap: () => _selectDate(context, false),
                          child: InputDecorator(
                            decoration: const InputDecoration(labelText: 'Data de Fim'),
                            child: Text(
                              _endDate == null ? 'Selecionar' : DateFormat('dd/MM/yyyy').format(_endDate!),
                            ),
                          ),
                        ),
                      ),
                    ],
                  ),
                  const SizedBox(height: 16),
    
                  // --- Description Input ---
                  TextFormField(
                    controller: _descriptionController,
                    decoration: const InputDecoration(labelText: 'Descrição e Critérios'),
                    maxLines: 4,
                  ),
                  const SizedBox(height: 32),
    
                  // --- Submit Button (Usando LoadingButton) ---
                  LoadingButton(
                    text: 'CRIAR META',
                    isLoading: _goalsProvider.isLoading,
                    onPressed: _submitForm,
                  ),
                  const SizedBox(height: 20),
                ],
              ),
            ),
          ),
        );
      },
    );
  }
}