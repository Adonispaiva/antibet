import 'package:flutter/services.dart';
// Necessário para Duration, embora não seja o foco

// Este serviço é a ponte entre o Flutter e o código nativo (Kotlin/Swift)
// para monitorar o tempo de uso de aplicativos/sites (crucial para o Analytics).

class AppUsageData {
  final String appName;
  final Duration timeSpent;
  final bool isHighRisk; // Indica se é um app de aposta ou rede social excessiva

  AppUsageData({
    required this.appName,
    required this.timeSpent,
    required this.isHighRisk,
  });

  // Converte o Map nativo (ex: JSON) para o modelo Dart
  factory AppUsageData.fromMap(Map<String, dynamic> map) {
    return AppUsageData(
      appName: map['appName'] as String,
      // O tempo é geralmente passado em milissegundos do nativo
      timeSpent: Duration(milliseconds: map['timeSpentMillis'] as int), 
      isHighRisk: map['isHighRisk'] as bool,
    );
  }
}

class AppUsageTrackerService {
  // Canal de comunicação com o código nativo (Kotlin/Swift)
  static const MethodChannel _channel = MethodChannel('com.inovexa.antibet/app_usage_tracker');
  
  // Apps de alto risco conhecidos que o serviço nativo monitorará
  static const List<String> HIGH_RISK_APPS = [
    'com.blaze.app', 
    'com.bet365.mobile', 
    'com.facebook.lite', // Exemplo de app que pode ser gatilho
  ];

  /// 1. Verifica se a permissão de Acesso ao Uso (Usage Stats) está concedida.
  Future<bool> checkUsagePermission() async {
    try {
      // Chama o método nativo para verificar o status
      final bool granted = await _channel.invokeMethod('checkUsagePermission');
      return granted;
    } on PlatformException catch (e) {
      print("Falha ao verificar permissão de uso: ${e.message}");
      return false;
    }
  }

  /// 2. Solicita as permissões necessárias ao usuário, abrindo a tela de configurações.
  Future<void> requestUsagePermission() async {
    try {
      await _channel.invokeMethod('requestUsagePermission');
    } on PlatformException catch (e) {
      print("Falha ao solicitar permissão de uso: ${e.message}");
    }
  }

  /// 3. Busca os dados de uso para o período especificado.
  Future<List<AppUsageData>> getUsageData(DateTime start, DateTime end) async {
    try {
      // Chama o método nativo com os timestamps
      final List<dynamic> result = await _channel.invokeMethod(
        'getUsageData',
        {
          'startTimeMillis': start.millisecondsSinceEpoch,
          'endTimeMillis': end.millisecondsSinceEpoch,
          'riskApps': HIGH_RISK_APPS,
        },
      );

      // Converte a lista de Maps nativos para a lista de modelos Dart
      return result.map((map) => AppUsageData.fromMap(map as Map<String, dynamic>)).toList();
    } on PlatformException catch (e) {
      print("Falha ao buscar dados de uso: ${e.message}");
      return [];
    }
  }
}