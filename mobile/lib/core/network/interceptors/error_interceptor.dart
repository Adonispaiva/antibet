import 'package:dio/dio.dart';
import 'package:flutter/foundation.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:antibet/features/auth/providers/auth_provider.dart';

class ErrorInterceptor extends Interceptor {
  final Ref _ref;
  // Utiliza um Lock para prevenir que múltiplas requisições 401/403 tentem o logout simultaneamente
  final DioLock _lock = DioLock(); 

  ErrorInterceptor({required Ref ref}) : _ref = ref;

  @override
  void onError(DioException err, ErrorInterceptorHandler handler) async {
    final statusCode = err.response?.statusCode;
    
    // Verifica se o erro é de autenticação ou autorização
    if (statusCode == 401 || statusCode == 403) {
      if (kDebugMode) {
        debugPrint('AUTH ERROR DETECTED: Status $statusCode. Forcing logout.');
      }
      
      // 1. Bloqueia outras requisições
      _lock.lock();

      try {
        // 2. Chama a função de logout do AuthNotifier, que limpa o token localmente e invalida o estado.
        // Devemos usar read aqui para evitar que o interceptor tente reconstruir widgets.
        await _ref.read(authProvider.notifier).logout();
        
      } catch (e) {
        // Loga erro no logout, mas o estado já deve ter sido limpo localmente pelo AuthService
        if (kDebugMode) {
          debugPrint('Falha ao executar logout após 401/403: $e');
        }
      } finally {
        // 3. Desbloqueia as requisições pendentes
        _lock.unlock();
      }
      
      // 4. Se o logout for forçado, não é necessário re-enviar a requisição.
      // A UI será redirecionada automaticamente pelo MainAppWrapper.
      handler.reject(err);
      return;
    }
    
    // Para todos os outros erros, o handler padrão segue
    handler.next(err);
  }
}