import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:mockito/mockito.dart';

import 'package:antibet/src/core/services/auth_service.dart';
import 'package:antibet/src/core/notifiers/auth_notifier.dart';
import 'package:antibet/src/core/notifiers/behavioral_analytics_notifier.dart';

// Mocks
class MockAuthService extends Mock implements AuthService {
  @override
  Future<bool> checkAuthenticationStatus() => super.noSuchMethod(
        Invocation.method(#checkAuthenticationStatus, []),
        returnValue: Future.value(false),
      ) as Future<bool>;

  @override
  Future<bool> login(String email, String password) => super.noSuchMethod(
        Invocation.method(#login, [email, password]),
        returnValue: Future.value(false),
      ) as Future<bool>;

  @override
  Future<void> logout() => super.noSuchMethod(
        Invocation.method(#logout, []),
        returnValue: Future.value(null),
      ) as Future<void>;
}

class MockBehavioralAnalyticsNotifier extends Mock implements BehavioralAnalyticsNotifier {
  @override
  Future<void> recordBehavioralEvent(String eventType, [Map<String, dynamic>? details]) => super.noSuchMethod(
        Invocation.method(#recordBehavioralEvent, [eventType, details]),
        returnValue: Future.value(null),
      ) as Future<void>;
}

void main() {
  late MockAuthService mockAuthService;
  late MockBehavioralAnalyticsNotifier mockAnalyticsNotifier;
  late AuthNotifier notifier;

  setUp(() {
    mockAuthService = MockAuthService();
    mockAnalyticsNotifier = MockBehavioralAnalyticsNotifier();

    // Configuração inicial do Notifier
    notifier = AuthNotifier(mockAuthService);
    // Late-Binding é setado (simula o que ocorre no main.dart)
    notifier.setAnalyticsNotifier(mockAnalyticsNotifier);
  });
  
  group('AuthNotifier - Initialization and Status Check', () {
    test('checkAuthenticationStatus should load state from service and notify listeners', () async {
      // Setup: Mocka o serviço para retornar true (autenticado)
      when(mockAuthService.checkAuthenticationStatus()).thenAnswer((_) => Future.value(true));
      
      final listener = MockListener();
      notifier.addListener(listener);

      // Ação
      await notifier.checkAuthenticationStatus();

      // Verificação
      expect(notifier.isLoggedIn, isTrue);
      verify(mockAuthService.checkAuthenticationStatus()).called(1);
      verify(listener()).called(1);
      
      notifier.removeListener(listener);
    });
  });

  group('AuthNotifier - Login', () {
    test('login should update state to true, notify listeners, and record event on success', () async {
      // Setup: Mocka o serviço para retornar sucesso
      when(mockAuthService.login(any, any)).thenAnswer((_) => Future.value(true));
      
      final listener = MockListener();
      notifier.addListener(listener);

      // Ação
      final success = await notifier.login('test@inovexa.com', 'pass');

      // Verificação
      expect(success, isTrue);
      expect(notifier.isLoggedIn, isTrue);
      verify(listener()).called(1);
      
      // Verificação do Late-Binding
      verify(mockAnalyticsNotifier.recordBehavioralEvent('login_successful')).called(1);
      
      notifier.removeListener(listener);
    });

    test('login should NOT update state or notify listeners on failure', () async {
      // Setup: Mocka o serviço para retornar falha
      when(mockAuthService.login(any, any)).thenAnswer((_) => Future.value(false));
      
      final listener = MockListener();
      notifier.addListener(listener);

      // Ação
      final success = await notifier.login('test@inovexa.com', 'fail');

      // Verificação
      expect(success, isFalse);
      expect(notifier.isLoggedIn, isFalse);
      verifyNever(listener());
      
      // Verificação do Late-Binding (não deve ser chamado)
      verifyNever(mockAnalyticsNotifier.recordBehavioralEvent(any));

      notifier.removeListener(listener);
    });
  });

  group('AuthNotifier - Logout', () {
    test('logout should update state to false, notify listeners, and record event', () async {
      // Setup: Simula que o usuário está logado
      (notifier as dynamic)._isLoggedIn = true; 
      
      final listener = MockListener();
      notifier.addListener(listener);

      // Ação
      await notifier.logout();

      // Verificação
      expect(notifier.isLoggedIn, isFalse);
      verify(mockAuthService.logout()).called(1);
      verify(listener()).called(1);
      
      // Verificação do Late-Binding
      verify(mockAnalyticsNotifier.recordBehavioralEvent('logout')).called(1);

      notifier.removeListener(listener);
    });
  });
}

// Helper para testar se notifyListeners foi chamado
class MockListener extends Mock {
  void call();
}