import 'package:dio/dio.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:mocktail/mocktail.dart';
import 'package:go_router/go_router.dart';
import 'package:antibet/core/network/interceptors/auth_interceptor.dart';
import 'package:antibet/features/auth/presentation/providers/auth_provider.dart';

// Mocks
class MockAuthNotifier extends StateNotifier<AuthState> with Mock implements AuthNotifier {}
class MockRequestInterceptorHandler extends Mock implements RequestInterceptorHandler {}
class MockErrorInterceptorHandler extends Mock implements ErrorInterceptorHandler {}
class MockNavigatorState extends Mock implements NavigatorState {}

void main() {
  late ProviderContainer container;
  late MockAuthNotifier mockAuthNotifier;
  late AuthInterceptor authInterceptor;
  late MockRequestInterceptorHandler mockRequestHandler;
  late MockErrorInterceptorHandler mockErrorHandler;

  setUp(() {
    // Inicializa o mock do Notifier
    mockAuthNotifier = MockAuthNotifier();
    
    // Inicializa o container com o provider de autenticação sobrescrito
    container = ProviderContainer(
      overrides: [
        authProvider.overrideWith((ref) => mockAuthNotifier),
      ],
    );

    // Inicializa o interceptor
    authInterceptor = AuthInterceptor(container.read);
    
    // Inicializa os mocks de handler
    mockRequestHandler = MockRequestInterceptorHandler();
    mockErrorHandler = MockErrorInterceptorHandler();
    
    // Registra fallback para RequestOptions e DioException
    registerFallbackValue(RequestOptions(path: '/test'));
    registerFallbackValue(DioException(requestOptions: RequestOptions(path: '/test')));
  });

  tearDown(() {
    container.dispose();
  });

  group('AuthInterceptor - onRequest', () {
    const tToken = 'test-jwt-token';
    final tRequestOptions = RequestOptions(path: '/secure-data');

    test('should add Authorization header when token is present', () {
      // Arrange
      when(() => mockAuthNotifier.state).thenReturn(const AuthState(token: tToken));

      // Act
      authInterceptor.onRequest(tRequestOptions, mockRequestHandler);

      // Assert
      expect(tRequestOptions.headers['Authorization'], 'Bearer $tToken');
      verify(() => mockRequestHandler.next(tRequestOptions)).called(1);
    });

    test('should NOT add Authorization header when token is null', () {
      // Arrange
      when(() => mockAuthNotifier.state).thenReturn(const AuthState(token: null));

      // Act
      authInterceptor.onRequest(tRequestOptions, mockRequestHandler);

      // Assert
      expect(tRequestOptions.headers.containsKey('Authorization'), false);
      verify(() => mockRequestHandler.next(tRequestOptions)).called(1);
    });
  });

  group('AuthInterceptor - onError', () {
    final tError401 = DioException(
      requestOptions: RequestOptions(path: '/secure-data'),
      response: Response(
        requestOptions: RequestOptions(path: '/secure-data'),
        statusCode: 401,
      ),
      type: DioExceptionType.badResponse,
    );

    test('should call logout and continue for 401 error', () {
      // Arrange
      // Mockamos o notifier para que o método logout possa ser verificado
      when(() => mockAuthNotifier.logout()).thenReturn(null);

      // Simulação do mock do NavigatorState para evitar erro de contexto (GoRouter)
      // Nota: A simulação completa do GoRouter em um teste unitário é complexa.
      // Aqui, verificamos a chamada do logout, que é a lógica principal do interceptor.
      // O mock do GoRouter é complexo e geralmente feito em testes de integração/widget.
      // Para este teste unitário, verificamos o efeito colateral no provider.

      // Act
      authInterceptor.onError(tError401, mockErrorHandler);

      // Assert
      // 1. Verifica se o método logout foi chamado
      verify(() => mockAuthNotifier.logout()).called(1);
      
      // 2. Verifica se o interceptor continua o fluxo de erro
      verify(() => mockErrorHandler.next(tError401)).called(1);
    });

    test('should NOT call logout for other errors (e.g., 500)', () {
      // Arrange
      final tError500 = DioException(
        requestOptions: RequestOptions(path: '/secure-data'),
        response: Response(
          requestOptions: RequestOptions(path: '/secure-data'),
          statusCode: 500,
        ),
        type: DioExceptionType.badResponse,
      );

      // Act
      authInterceptor.onError(tError500, mockErrorHandler);

      // Assert
      // Verifica se o método logout NÃO foi chamado
      verifyNever(() => mockAuthNotifier.logout());
      
      // Verifica se o interceptor continua o fluxo de erro
      verify(() => mockErrorHandler.next(tError500)).called(1);
    });
  });
}