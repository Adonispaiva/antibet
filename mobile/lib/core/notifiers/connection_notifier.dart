import 'package:flutter/foundation.dart';

/// Notifier responsável por gerenciar o estado da conexão de rede do aplicativo.
/// Isso permite que a UI reaja a perdas de conexão, exibindo alertas.
class ConnectionNotifier extends ChangeNotifier {
  // Estado que reflete se o aplicativo está conectado à internet.
  // Assume-se conectado por padrão até que um check real seja feito.
  bool _isConnected = true;
  
  // Getter público para acessar o estado da conexão.
  bool get isConnected => _isConnected;

  /// Método para verificar e atualizar o estado da conexão.
  /// No futuro, usará uma dependência de terceiros (Ex: connectivity_plus).
  Future<void> checkConnectionStatus() async {
    // Simulação de delay para a checagem de rede.
    await Future.delayed(const Duration(milliseconds: 1500));
    
    // Por enquanto, apenas um placeholder para um check de rede simulado.
    // Para fins de teste inicial, mantemos como true.
    const bool currentStatus = true; 

    if (_isConnected != currentStatus) {
      _isConnected = currentStatus;
      // Notifica a UI apenas se o estado mudar.
      notifyListeners();
    }
  }

  /// Define explicitamente o estado da conexão (útil para simulação/testes).
  void setConnectionStatus(bool status) {
    if (_isConnected != status) {
      _isConnected = status;
      notifyListeners();
    }
  }
}