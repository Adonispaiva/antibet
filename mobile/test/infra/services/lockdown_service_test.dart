import 'package:flutter_test/flutter_test.dart';

// Importações dos componentes a serem testados
import 'package:antibet_mobile/infra/services/lockdown_service.dart';

// Importação interna para limpar o mock storage
import 'package:antibet_mobile/infra/services/lockdown_service.dart' show _LocalLockdownStorage;

void main {
  late LockdownService lockdownService;
  
  setUp(() {
    // Instancia o serviço
    lockdownService = LockdownService(); 
  });

  tearDown(() {
    // Limpa o armazenamento estático simulado entre os testes
    _LocalLockdownStorage.clearAll();
  });

  group('LockdownService Tests', () {
    
    // --- Teste 1: Carregamento Inicial (Nulo) ---
    test('loadLockdownEndTime deve retornar nulo se nenhum bloqueio foi salvo', () async {
      final endTime = await lockdownService.loadLockdownEndTime();
      expect(endTime, isNull);
    });

    // --- Teste 2: Salvar e Carregar (Bloqueio Futuro) ---
    test('saveLockdownEndTime deve persistir um timestamp futuro', () async {
      final futureTime = DateTime.now().add(const Duration(hours: 1));
      
      await lockdownService.saveLockdownEndTime(futureTime);
      
      final loadedTime = await lockdownService.loadLockdownEndTime();
      
      // Compara os milissegundos para garantir precisão
      expect(loadedTime?.toIso8601String(), futureTime.toIso8601String());
    });

    // --- Teste 3: Carregamento de Bloqueio Expirado ---
    test('loadLockdownEndTime deve retornar nulo se o timestamp estiver no passado', () async {
      final pastTime = DateTime.now().subtract(const Duration(minutes: 1));

      // 1. Salva o tempo no passado
      await lockdownService.saveLockdownEndTime(pastTime);
      
      // 2. Tenta carregar (o serviço deve limpar automaticamente)
      final loadedTime = await lockdownService.loadLockdownEndTime();
      
      expect(loadedTime, isNull);
    });
    
    // --- Teste 4: Limpeza de Bloqueio (clearLockdown) ---
    test('clearLockdown deve remover um bloqueio ativo', () async {
      final futureTime = DateTime.now().add(const Duration(hours: 1));
      
      // 1. Salva o bloqueio
      await lockdownService.saveLockdownEndTime(futureTime);
      final loadedTime = await lockdownService.loadLockdownEndTime();
      expect(loadedTime, isNotNull); // Confirma que foi salvo

      // 2. Limpa o bloqueio
      await lockdownService.clearLockdown();
      
      // 3. Verifica se foi limpo
      final finalTime = await lockdownService.loadLockdownEndTime();
      expect(finalTime, isNull);
    });
  });
}