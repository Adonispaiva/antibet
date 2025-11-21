import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:dio/dio.dart';
import 'package:antibet/core/network/dio_provider.dart';
import 'package:antibet/core/network/interceptors/auth_interceptor.dart';

void main() {
  group('Dio Provider', () {
    late ProviderContainer container;

    setUp(() {
      // Inicializa o container do Riverpod. 
      // Não é necessário mockar o AuthInterceptor aqui, apenas garantir que ele seja injetado.
      container = ProviderContainer();
    });

    tearDown(() {
      container.dispose();
    });

    test('should provide a Dio instance with correct BaseOptions', () {
      // Act
      final dio = container.read(dioProvider);

      // Assert
      expect(dio, isA<Dio>());
      expect(dio.options.baseUrl, 'https://api.dev.antibet.com/v1');
      expect(dio.options.connectTimeout, const Duration(seconds: 10));
      expect(dio.options.receiveTimeout, const Duration(seconds: 10));
    });

    test('should include AuthInterceptor and LogInterceptor', () {
      // Act
      final dio = container.read(dioProvider);
      final interceptors = dio.interceptors;

      // Assert
      // Deve ter pelo menos o AuthInterceptor e o LogInterceptor (total de 2)
      expect(interceptors.length, greaterThanOrEqualTo(2));
      
      // Verifica se o AuthInterceptor está presente
      expect(interceptors.any((i) => i is AuthInterceptor), isTrue);

      // Verifica se o LogInterceptor está presente (o tipo exato pode ser mais difícil de checar, 
      // mas verificamos se há um tipo Base de Interceptor que corresponde ao LogInterceptor)
      expect(interceptors.any((i) => i.runtimeType.toString().contains('LogInterceptor')), isTrue);
    });
  });
}