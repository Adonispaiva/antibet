import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

import 'package:antibet/src/core/notifiers/block_list_notifier.dart';
import 'package:antibet/src/core/services/block_list_service.dart'; // Para acessar o modelo

class AutoblockSettingsView extends StatefulWidget {
  const AutoblockSettingsView({super.key});

  @override
  State<AutoblockSettingsView> createState() => _AutoblockSettingsViewState();
}

class _AutoblockSettingsViewState extends State<AutoblockSettingsView> {
  final TextEditingController _itemController = TextEditingController();
  final _formKey = GlobalKey<FormState>();
  
  String? _message;
  
  @override
  void initState() {
    super.initState();
    // Garante que a lista seja carregada ao entrar na tela (se não foi carregada antes)
    WidgetsBinding.instance.addPostFrameCallback((_) {
      context.read<BlockListNotifier>().loadBlockList();
    });
  }

  Future<void> _addItem() async {
    if (!_formKey.currentState!.validate()) return;
    
    final item = _itemController.text.trim().toLowerCase();
    final success = await context.read<BlockListNotifier>().addItem(item);
    
    setState(() {
      if (success) {
        _message = 'Item "$item" adicionado com sucesso.';
        _itemController.clear();
      } else {
        _message = 'Erro: O domínio "$item" já está na lista ou é inválido.';
      }
    });
    // Limpa a mensagem após um tempo
    _clearMessageAfterDelay();
  }

  Future<void> _removeItem(String item) async {
    final success = await context.read<BlockListNotifier>().removeItem(item);

    setState(() {
      if (success) {
        _message = 'Item "$item" removido da sua lista.';
      } else {
        // Regra de segurança: falha ao tentar remover um item padrão
        _message = 'Atenção: Itens de alto risco padrão não podem ser removidos.';
      }
    });
    _clearMessageAfterDelay();
  }
  
  void _clearMessageAfterDelay() {
    Future.delayed(const Duration(seconds: 4), () {
      if (mounted) {
        setState(() {
          _message = null;
        });
      }
    });
  }

  @override
  Widget build(BuildContext context) {
    final notifier = context.watch<BlockListNotifier>();
    
    // Simulação dos domínios padrão (para destacar na UI)
    final BlockListService mockService = BlockListService();
    final List<String> defaultDomains = mockService.getBlockList().where((item) => item.contains('.com') || item.contains('.net')).toList().take(4).toList(); // Pega os 4 primeiros
    
    return Scaffold(
      appBar: AppBar(
        title: const Text('Gerenciar Bloqueios'),
        backgroundColor: Colors.deepOrange,
        foregroundColor: Colors.white,
      ),
      body: Column(
        children: <Widget>[
          // Área de Mensagens de Feedback
          if (_message != null)
            Padding(
              padding: const EdgeInsets.symmetric(vertical: 10, horizontal: 20),
              child: Text(_message!, style: TextStyle(color: _message!.startsWith('Erro') || _message!.startsWith('Atenção') ? Colors.red : Colors.green[700])),
            ),
            
          // Formulário de Adição
          Card(
            margin: const EdgeInsets.all(16.0),
            child: Padding(
              padding: const EdgeInsets.all(16.0),
              child: Form(
                key: _formKey,
                child: Row(
                  children: [
                    Expanded(
                      child: TextFormField(
                        controller: _itemController,
                        decoration: const InputDecoration(
                          labelText: 'Adicionar Site/App (Ex: nomedosite.com)',
                          border: OutlineInputBorder(),
                        ),
                        validator: (value) => value == null || value.isEmpty ? 'Insira um domínio válido.' : null,
                      ),
                    ),
                    const SizedBox(width: 10),
                    ElevatedButton(
                      onPressed: _addItem,
                      style: ElevatedButton.styleFrom(
                        backgroundColor: Colors.deepOrange,
                        padding: const EdgeInsets.symmetric(vertical: 18),
                      ),
                      child: const Icon(Icons.add, color: Colors.white),
                    ),
                  ],
                ),
              ),
            ),
          ),
          
          _buildSectionTitle(context, 'Itens Bloqueados (${notifier.blockList.length})'),
          
          // Lista de Itens Bloqueados
          Expanded(
            child: ListView.builder(
              itemCount: notifier.blockList.length,
              itemBuilder: (context, index) {
                final item = notifier.blockList[index];
                final isDefault = defaultDomains.contains(item);
                
                return Card(
                  elevation: 0.5,
                  margin: const EdgeInsets.symmetric(horizontal: 16.0, vertical: 4.0),
                  child: ListTile(
                    leading: Icon(
                      isDefault ? Icons.lock : Icons.block,
                      color: isDefault ? Colors.red[800] : Colors.grey[600],
                    ),
                    title: Text(item),
                    subtitle: isDefault ? const Text('Bloqueio Padrão (Não Removível)', style: TextStyle(color: Colors.red)) : null,
                    trailing: isDefault 
                      ? null 
                      : IconButton(
                          icon: const Icon(Icons.delete_outline, color: Colors.grey),
                          onPressed: () => _removeItem(item),
                        ),
                  ),
                );
              },
            ),
          ),
        ],
      ),
    );
  }
  
  Widget _buildSectionTitle(BuildContext context, String title) {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 16.0, vertical: 8.0),
      child: Align(
        alignment: Alignment.centerLeft,
        child: Text(
          title,
          style: TextStyle(
            fontSize: 16,
            fontWeight: FontWeight.bold,
            color: Colors.blueGrey[800],
          ),
        ),
      ),
    );
  }
}