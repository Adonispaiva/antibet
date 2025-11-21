import 'package:dio/dio.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:mocktail/mocktail.dart';
import 'package:antibet/features/auth/data/services/auth_service.dart';

class MockDio extends Mock implements Dio {}

void main() {
  late MockDio mockDio;
  late AuthService authService;

  setUp(() {
    mockDio = MockDio();
    authService = AuthService(mockDio);
  });

  group('AuthService', () {
    const tEmail = 'test@example.com';
    const tPassword = 'password123';
    const tToken = 'fake_jwt_token';

    test('login should return token on success (200)', () async {
      // Arrange
      when(() => mockDio.post('/auth/login', data: any(named: 'data')))
          .thenAnswer((_) async => Response(
                requestOptions: RequestOptions(path: '/auth/login'),
                statusCode: 200,
                data: {'token': tToken},
              ));

      // Act
      final result = await authService.login(tEmail, tPassword);

      // Assert
      expect(result, tToken);
      verify(() => mockDio.post('/auth/login', data: {
            'email': tEmail,
            'password': tPassword,
          })).called(1);
    });

    test('login should throw Exception on failure (401)', () async {
      // Arrange
      when(() => mockDio.post('/auth/login', data: any(named: 'data')))
          .thenThrow(DioException(
            requestOptions: RequestOptions(path: '/auth/login'),
            response: Response(
              requestOptions: RequestOptions(path: '/auth/login'),
              statusCode: 401,
              data: {'message': 'Invalid credentials'},
            ),
            type: DioExceptionType.badResponse,
          ));

      // Act
      final call = authService.login;

      // Assert
      expect(() => call(tEmail, tPassword), throwsException);
    });

    test('register should complete successfully on 201', () async {
      // Arrange
      when(() => mockDio.post('/auth/register', data: any(named: 'data')))
          .thenAnswer((_) async => Response(
                requestOptions: RequestOptions(path: '/auth/register'),
                statusCode: 201,
                data: {'message': 'User created'},
              ));

      // Act
      await authService.register(tEmail, tPassword);

      // Assert
      verify(() => mockDio.post('/auth/register', data: {
            'email': tEmail,
            'password': tPassword,
          })).called(1);
    });
  });
}