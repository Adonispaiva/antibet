import 'package:flutter_test/flutter_test.dart';
import 'package:mockito/mockito.dart';
import 'package:antibet/src/core/services/lockdown_service.dart';
import 'package:antibet/src/core/notifiers/lockdown_notifier.dart';
import 'package:antibet/src/core/notifiers/behavioral_analytics_notifier.dart';

// Importa para usar expectLater
import 'package:matcher/matcher.dart';

// Mocks
class MockLockdownService extends Mock implements LockdownService {
  @override
  Future<bool> isLockdownActive() => super.noSuchMethod(
        Invocation.method(#isLockdownActive, []),
        returnValue: Future.value(false),
      ) as Future<bool>;
  
  @override
  Future<void> activateLockdown() => super.noSuchMethod(
        Invocation.method(#activateLockdown, []),
        returnValue: Future.value(null),
      ) as Future<void>;

  @override
  Future<void> deactivateLockdown() => super.noSuchMethod(
        Invocation.method(#deactivateLockdown, []),
        returnValue: Future.value(null),
      ) as Future<void>;
}

class MockBehavioralAnalyticsNotifier extends Mock implements BehavioralAnalyticsNotifier {
  @override
  void recordPanicIntervention() => super.noSuchMethod(
        Invocation.method(#recordPanicIntervention, []),
        returnValue: null,
      );
}

void main() {
  late MockLockdownService mockService;
  late MockBehavioralAnalyticsNotifier mockAnalyticsNotifier;
  late LockdownNotifier notifier;

  setUp(() {
    mockService = MockLockdownService();
    mockAnalyticsNotifier = MockBehavioralAnalyticsNotifier();
    
    // Configura o mock inicial para retornar 'falso' por padrão
    when(mockService.isLockdownActive()).thenAnswer((_) => Future.value(false));

    // Inicializa o notifier. O construtor chama checkLockdownStatus.
    notifier = LockdownNotifier(service: mockService);
    notifier.setAnalyticsNotifier(mockAnalyticsNotifier);
  });

  group('LockdownNotifier - Initialization and State', () {
    test('Should check initial status upon creation', () {
      // Verifica se o método de serviço foi chamado na inicialização
      verify(mockService.isLockdownActive()).called(1);
      // O estado inicial deve ser falso (mock padrão)
      expect(notifier.isLockdownActive, isFalse);
    });

    test('Should update state correctly when loading active status', () async {
      // Configura o mock para retornar 'verdadeiro'
      when(mockService.isLockdownActive()).thenAnswer((_) => Future.value(true));
      
      // Chama a checagem novamente
      await notifier.checkLockdownStatus();

      // Verifica o novo estado
      expect(notifier.isLockdownActive, isTrue);
      // O service.isLockdownActive deve ter sido chamado duas vezes (setup + check)
      verify(mockService.isLockdownActive()).called(2); 
    });
  });

  group('LockdownNotifier - Activation', () {
    test('Should call service to activate and notify listeners', () async {
      // Garante que o estado de notificação será testado
      when(mockService.isLockdownActive()).thenAnswer((_) => Future.value(false)); // Inicialmente false
      
      final listener = MockListener();
      notifier.addListener(listener);

      // Simula a ativação
      await notifier.activateLockdown();

      // O serviço deve ser chamado para ativar
      verify(mockService.activateLockdown()).called(1);
      // O analytics deve ser notificado sobre a intervenção de pânico
      verify(mockAnalyticsNotifier.recordPanicIntervention()).called(1);
      
      // checkLockdownStatus é chamado novamente para atualizar o estado
      verify(mockService.isLockdownActive()).called(2); 

      // Um listener deve ser notificado (notifyListeners)
      verify(listener()).called(1);
      
      notifier.removeListener(listener);
    });
  });

  group('LockdownNotifier - Deactivation', () {
    test('Should call service to deactivate and notify listeners on success', () async {
      // Simula que o serviço permite a desativação (não lança exceção)
      when(mockService.isLockdownActive()).thenAnswer((_) => Future.value(false));
      
      final listener = MockListener();
      notifier.addListener(listener);

      // Simula a desativação
      final result = await notifier.deactivateLockdown();

      // Deve ter tentado desativar
      verify(mockService.deactivateLockdown()).called(1);
      
      // Deve retornar true em caso de sucesso
      expect(result, isTrue);

      // Um listener deve ser notificado
      verify(listener()).called(1);
      
      notifier.removeListener(listener);
    });

    test('Should handle deactivation failure (time rule) and return false', () async {
      // Simula que o serviço falha/lança exceção (Regra de tempo de segurança)
      when(mockService.deactivateLockdown()).thenThrow(Exception("Tentativa de desativação antes do período mínimo."));
      
      // Simula a desativação
      final result = await notifier.deactivateLockdown();

      // Deve ter tentado desativar
      verify(mockService.deactivateLockdown()).called(1);
      
      // Deve retornar false em caso de falha/erro
      expect(result, isFalse);
      
      // notifyListeners não deve ser chamado em caso de falha, pois o estado não muda.
      verifyNever(() => notifier.notifyListeners());
    });
  });
}

// Helper para testar se notifyListeners foi chamado
class MockListener extends Mock {
  void call();
}