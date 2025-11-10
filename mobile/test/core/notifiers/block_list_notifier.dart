import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:mockito/mockito.dart';

import 'package:antibet/src/core/services/block_list_service.dart';
import 'package:antibet/src/core/notifiers/block_list_notifier.dart';

// Mocks
class MockBlockListService extends Mock implements BlockListService {
  // Lista inicial para simulação de estado
  final List<String> _mockList = ['blaze.com', 'user-added.net'];

  @override
  List<String> getBlockList() {
    return List.from(_mockList);
  }

  @override
  Future<bool> addItem(String item) {
    if (!_mockList.contains(item)) {
      _mockList.add(item);
      return Future.value(true);
    }
    return Future.value(false);
  }

  @override
  Future<bool> removeItem(String item) {
    if (_mockList.contains(item) && item != 'blaze.com') { // Simula a regra de não remover padrão
      _mockList.remove(item);
      return Future.value(true);
    }
    return Future.value(false);
  }

  // Simula o initPrefs
  @override
  Future<void> _initPrefs() => super.noSuchMethod(
        Invocation.method(#_initPrefs, []),
        returnValue: Future.value(null),
      ) as Future<void>;
  
  // Simula o loadList
  @override
  Future<void> _loadList() => super.noSuchMethod(
        Invocation.method(#_loadList, []),
        returnValue: Future.value(null),
      ) as Future<void>;
}

// Helper para testar se notifyListeners foi chamado
class MockListener extends Mock {
  void call();
}

void main() {
  late MockBlockListService mockService;
  late BlockListNotifier notifier;

  setUp(() {
    mockService = MockBlockListService();
    // Força a simulação da inicialização do serviço antes do notifier
    when(mockService._initPrefs()).thenAnswer((_) => Future.value(null));
    when(mockService._loadList()).thenAnswer((_) => Future.value(null));
    
    // Inicializa o Notifier. O construtor chama loadBlockList().
    notifier = BlockListNotifier(mockService);
  });
  
  group('BlockListNotifier - Initialization and Getters', () {
    test('loadBlockList should initialize blockList with data from service', () async {
      // O construtor chama loadBlockList, mas precisamos esperar o Future.delayed(Duration.zero) interno
      await Future.delayed(Duration.zero); 
      
      // Verifica o estado inicial (do mock)
      expect(notifier.blockList, isNotEmpty);
      expect(notifier.blockList.length, equals(2));
      expect(notifier.blockList, contains('blaze.com'));
    });
    
    test('isItemBlocked should return true for a blocked item', () async {
      await Future.delayed(Duration.zero); 
      expect(notifier.isItemBlocked('blaze.com'), isTrue);
      expect(notifier.isItemBlocked('user-added.net'), isTrue);
    });
    
    test('isItemBlocked should return false for an unblocked item', () async {
      await Future.delayed(Duration.zero); 
      expect(notifier.isItemBlocked('google.com'), isFalse);
    });
  });

  group('BlockListNotifier - Operations and Reactivity', () {
    test('addItem should update list, call service, and notify listeners', () async {
      await Future.delayed(Duration.zero); 
      const newItem = 'new-site.com';
      final initialLength = notifier.blockList.length;

      final listener = MockListener();
      notifier.addListener(listener);

      // Ação
      final result = await notifier.addItem(newItem);

      // Verificações
      expect(result, isTrue);
      verify(mockService.addItem(newItem)).called(1);
      verify(listener()).called(1);
      
      // Verifica o estado atualizado
      expect(notifier.blockList.length, equals(initialLength + 1));
      expect(notifier.blockList, contains(newItem));
      
      notifier.removeListener(listener);
    });

    test('removeItem should update list, call service, and notify listeners', () async {
      await Future.delayed(Duration.zero); 
      const itemToRemove = 'user-added.net';
      final initialLength = notifier.blockList.length;

      final listener = MockListener();
      notifier.addListener(listener);

      // Ação
      final result = await notifier.removeItem(itemToRemove);

      // Verificações
      expect(result, isTrue);
      verify(mockService.removeItem(itemToRemove)).called(1);
      verify(listener()).called(1);
      
      // Verifica o estado atualizado
      expect(notifier.blockList.length, equals(initialLength - 1));
      expect(notifier.blockList, isNot(contains(itemToRemove)));
      
      notifier.removeListener(listener);
    });
    
    test('addItem should not notify listeners if service returns false (item already exists)', () async {
      await Future.delayed(Duration.zero); 
      const existingItem = 'blaze.com';

      final listener = MockListener();
      notifier.addListener(listener);
      
      // Ação (Mock service retorna false pois já existe)
      final result = await notifier.addItem(existingItem);
      
      expect(result, isFalse);
      verifyNever(listener());
      
      notifier.removeListener(listener);
    });
  });
}