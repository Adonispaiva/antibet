import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:go_router/go_router.dart';

// Importações dos notifiers e modelos
import '../../notifiers/bet_strategy_notifier.dart';
import '../../core/domain/bet_strategy_model.dart';
// Para tratamento de exceção

class BetStrategyFormView extends StatefulWidget {
  // Recebe a estratégia para edição (opcional, para criação)
  final BetStrategyModel? strategy; 

  const BetStrategyFormView({super.key, this.strategy});

  @override
  State<BetStrategyFormView> createState() => _BetStrategyFormViewState();
}

class _BetStrategyFormViewState extends State<BetStrategyFormView> {
  final _formKey = GlobalKey<FormState>();
  final TextEditingController _nameController = TextEditingController();
  final TextEditingController _descriptionController = TextEditingController();
  final TextEditingController _riskController = TextEditingController();
  
  bool _isLoading = false;
  late bool _isEditing;

  @override
  void initState() {
    super.initState();
    _isEditing = widget.strategy != null;
    if (_isEditing) {
      // Popula os controllers no modo de edição
      _nameController.text = widget.strategy!.name;
      _descriptionController.text = widget.strategy!.description;
      _riskController.text = (widget.strategy!.riskFactor * 100).toInt().toString();
    }
  }

  @override
  void dispose() {
    _nameController.dispose();
    _descriptionController.dispose();
    _riskController.dispose();
    super.dispose();
  }

  /// Manipula o salvamento e persiste a estratégia via Notifier
  Future<void> _handleSave() async {
    if (_formKey.currentState!.validate()) {
      setState(() {
        _isLoading = true;
      });

      final notifier = context.read<BetStrategyNotifier>();
      
      // Constrói o modelo a ser salvo
      final double riskFactor = double.tryParse(_riskController.text)! / 100.0;
      final strategyToSave = (_isEditing ? widget.strategy! : kDefaultBetStrategy).copyWith(
        id: _isEditing ? widget.strategy!.id : '', // ID vazio forçará a criação
        name: _nameController.text,
        description: _descriptionController.text,
        riskFactor: riskFactor,
      );

      try {
        await notifier.saveStrategy(strategyToSave);

        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('Estratégia ${_isEditing ? 'atualizada' : 'criada'} com sucesso!')),
        );
        // Volta para a tela anterior
        if (mounted) context.pop(); 

      } on BetStrategyException catch (e) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('Falha ao salvar: ${e.message}')),
        );
      } finally {
        if (mounted) {
          setState(() {
            _isLoading = false;
          });
        }
      }
    }
  }

  // Estratégia padrão para cópia no modo de criação
  static const kDefaultBetStrategy = BetStrategyModel(
    id: '', 
    name: '',
    description: '',
    riskFactor: 0.0,
    isActive: true,
  );

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text(_isEditing ? 'Editar Estratégia' : 'Nova Estratégia'),
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(16.0),
        child: Form(
          key: _formKey,
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: <Widget>[
              // Campo Nome
              TextFormField(
                controller: _nameController,
                decoration: const InputDecoration(labelText: 'Nome da Estratégia'),
                validator: (value) {
                  if (value == null || value.isEmpty) {
                    return 'O nome é obrigatório';
                  }
                  return null;
                },
              ),
              const SizedBox(height: 16),

              // Campo Descrição
              TextFormField(
                controller: _descriptionController,
                decoration: const InputDecoration(labelText: 'Descrição Detalhada'),
                maxLines: 3,
              ),
              const SizedBox(height: 16),

              // Campo Fator de Risco (Slider simplificado)
              TextFormField(
                controller: _riskController,
                decoration: const InputDecoration(
                  labelText: 'Fator de Risco (%)',
                  suffixText: '%',
                ),
                keyboardType: TextInputType.number,
                validator: (value) {
                  final risk = double.tryParse(value ?? '');
                  if (risk == null || risk < 0 || risk > 100) {
                    return 'O risco deve ser um número entre 0 e 100';
                  }
                  return null;
                },
              ),
              const SizedBox(height: 32),

              // Botão de Salvar
              Center(
                child: ElevatedButton(
                  onPressed: _isLoading ? null : _handleSave,
                  child: _isLoading
                      ? const CircularProgressIndicator(color: Colors.white)
                      : Text(_isEditing ? 'Salvar Alterações' : 'Criar Estratégia'),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}