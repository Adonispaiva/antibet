import 'packagepackage:flutter/material.dart';
import 'package:auto_route/auto_route.dart';
import 'package:get_it/get_it.dart';
import 'package:antibet/features/journal/models/journal_entry_model.dart'; 
import 'package:antibet/features/journal/providers/journal_provider.dart';
import 'package:antibet/features/strategy/providers/strategy_provider.dart'; 
import 'package:antibet/features/shared/widgets/app_layout.dart'; 
import 'package:antibet/features/shared/widgets/loading_button.dart'; // Importação do LoadingButton

// O decorator @RoutePage é exigido pelo auto_route para gerar a rota correspondente.
@RoutePage()
class JournalEntryCreationScreen extends StatefulWidget {
  const JournalEntryCreationScreen({super.key});

  @override
  State<JournalEntryCreationScreen> createState() => _JournalEntryCreationScreenState();
}

class _JournalEntryCreationScreenState extends State<JournalEntryCreationScreen> {
  final _formKey = GlobalKey<FormState>();
  
  final _instrumentController = TextEditingController();
  final _entryPriceController = TextEditingController();
  final _exitPriceController = TextEditingController();
  final _notesController = TextEditingController();
  
  final JournalProvider _journalProvider = GetIt.I<JournalProvider>();
  final StrategyProvider _strategyProvider = GetIt.I<StrategyProvider>(); 

  String? _selectedStrategyId; 

  @override
  void dispose() {
    _instrumentController.dispose();
    _entryPriceController.dispose();
    _exitPriceController.dispose();
    _notesController.dispose();
    super.dispose();
  }

  /// Constrói o modelo e chama o Provider para persistir o novo lançamento.
  Future<void> _submitForm() async {
    if (_formKey.currentState?.validate() ?? false) {
      if (_selectedStrategyId == null) {
        if (mounted) {
          ScaffoldMessenger.of(context).showSnackBar(
            const SnackBar(content: Text('Por favor, selecione uma estratégia.')),
          );
        }
        return;
      }
      
      try {
        final newEntry = JournalEntryModel(
          id: 'temp_id-${DateTime.now().millisecondsSinceEpoch}', 
          instrument: _instrumentController.text,
          strategyId: _selectedStrategyId!,
          direction: 'BUY', 
          entryPrice: double.parse(_entryPriceController.text),
          exitPrice: double.parse(_exitPriceController.text),
          volume: 1.0, 
          pnl: double.parse(_exitPriceController.text) - double.parse(_entryPriceController.text), 
          entryDate: DateTime.now().subtract(const Duration(hours: 1)),
          exitDate: DateTime.now(),
          notes: _notesController.text.isNotEmpty ? _notesController.text : null,
        );
        
        await _journalProvider.createEntry(newEntry);
        
        if (mounted) context.router.pop();
        
      } catch (e) {
        if (mounted) {
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(content: Text('Falha ao registrar trade: ${e.toString()}')),
          );
        }
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    return ListenableBuilder(
      listenable: _journalProvider,
      builder: (context, child) {
        return AppLayout(
          isLoading: false, // O loading agora é tratado pelo botão
          appBar: AppBar(
            title: const Text('Novo Lançamento de Trading'),
          ),
          child: SingleChildScrollView(
            child: Form(
              key: _formKey,
              child: Column(
                children: [
                  // --- Input de Ativo ---
                  TextFormField(
                    controller: _instrumentController,
                    decoration: const InputDecoration(labelText: 'Ativo (Ex: BTC/USD)'),
                    validator: (v) => v!.isEmpty ? 'Campo obrigatório.' : null,
                  ),
                  const SizedBox(height: 16),
    
                  // --- Seleção de Estratégia ---
                  DropdownButtonFormField<String>(
                    decoration: const InputDecoration(labelText: 'Estratégia Utilizada'),
                    value: _selectedStrategyId,
                    items: const [
                       DropdownMenuItem(value: '1', child: Text('Estratégia Padrão 1')),
                       DropdownMenuItem(value: '2', child: Text('Estratégia Risco Baixo')),
                    ],
                    onChanged: (value) {
                      setState(() {
                        _selectedStrategyId = value;
                      });
                    },
                    validator: (v) => v == null ? 'Selecione uma estratégia.' : null,
                  ),
                  const SizedBox(height: 16),
                  
                  // --- Inputs de Preço ---
                  Row(
                    children: [
                      Expanded(
                        child: TextFormField(
                          controller: _entryPriceController,
                          decoration: const InputDecoration(labelText: 'Preço de Entrada'),
                          keyboardType: const TextInputType.numberWithOptions(decimal: true),
                          validator: (v) => v!.isEmpty ? 'Obrigatório.' : null,
                        ),
                      ),
                      const SizedBox(width: 16),
                      Expanded(
                        child: TextFormField(
                          controller: _exitPriceController,
                          decoration: const InputDecoration(labelText: 'Preço de Saída'),
                          keyboardType: const TextInputType.numberWithOptions(decimal: true),
                          validator: (v) => v!.isEmpty ? 'Obrigatório.' : null,
                        ),
                      ),
                    ],
                  ),
                  const SizedBox(height: 16),
    
                  // --- Notas ---
                  TextFormField(
                    controller: _notesController,
                    decoration: const InputDecoration(labelText: 'Notas e Lições (Opcional)'),
                    maxLines: 4,
                  ),
                  const SizedBox(height: 32),
    
                  // --- Botão de Submissão (Usando LoadingButton) ---
                  LoadingButton(
                    text: 'REGISTRAR TRADE',
                    isLoading: _journalProvider.isLoading,
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