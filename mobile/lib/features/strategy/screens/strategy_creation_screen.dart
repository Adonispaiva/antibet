import 'package:flutter/material.dart';
import 'package:auto_route/auto_route.dart';
import 'package:get_it/get_it.dart';

import 'package:antibet/features/strategy/models/strategy_model.dart'; 
import 'package:antibet/features/strategy/providers/strategy_provider.dart';
import 'package:antibet/features/shared/widgets/app_layout.dart'; 
import 'package:antibet/features/shared/widgets/loading_button.dart'; // Importação do LoadingButton

// O decorator @RoutePage é exigido pelo auto_route
@RoutePage()
class StrategyCreationScreen extends StatefulWidget {
  const StrategyCreationScreen({super.key});

  @override
  State<StrategyCreationScreen> createState() => _StrategyCreationScreenState();
}

class _StrategyCreationScreenState extends State<StrategyCreationScreen> {
  final _formKey = GlobalKey<FormState>();
  
  // Controladores
  final _nameController = TextEditingController();
  final _descriptionController = TextEditingController();
  
  // Campos de Seleção
  String? _selectedType;
  final List<String> _strategyTypes = ['Scalping', 'Day Trade', 'Swing Trade', 'Position Trade'];
  
  // Dependência (Provider)
  final StrategyProvider _strategyProvider = GetIt.I<StrategyProvider>();

  @override
  void dispose() {
    _nameController.dispose();
    _descriptionController.dispose();
    super.dispose();
  }

  /// Constrói o modelo e chama o Provider para persistir a nova estratégia.
  Future<void> _submitForm() async {
    if (_formKey.currentState?.validate() ?? false) {
      if (_selectedType == null) {
        if (mounted) {
          ScaffoldMessenger.of(context).showSnackBar(
            const SnackBar(content: Text('Por favor, selecione o Tipo de Trading.')),
          );
        }
        return;
      }
      
      try {
        final newStrategy = StrategyModel(
          id: 'temp_id-${DateTime.now().millisecondsSinceEpoch}', 
          name: _nameController.text,
          description: _descriptionController.text,
          type: _selectedType!,
          isActive: true, // Nova estratégia começa ativa
          createdAt: DateTime.now(),
        );
        
        await _strategyProvider.createStrategy(newStrategy);
        
        // Sucesso: Retorna para a tela anterior
        if (mounted) context.router.pop();
        
      } catch (e) {
        // Exibir erro de criação
        if (mounted) {
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(content: Text('Falha ao criar estratégia: ${e.toString()}')),
          );
        }
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    return ListenableBuilder(
      listenable: _strategyProvider,
      builder: (context, child) {
        return AppLayout(
          isLoading: false, // O loading agora é tratado pelo botão
          appBar: AppBar(
            title: const Text('Criar Nova Estratégia'),
          ),
          child: SingleChildScrollView(
            child: Form(
              key: _formKey,
              child: Column(
                children: [
                  // --- Name Input ---
                  TextFormField(
                    controller: _nameController,
                    decoration: const InputDecoration(labelText: 'Nome da Estratégia'),
                    validator: (v) => v!.isEmpty ? 'Campo obrigatório.' : null,
                  ),
                  const SizedBox(height: 16),
    
                  // --- Type Selection ---
                  DropdownButtonFormField<String>(
                    decoration: const InputDecoration(labelText: 'Tipo de Trading'),
                    initialValue: _selectedType,
                    items: _strategyTypes.map((type) {
                      return DropdownMenuItem(
                        value: type,
                        child: Text(type),
                      );
                    }).toList(),
                    onChanged: (value) {
                      setState(() {
                        _selectedType = value;
                      });
                    },
                    validator: (v) => v == null ? 'Selecione o tipo.' : null,
                  ),
                  const SizedBox(height: 16),
    
                  // --- Description Input ---
                  TextFormField(
                    controller: _descriptionController,
                    decoration: const InputDecoration(labelText: 'Descrição e Regras'),
                    maxLines: 4,
                  ),
                  const SizedBox(height: 32),
    
                  // --- Submit Button (Usando LoadingButton) ---
                  LoadingButton(
                    text: 'SALVAR ESTRATÉGIA',
                    isLoading: _strategyProvider.isLoading,
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