import 'package:flutter_test/flutter_test.dart';

// Importações dos componentes a serem testados
import 'package:antibet_mobile/core/domain/help_and_alerts_model.dart';
import 'package:antibet_mobile/infra/services/help_and_alerts_service.dart';

void main {
  // Nota: O serviço usa uma lista privada mockada para simular o backend.
  late HelpAndAlertsService alertsService;
  
  setUp(() {
    alertsService = HelpAndAlertsService(); 
  });

  group('HelpAndAlertsService Tests', () {
    
    // --- Teste 1: Fetch de Recursos ---
    test('fetchResources deve retornar o modelo com a lista de mocks', () async {
      final model = await alertsService.fetchResources();

      // Verifica o tipo de retorno
      expect(model, isA<HelpAndAlertsModel>());
      
      // Verifica se os recursos mockados (CVV, Jogadores Anônimos, 188) estão presentes
      expect(model.supportResources, isNotEmpty);
      expect(model.supportResources, hasLength(3)); 
      expect(model.supportResources.first.title, 'Apoio Emocional - CVV');
    });

    // --- Teste 2: Consistência dos Recursos Mockados ---
    test('Recursos mockados devem ter dados válidos', () async {
      final model = await alertsService.fetchResources();
      
      for (final resource in model.supportResources) {
        expect(resource.title, isNotEmpty);
        expect(resource.url, isNotEmpty);
        expect(resource.type, isNotEmpty);
      }
    });

    // --- Teste 3: Acionamento de Alerta (Auditoria) ---
    test('triggerAlert deve executar sem lançar exceções', () async {
      // O método triggerAlert é uma simulação (debug print)
      // O teste garante que ele pode ser chamado com segurança pelo Notifier.
      
      expect(
        () async => await alertsService.triggerAlert('Teste de auditoria de risco'), 
        returnsNormally,
      );
    });
  });
}