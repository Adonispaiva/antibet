import 'package:flutter_test/flutter_test.dart';
import 'package:mockito/mockito.dart';
import 'package:mockito/annotations.dart';
import 'package:dio/dio.dart';
import 'package:flutter_secure_storage/flutter_secure_storage.dart';

import 'package.antibet/core/data/api/api_client.dart';
import 'package.antibet/features/auth/services/auth_service.dart';
import 'package.antibet/features/auth/models/auth_response_model.dart';
import 'package.antibet/features/user/models/user_model.dart';

// Importa o arquivo gerado pelo mockito
import 'auth_service_test.mocks.dart';

// Gera mocks para as dependências do AuthService
@GenerateMocks([ApiClient, FlutterSecureStorage])
void main() {
  late MockApiClient mockApiClient;
  late MockFlutterSecureStorage mockSecureStorage;
  late AuthService authService;

  setUp(() {
    mockApiClient = MockApiClient();
    mockSecureStorage = MockFlutterSecureStorage();
    // Injeta os mocks na implementação concreta do serviço
    authService = AuthService(mockApiClient, mockSecureStorage);
  });

  // Agrupa os testes da funcionalidade de Login
  group('login', () {
    // Mock do usuário e da resposta da API
    final tUserModel = UserModel(id: '1', name: 'Test User', email: 'test@test.com', isActive: true, createdAt: DateTime.now());
    final tAuthResponse = AuthResponseModel(user: tUserModel, token: 'fake_token');
    
    test('deve retornar AuthResponseModel e salvar o token no storage em caso de sucesso', () async {
      // 1. Arrange (Configuração)
      // Configura o mock do ApiClient para retornar uma resposta de sucesso
      when(mockApiClient.post(
        '/auth/login',
        data: anyNamed('data'),
      )).thenAnswer((_) async => Response(
        requestOptions: RequestOptions(path: '/auth/login'),
        data: tAuthResponse.toJson(),
        statusCode: 200,
      ));
      
      // Configura o mock do SecureStorage para simular a escrita
      when(mockSecureStorage.write(key: 'authToken', value: 'fake_token'))
          .thenAnswer((_) async => Future.value());

      // 2. Act (Ação)
      final result = await authService.login('test@test.com', 'password');

      // 3. Assert (Verificação)
      expect(result, isA<AuthResponseModel>());
      expect(result.token, 'fake_token');
      // Verifica se o ApiClient.post foi chamado com os dados corretos
      verify(mockApiClient.post('/auth/login', data: {'email': 'test@test.com', 'password': 'password'}));
      // Verifica se o token foi salvo no storage
      verify(mockSecureStorage.write(key: 'authToken', value: 'fake_token'));
    });

    test('deve lançar uma exceção se a chamada da API falhar (ex: 401)', () async {
      // 1. Arrange
      // Configura o mock do ApiClient para simular um erro
      when(mockApiClient.post(
        '/auth/login',
        data: anyNamed('data'),
      )).thenThrow(DioException(
        requestOptions: RequestOptions(path: '/auth/login'),
        response: Response(
          requestOptions: RequestOptions(path: '/auth/login'),
          data: {'message': 'Credenciais inválidas'},
          statusCode: 401,
        ),
      ));

      // 2. Act
      final call = authService.login('test@test.com', 'wrong_password');

      // 3. Assert
      expect(call, throwsA(isA<DioException>()));
      // Verifica se o storage NÃO foi chamado
      verifyNever(mockSecureStorage.write(key: any, value: any));
    });
  });

  // Agrupa os testes da funcionalidade de Logout
  group('logout', () {
    test('deve deletar o token do secure storage', () async {
      // 1. Arrange
      when(mockSecureStorage.delete(key: 'authToken'))
          .thenAnswer((_) async => Future.value());

      // 2. Act
      await authService.logout();

      // 3. Assert
      verify(mockSecureStorage.delete(key: 'authToken'));
    });
  });

  // Agrupa os testes da funcionalidade de checagem de token
  group('checkTokenValidity', () {
    test('deve retornar true se um token existir no storage', () async {
      // 1. Arrange
      when(mockSecureStorage.read(key: 'authToken'))
          .thenAnswer((_) async => 'some_token');

      // 2. Act
      final result = await authService.checkTokenValidity();

      // 3. Assert
      expect(result, true);
    });

    test('deve retornar false se não houver token no storage', () async {
      // 1. Arrange
      when(mockSecureStorage.read(key: 'authToken'))
          .thenAnswer((_) async => null);

      // 2. Act
      final result = await authService.checkTokenValidity();

      // 3. Assert
      expect(result, false);
    });
  });
}