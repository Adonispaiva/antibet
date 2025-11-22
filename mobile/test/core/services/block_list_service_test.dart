import 'package:flutter_test/flutter_test.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:antibet/src/core/services/block_list_service.dart';

void main() {
  // Chave de persistência (duplicada para o teste)
  const String blockListKey = 'user_block_list';
  late BlockListService service;

  // Domínios padrão internos (para referência no teste)
  const List<String> defaultDomains = ['blaze.com', 'bet365.com', 'pixbet.com', 'stake.com'];

  setUp(() async {
    // Limpa o mock de SharedPreferences antes de cada teste
    SharedPreferences.setMockInitialValues({});
    
    // Inicializa o serviço e aguarda o carregamento inicial das preferências
    service = BlockListService();
    // Forçamos o initPrefs a rodar
    await Future.delayed(Duration.zero);
  });

  group('BlockListService - Load and Default', () {
    test('getBlockList should contain all default domains upon initialization', () {
      final list = service.getBlockList();
      
      // Deve conter todos os domínios padrão
      for (var domain in defaultDomains) {
        expect(list, contains(domain));
      }
    });

    test('should load user-added items from SharedPreferences and merge with defaults', () async {
      // 1. Prepara o mock com itens adicionados pelo usuário
      SharedPreferences.setMockInitialValues({
        blockListKey: ['user-added-site.com', 'app-bloqueado.apk'],
      });

      // Recria o serviço para carregar o novo estado
      service = BlockListService();
      await Future.delayed(Duration.zero); // Espera o _initPrefs

      final list = service.getBlockList();
      
      // Deve conter os padrões E os adicionados
      expect(list, contains('user-added-site.com'));
      expect(list.length, equals(defaultDomains.length + 2)); 
    });
  });

  group('BlockListService - Add Item', () {
    test('addItem should add a new item and return true', () async {
      const newItem = 'new-gambling-site.com';
      
      final result = await service.addItem(newItem);
      
      expect(result, isTrue);
      final list = service.getBlockList();
      expect(list, contains(newItem));
      
      // Verifica a persistência
      final prefs = await SharedPreferences.getInstance();
      final savedList = prefs.getStringList(blockListKey);
      expect(savedList, contains(newItem));
    });

    test('addItem should fail if item is empty or already exists', () async {
      // Teste 1: Item vazio
      expect(await service.addItem(''), isFalse);
      
      // Teste 2: Item já existente (um padrão)
      expect(await service.addItem('blaze.com'), isFalse);
    });
  });

  group('BlockListService - Remove Item', () {
    test('removeItem should remove a user-added item and return true', () async {
      // 1. Adiciona um item para remover
      const userItem = 'removed-user-site.com';
      await service.addItem(userItem);
      
      final initialList = service.getBlockList();
      expect(initialList, contains(userItem));
      
      // 2. Ação: Remove o item
      final result = await service.removeItem(userItem);
      
      expect(result, isTrue);
      final finalList = service.getBlockList();
      expect(finalList, isNot(contains(userItem)));
      
      // Verifica a persistência (deve ter sido removido das SharedPreferences)
      final prefs = await SharedPreferences.getInstance();
      final savedList = prefs.getStringList(blockListKey);
      expect(savedList, isNot(contains(userItem)));
    });

    test('removeItem should fail and not remove default domains (Security Rule)', () async {
      // Tenta remover um domínio padrão
      const defaultDomain = 'bet365.com';
      final initialLength = service.getBlockList().length;

      final result = await service.removeItem(defaultDomain);
      
      // Deve falhar
      expect(result, isFalse);
      
      // O domínio deve permanecer na lista e o tamanho não deve mudar
      expect(service.getBlockList(), contains(defaultDomain));
      expect(service.getBlockList().length, equals(initialLength));
    });
  });
}