import 'package.flutter_test/flutter_test.dart';
import 'package:mockito/mockito.dart';
import 'package:dio/dio.dart';
import 'package:flutter_secure_storage/flutter_secure_storage.dart';

import 'package:antibet/core/data/api/api_client.dart';
import 'package:antibet/features/user/services/user_service.dart';
import 'package:antibet/features/user/models/user_model.dart';

// Importa o arquivo gerado pelo mockito (agora sabemos que ele existe)
import '../../auth/services/auth_service_test.mocks.dart';
    
void main() {
  late MockApiClient mockApiClient;
  late MockFlutterSecureStorage mockSecureStorage;
  late UserService userService;

  setUp(() {
    mockApiClient = MockApiClient();
    mockSecureStorage = MockFlutterSecureStorage();
    // Injeta os mocks na implementação concreta do serviço
    userService = UserService(mockApiClient, mockSecureStorage);
  });

  // Agrupa os testes da funcionalidade de fetchCurrentUser
  group('fetchCurrentUser', () {
    final tUserModel = UserModel(id: '1', name: 'Test User', email: 'test@test.com', isActive: true, createdAt: DateTime.now());
    const tToken = 'fake_token';

    test('deve retornar UserModel se o token existir e a API responder com sucesso', () async {
      // 1. Arrange (Configuração)
      // Simula o storage lendo o token
      when(mockSecureStorage.read(key: 'authToken')).thenAnswer((_) async => tToken);
      
      // Simula o ApiClient (com o token) buscando o usuário
      when(mockApiClient.get(
        '/users/me',
        options: anyNamed('options'), // O options deve conter o token
      )).thenAnswer((_) async => Response(
        requestOptions: RequestOptions(path: '/users/me'),
        data: tUserModel.toJson(),
        statusCode: 200,
      ));

      // 2. Act (Ação)
      final result = await userService.fetchCurrentUser();

      // 3. Assert (Verificação)
      expect(result, isA<UserModel>());
      expect(result.id, '1');
      
      // Verifica se o token foi lido do storage
      verify(mockSecureStorage.read(key: 'authToken'));
      // Verifica se a API foi chamada
      verify(mockApiClient.get('/users/me', options: anyNamed('options')));
    });

    test('deve lançar uma exceção se o token não existir no storage', () async {
      // 1. Arrange
      // Simula o storage não encontrando o token
      when(mockSecureStorage.read(key: 'authToken')).thenAnswer((_) async => null);

      // 2. Act
      final call = userService.fetchCurrentUser();

      // 3. Assert
      expect(call, throwsA(isA<Exception>()));
      // Verifica se a API (get) NÃO foi chamada
      verifyNever(mockApiClient.get(any, options: anyNamed('options')));
    });

    test('deve lançar uma exceção (DioException) se a API falhar (ex: 401)', () async {
      // 1. Arrange
      when(mockSecureStorage.read(key: 'authToken')).thenAnswer((_) async => tToken);

      when(mockApiClient.get(
        '/users/me',
        options: anyNamed('options'),
      )).thenThrow(DioException(
        requestOptions: RequestOptions(path: '/users/me'),
        response: Response(
          requestOptions: RequestOptions(path: '/users/me'),
          data: {'message': 'Token expirado'},
          statusCode: 401,
        ),
      ));

      // 2. Act
      final call = userService.fetchCurrentUser();

      // 3. Assert
      expect(call, throwsA(isA<DioException>()));
    });
  });
}