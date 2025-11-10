import 'package:flutter/services.dart';
import 'package:flutter_test/flutter_test.dart';

import 'package:antibet/src/core/services/app_usage_tracker_service.dart';

void main() {
  TestWidgetsFlutterBinding.ensureInitialized();
  
  // Define o MethodChannel a ser mockado
  const MethodChannel channel = MethodChannel('com.inovexa.antibet/app_usage_tracker');
  late AppUsageTrackerService appUsageTrackerService;
  
  // Variável para armazenar o último método invocado e seus argumentos
  String? lastMethod;
  Map<String, dynamic>? lastArguments;

  setUp(() {
    appUsageTrackerService = AppUsageTrackerService();
    
    // Configura o handler de teste para o MethodChannel
    channel.setMockMethodCallHandler((MethodCall methodCall) async {
      lastMethod = methodCall.method;
      lastArguments = methodCall.arguments as Map<String, dynamic>?;

      switch (methodCall.method) {
        case 'checkUsagePermission':
          return true; // Padrão: permissão concedida
        case 'requestUsagePermission':
          return null; 
        case 'getUsageData':
          // Retorna dados mockados: 1 app de risco e 1 normal
          return [
            {
              'appName': 'com.blaze.app',
              'timeSpentMillis': 3600000, // 1 hora
              'isHighRisk': true,
            },
            {
              'appName': 'com.facebook.lite',
              'timeSpentMillis': 600000, // 10 minutos
              'isHighRisk': false,
            }
          ];
        default:
          throw PlatformException(code: 'UNIMPLEMENTED', message: 'Método não implementado no mock.');
      }
    });
  });

  tearDown(() {
    // Limpa o handler após cada teste
    channel.setMockMethodCallHandler(null);
  });

  group('AppUsageTrackerService - Permission Checks', () {
    test('checkUsagePermission returns true when native code confirms permission', () async {
      final isGranted = await appUsageTrackerService.checkUsagePermission();
      
      expect(isGranted, isTrue);
      expect(lastMethod, 'checkUsagePermission');
    });

    test('requestUsagePermission invokes the correct native method', () async {
      await appUsageTrackerService.requestUsagePermission();
      
      expect(lastMethod, 'requestUsagePermission');
    });

    test('checkUsagePermission returns false when PlatformException is caught', () async {
      // Configura o mock para lançar uma exceção
      channel.setMockMethodCallHandler((MethodCall methodCall) async {
        if (methodCall.method == 'checkUsagePermission') {
          throw PlatformException(code: 'PERMISSION_DENIED');
        }
        return null;
      });
      
      final isGranted = await appUsageTrackerService.checkUsagePermission();
      
      expect(isGranted, isFalse);
    });
  });

  group('AppUsageTrackerService - Get Usage Data', () {
    test('getUsageData calls getUsageData and correctly maps native data to Dart models', () async {
      final start = DateTime(2025, 1, 1);
      final end = DateTime(2025, 1, 2);
      
      final usageData = await appUsageTrackerService.getUsageData(start, end);
      
      // 1. Verifica a chamada do canal nativo
      expect(lastMethod, 'getUsageData');
      
      // 2. Verifica se os timestamps e a lista de apps de risco foram enviados
      expect(lastArguments!['startTimeMillis'], start.millisecondsSinceEpoch);
      expect(lastArguments!['endTimeMillis'], end.millisecondsSinceEpoch);
      expect(lastArguments!['riskApps'], isNotNull);
      
      // 3. Verifica o mapeamento e o conteúdo dos dados
      expect(usageData.length, 2);
      
      // Dados do primeiro app (Risco Alto)
      final highRiskApp = usageData.first;
      expect(highRiskApp.appName, 'com.blaze.app');
      expect(highRiskApp.timeSpent, const Duration(hours: 1));
      expect(highRiskApp.isHighRisk, isTrue);

      // Dados do segundo app (Risco Normal)
      final lowRiskApp = usageData.last;
      expect(lowRiskApp.appName, 'com.facebook.lite');
      expect(lowRiskApp.timeSpent, const Duration(minutes: 10));
      expect(lowRiskApp.isHighRisk, isFalse);
    });

    test('getUsageData returns empty list when PlatformException is caught', () async {
      // Configura o mock para lançar uma exceção
      channel.setMockMethodCallHandler((MethodCall methodCall) async {
        if (methodCall.method == 'getUsageData') {
          throw PlatformException(code: 'API_ERROR', message: 'Erro ao acessar API nativa.');
        }
        return null;
      });
      
      final start = DateTime.now();
      final end = DateTime.now();
      
      final usageData = await appUsageTrackerService.getUsageData(start, end);
      
      expect(usageData, isEmpty);
    });
  });
}