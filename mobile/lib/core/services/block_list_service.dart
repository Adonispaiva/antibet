import 'package:shared_preferences/shared_preferences.dart';

// O Serviço de Lista de Bloqueio gerencia a lista de sites e aplicativos
// que o usuário deseja voluntariamente restringir.

class BlockListService {
  // Chave de persistência para a lista de bloqueio
  static const String _blockListKey = 'user_block_list';

  // Lista inicial de domínios conhecidos (base para a IA)
  final List<String> _initialDomains = const [
    'blaze.com', 
    'bet365.com', 
    'pixbet.com',
    'stake.com',
  ];
  
  // Lista de bloqueio persistente do usuário
  List<String> _userBlockList = [];

  // Armazena a referência às SharedPreferences
  late final SharedPreferences _prefs;

  BlockListService() {
    _initPrefs();
  }

  // Inicializa as SharedPreferences e carrega a lista
  Future<void> _initPrefs() async {
    _prefs = await SharedPreferences.getInstance();
    await _loadList();
  }

  // Carrega a lista do armazenamento local e mescla com a lista inicial
  Future<void> _loadList() async {
    final storedList = _prefs.getStringList(_blockListKey) ?? [];
    
    // Mescla a lista do usuário com a base inicial, garantindo exclusividade
    final combinedList = {..._initialDomains, ...storedList}.toList(); 
    _userBlockList = combinedList;
  }

  /// Retorna a lista atual de domínios e apps bloqueados.
  List<String> getBlockList() {
    return List.unmodifiable(_userBlockList);
  }

  /// Adiciona um novo item à lista de bloqueio.
  Future<bool> addItem(String item) async {
    final normalizedItem = item.toLowerCase().trim();
    if (normalizedItem.isEmpty || _userBlockList.contains(normalizedItem)) {
      return false;
    }
    
    _userBlockList.add(normalizedItem);
    await _saveList();
    print('Item adicionado à lista de bloqueio: $normalizedItem');
    return true;
  }

  /// Remove um item da lista de bloqueio (se não for um item inicial).
  Future<bool> removeItem(String item) async {
    final normalizedItem = item.toLowerCase().trim();
    
    // Proíbe a remoção dos domínios iniciais (regra de segurança do App)
    if (_initialDomains.contains(normalizedItem)) {
      print('Erro: Não é permitido remover domínios de alto risco padrão.');
      return false;
    }

    if (_userBlockList.remove(normalizedItem)) {
      await _saveList();
      print('Item removido da lista de bloqueio: $normalizedItem');
      return true;
    }
    return false;
  }

  // Salva a lista de bloqueio no SharedPreferences (apenas os itens adicionados pelo usuário, para evitar re-salvar a lista inicial)
  Future<void> _saveList() async {
    // Salva apenas os itens que não são da lista inicial (para manter a lista inicial imutável)
    final userOnlyList = _userBlockList.where((item) => !_initialDomains.contains(item)).toList();
    await _prefs.setStringList(_blockListKey, userOnlyList);
  }
}