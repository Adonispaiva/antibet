import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:go_router/go_router.dart';
import 'package:mocktail/mocktail.dart';
import 'package:antibet/core/routing/app_router.dart';
import 'package:antibet/features/auth/presentation/providers/auth_provider.dart';

// Mocks
class MockAuthNotifier extends StateNotifier<AuthState> with Mock implements AuthNotifier {}

void main() {
  late MockAuthNotifier mockAuthNotifier;
  late ProviderContainer container;

  setUp(() {
    mockAuthNotifier = MockAuthNotifier();
    // Inicializa o container com o provider de autenticação sobrescrito
    container = ProviderContainer(
      overrides: [
        authProvider.overrideWith((ref) => mockAuthNotifier),
      ],
    );
  });

  tearDown(() {
    container.dispose();
  });

  group('App Router Redirect Logic (Unit Test)', () {
    test('should redirect unauthenticated user from protected route (/journal) to /login', () {
      // Arrange
      // Simula o estado deslogado
      when(() => mockAuthNotifier.state).thenReturn(const AuthState(token: null));
      
      final router = container.read(goRouterProvider);
      
      // Act: Simula a tentativa de acesso a uma rota protegida
      final result = router.routerDelegate.redirect(
        const RouteMatchList.empty(),
        GoRouterState(
          uri: Uri.parse('/journal'),
          matchedLocation: '/journal',
          router: router,
        ),
      );

      // Assert
      expect(result, '/login');
    });

    test('should NOT redirect unauthenticated user from /login', () {
      // Arrange
      when(() => mockAuthNotifier.state).thenReturn(const AuthState(token: null));
      
      final router = container.read(goRouterProvider);
      
      // Act: Simula a tentativa de acesso à rota de login
      final result = router.routerDelegate.redirect(
        const RouteMatchList.empty(),
        GoRouterState(
          uri: Uri.parse('/login'),
          matchedLocation: '/login',
          router: router,
        ),
      );

      // Assert
      expect(result, null); // Não deve redirecionar
    });

    test('should redirect authenticated user from /login to /journal', () {
      // Arrange
      // Simula o estado logado
      when(() => mockAuthNotifier.state).thenReturn(const AuthState(token: 'jwt_token'));
      
      final router = container.read(goRouterProvider);
      
      // Act: Simula a tentativa de acesso à rota de login
      final result = router.routerDelegate.redirect(
        const RouteMatchList.empty(),
        GoRouterState(
          uri: Uri.parse('/login'),
          matchedLocation: '/login',
          router: router,
        ),
      );

      // Assert
      expect(result, '/journal');
    });

    test('should NOT redirect authenticated user from protected route (/journal)', () {
      // Arrange
      when(() => mockAuthNotifier.state).thenReturn(const AuthState(token: 'jwt_token'));
      
      final router = container.read(goRouterProvider);
      
      // Act: Simula a tentativa de acesso a uma rota protegida
      final result = router.routerDelegate.redirect(
        const RouteMatchList.empty(),
        GoRouterState(
          uri: Uri.parse('/journal'),
          matchedLocation: '/journal',
          router: router,
        ),
      );

      // Assert
      expect(result, null); // Não deve redirecionar
    });
  });
}