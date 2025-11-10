import 'package:flutter_test/flutter_test.dart';
import 'package:mockito/annotations.dart';
import 'package:mockito/mockito.dart';

// Importações dos componentes a serem testados e dependências
import 'package:antibet_mobile/infra/services/lockdown_service.dart';
import 'package:antibet_mobile/notifiers/lockdown_notifier.dart';

// Gera o mock para a dependência
@GenerateMocks([LockdownService])
import 'lockdown_notifier_test.mocks.dart'; 

void main() {
  late MockLockdownService mockLockdownService;
  late LockdownNotifier lockdownNotifier;

  // Configuração executada antes de cada teste
  setUp(() {
    mockLockdownService = MockLockdownService();
    // Injeta o mock
    lockdownNotifier = LockdownNotifier(mockLockdownService); 
  });

  // Limpeza executada após cada teste
  tearDown(() {
    lockdownNotifier.dispose(); // Garante que o timer seja cancelado
    reset(mockLockdownService);
  });

  group('LockdownNotifier - Check Status (Initialization)', () {
    // --- Teste 1: Estado Inicial ---
    test('Estado inicial é isLoading=true e isLocked=false', () {
      expect(lockdownNotifier.isLoading, isTrue);
      expect(lockdownNotifier.isLocked, isFalse);
    });

    // --- Teste 2: Carregamento - Sem Bloqueio Ativo ---
    test('checkLockdownStatus: Sem bloqueio salvo, deve carregar e desbloquear', () async {
      // Configuração: Serviço não retorna timestamp (nulo)
      when(mockLockdownService.loadLockdownEndTime()).thenAnswer((_) async => null);
      
      await lockdownNotifier.checkLockdownStatus();

      // Verifica o estado final
      expect(lockdownNotifier.isLoading, isFalse);
      expect(lockdownNotifier.isLocked, isFalse);
      expect(lockdownNotifier.lockdownEndTime, isNull);
      verify(mockLockdownService.loadLockdownEndTime()).called(1);
    });

    // --- Teste 3: Carregamento - Com Bloqueio Ativo ---
    test('checkLockdownStatus: Com bloqueio salvo e futuro, deve carregar e bloquear', () async {
      final futureTime = DateTime.now().add(const Duration(hours: 1));
      // Configuração: Serviço retorna timestamp futuro
      when(mockLockdownService.loadLockdownEndTime()).thenAnswer((_) async => futureTime);
      
      await lockdownNotifier.checkLockdownStatus();

      // Verifica o estado final
      expect(lockdownNotifier.isLoading, isFalse);
      expect(lockdownNotifier.isLocked, isTrue);
      expect(lockdownNotifier.lockdownEndTime, futureTime);
    });

    // --- Teste 4: Carregamento - Com Bloqueio Expirado ---
    test('checkLockdownStatus: Com bloqueio salvo e passado, deve carregar e desbloquear', () async {
      final pastTime = DateTime.now().subtract(const Duration(hours: 1));
      // Configuração: Serviço retorna timestamp passado (lógica interna do service deve limpar)
      when(mockLockdownService.loadLockdownEndTime()).thenAnswer((_) async => null); // O service já limpa
      
      await lockdownNotifier.checkLockdownStatus();

      // Verifica o estado final
      expect(lockdownNotifier.isLoading, isFalse);
      expect(lockdownNotifier.isLocked, isFalse);
    });
  });

  group('LockdownNotifier - Activate Lockdown (Botão de Pânico)', () {
    // --- Teste 5: Ativação Bem-Sucedida ---
    test('activateLockdown: deve chamar save e iniciar o bloqueio', () async {
      const duration = Duration(hours: 24);
      // Configuração: Serviço de salvamento não retorna erro
      when(mockLockdownService.saveLockdownEndTime(any)).thenAnswer((_) async {});
      
      await lockdownNotifier.activateLockdown(duration);

      // Verifica o estado local
      expect(lockdownNotifier.isLocked, isTrue);
      expect(lockdownNotifier.lockdownEndTime, isNotNull);
      
      // Verifica se o serviço foi chamado para persistir o bloqueio
      verify(mockLockdownService.saveLockdownEndTime(any)).called(1);
    });

    // --- Teste 6: Falha na Ativação ---
    test('activateLockdown: deve lançar exceção se o serviço falhar', () async {
      const duration = Duration(hours: 24);
      // Configuração: Serviço de salvamento lança erro
      when(mockLockdownService.saveLockdownEndTime(any)).thenThrow(Exception('Falha de I/O'));
      
      // Verifica se a exceção é repassada para a UI
      expect(
        () => lockdownNotifier.activateLockdown(duration), 
        throwsA(isA<Exception>()),
      );
      
      // Estado não deve mudar
      expect(lockdownNotifier.isLocked, isFalse);
    });
  });

  group('LockdownNotifier - Auto Unlock Timer (FakeAsync)', () {
    // --- Teste 7: Desbloqueio Automático ---
    test('Notifier deve desbloquear automaticamente após o término do tempo', () async {
      // Usamos FakeAsync para controlar o tempo do Timer
      await fakeAsync((async) async {
        const duration = Duration(minutes: 10);
        
        // 1. Ativa o bloqueio
        when(mockLockdownService.saveLockdownEndTime(any)).thenAnswer((_) async {});
        await lockdownNotifier.activateLockdown(duration);
        
        expect(lockdownNotifier.isLocked, isTrue);

        // 2. Avança o tempo (9 minutos e 59 segundos)
        async.elapse(const Duration(minutes: 9, seconds: 59));
        // Força o processamento da fila de microtarefas
        await tester.pump(); 
        
        // Ainda deve estar bloqueado
        expect(lockdownNotifier.isLocked, isTrue);

        // 3. Avança o tempo restante (mais 2 segundos)
        async.elapse(const Duration(seconds: 2));
        await tester.pump(); 

        // 4. Deve estar desbloqueado
        expect(lockdownNotifier.isLocked, isFalse);
        expect(lockdownNotifier.lockdownEndTime, isNull);
        
        // Verifica se o serviço de limpeza foi chamado
        verify(mockLockdownService.clearLockdown()).called(1);
      });
    });
  });
}