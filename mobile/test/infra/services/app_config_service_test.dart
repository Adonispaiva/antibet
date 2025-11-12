import 'package:flutter_test/flutter_test.dart';
import 'package:antibet_mobile/infra/services/app_config_service.dart';

// =========================================================================
// SIMULAÇÃO DE DEPENDÊNCIAS (Mocks)
// =========================================================================

// Mock da classe de Serviço de Configuração
class AppConfigService {
  AppConfigService();
  bool shouldThrowError = false;

  // Simula a busca de uma configuração simples (ex: Versão, Chave Pública)
  Future<Map<String, dynamic>> getConfiguration() async {
    if (shouldThrowError) {
      throw Exception('Falha ao carregar configurações da API.');
    }
    
    // Simulação de chamada de rede
    await Future.delayed(Duration.zero);

    return {
      'appVersion': '1.0.0',
      'isMaintenanceMode': false,
      'publicApiKey': 'PUBKEY_12345',
    };
  }
}

// =========================================================================
// FIM DA SIMULAÇÃO
// =========================================================================

void main() {
  group('AppConfigService Unit Tests', () {
    late AppConfigService configService;

    setUp(() {
      configService = AppConfigService();
    });

    test('01. getConfiguration deve retornar um mapa de configuração válido', () async {
      final config = await configService.getConfiguration();

      expect(config, isA<Map<String, dynamic>>());
      expect(config['appVersion'], '1.0.0');
      expect(config['isMaintenanceMode'], false);
    });

    test('02. getConfiguration deve lançar exceção em caso de falha de API', () async {
      configService.shouldThrowError = true;

      expect(
        () => configService.getConfiguration(),
        throwsA(isA<Exception>()),
      );
    });
  });
}