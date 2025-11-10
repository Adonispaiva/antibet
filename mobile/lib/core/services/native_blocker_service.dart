import 'package:flutter/services.dart';
import 'package:antibet/src/core/services/block_list_service.dart';

// Este serviço é a ponte entre o Flutter e o código nativo (Kotlin/Swift)
// para implementar o bloqueio real de sites/aplicativos.

class NativeBlockerService {
  // Canal de comunicação com o código nativo (Kotlin/Swift)
  static const MethodChannel _channel = MethodChannel('com.inovexa.antibet/native_blocker');

  final BlockListService _blockListService;

  NativeBlockerService(this._blockListService);

  /// 1. Verifica se a permissão necessária (Acessibilidade/VPN) está concedida.
  Future<bool> isPermissionGranted() async {
    try {
      // Chama o método nativo para verificar o status
      final bool granted = await _channel.invokeMethod('isPermissionGranted');
      return granted;
    } on PlatformException catch (e) {
      print("Falha ao verificar permissão: ${e.message}");
      return false;
    }
  }

  /// 2. Solicita as permissões necessárias ao usuário (Acessibilidade/VPN).
  Future<void> requestPermission() async {
    try {
      await _channel.invokeMethod('requestPermission');
    } on PlatformException catch (e) {
      print("Falha ao solicitar permissão: ${e.message}");
    }
  }

  /// 3. Envia a lista atual de domínios/apps para o serviço de bloqueio nativo.
  /// O serviço nativo fará o monitoramento e a interrupção.
  Future<bool> updateNativeBlockList() async {
    final List<String> currentBlockList = _blockListService.getBlockList();
    
    try {
      // Chama o método nativo com a lista completa
      final bool success = await _channel.invokeMethod(
        'updateBlockList',
        {'blockList': currentBlockList},
      );
      print('Lista de bloqueio enviada ao nativo. Sucesso: $success');
      return success;
    } on PlatformException catch (e) {
      print("Falha ao atualizar lista nativa: ${e.message}");
      return false;
    }
  }

  /// 4. Monitora o status do serviço nativo (ex: se o serviço de acessibilidade foi morto pelo SO)
  Future<bool> isBlockerActive() async {
    try {
      final bool isActive = await _channel.invokeMethod('isBlockerActive');
      return isActive;
    } on PlatformException catch (e) {
      print("Falha ao verificar status do bloqueador: ${e.message}");
      return false;
    }
  }
}