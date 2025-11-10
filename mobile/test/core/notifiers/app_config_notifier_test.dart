import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:mockito/mockito.dart';

import 'package:antibet/src/core/services/app_config_service.dart';
import 'package:antibet/src/core/notifiers/app_config_notifier.dart';

// Mocks
class MockAppConfigService extends Mock implements AppConfigService {
  @override
  Future<bool> loadDarkModeStatus() => super.noSuchMethod(
        Invocation.method(#loadDarkModeStatus, []),
        returnValue: Future.value(false), // Padrão é Modo Claro
      ) as Future<bool>;

  @override
  Future<void> setDarkModeStatus(bool isDarkMode) => super.noSuchMethod(
        Invocation.method(#setDarkModeStatus, [isDarkMode]),
        returnValue: Future.value(null),
      ) as Future<void>;
}

void main() {
  late MockAppConfigService mockService;
  late AppConfigNotifier notifier;

  setUp(() {
    mockService = MockAppConfigService();
    // Inicializa o Notifier com o mock. O construtor não chama loadConfig.
    notifier = AppConfigNotifier(mockService);
  });

  group('AppConfigNotifier - Initialization and Loading', () {
    test('loadConfig should load state from service and notify listeners', () async {
      // Setup: Mocka o serviço para retornar true (Modo Escuro)
      when(mockService.loadDarkModeStatus()).thenAnswer((_) => Future.value(true));
      
      final listener = MockListener();
      notifier.addListener(listener);

      // Ação
      await notifier.loadConfig();

      // Verificação
      expect(notifier.isDarkMode, isTrue);
      verify(mockService.loadDarkModeStatus()).called(1);
      verify(listener()).called(1);
      
      notifier.removeListener(listener);
    });

    test('Initial state should be false before loadConfig is called', () {
      // O estado é false no construtor antes do Future ser resolvido
      expect(notifier.isDarkMode, isFalse);
      verifyNever(mockService.loadDarkModeStatus());
    });
  });

  group('AppConfigNotifier - Toggle Dark Mode', () {
    test('toggleDarkMode should change state to true, persist, and notify listeners', () async {
      // Setup: Estado inicial falso
      (notifier as dynamic)._isDarkMode = false; 
      
      final listener = MockListener();
      notifier.addListener(listener);

      // Ação: Mudar para true
      await notifier.toggleDarkMode(true);

      // Verificação 1: O estado deve ser true
      expect(notifier.isDarkMode, isTrue);

      // Verificação 2: O serviço deve ser chamado para persistir
      verify(mockService.setDarkModeStatus(true)).called(1);
      
      // Verificação 3: O listener deve ser notificado
      verify(listener()).called(1);
      
      notifier.removeListener(listener);
    });
    
    test('toggleDarkMode should change state to false, persist, and notify listeners', () async {
      // Setup: Estado inicial true
      (notifier as dynamic)._isDarkMode = true; 
      
      final listener = MockListener();
      notifier.addListener(listener);

      // Ação: Mudar para false
      await notifier.toggleDarkMode(false);

      // Verificação 1: O estado deve ser false
      expect(notifier.isDarkMode, isFalse);

      // Verificação 2: O serviço deve ser chamado para persistir
      verify(mockService.setDarkModeStatus(false)).called(1);
      
      // Verificação 3: O listener deve ser notificado
      verify(listener()).called(1);
      
      notifier.removeListener(listener);
    });

    test('toggleDarkMode should not persist or notify if value is the same', () async {
      // Setup: Estado inicial true
      (notifier as dynamic)._isDarkMode = true; 
      
      final listener = MockListener();
      notifier.addListener(listener);

      // Ação: Tentar mudar para true (mesmo valor)
      await notifier.toggleDarkMode(true);

      // Verificação: O serviço NÃO deve ser chamado
      verifyNever(mockService.setDarkModeStatus(any));
      
      // Verificação: O listener NÃO deve ser notificado
      verifyNever(listener());

      notifier.removeListener(listener);
    });
  });
}

// Helper para testar se notifyListeners foi chamado
class MockListener extends Mock {
  void call();
}