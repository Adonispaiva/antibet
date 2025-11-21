import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:antibet/features/auth/presentation/providers/auth_provider.dart';

void main() {
  late ProviderContainer container;

  setUp(() {
    container = ProviderContainer();
  });

  tearDown(() {
    container.dispose();
  });

  group('AuthNotifier', () {
    test('initial state should be unauthenticated', () {
      final state = container.read(authProvider);
      
      expect(state.token, null);
      expect(state.isAuthenticated, false);
      expect(state.isLoading, false);
      expect(state.error, null);
    });

    test('setToken should update state to authenticated', () {
      final notifier = container.read(authProvider.notifier);
      const tToken = 'test_token_123';

      notifier.setToken(tToken);

      final state = container.read(authProvider);
      expect(state.token, tToken);
      expect(state.isAuthenticated, true);
      expect(state.isLoading, false);
    });

    test('setLoading should update isLoading to true', () {
      final notifier = container.read(authProvider.notifier);

      notifier.setLoading();

      final state = container.read(authProvider);
      expect(state.isLoading, true);
      expect(state.error, null);
    });

    test('setError should update error message and stop loading', () {
      final notifier = container.read(authProvider.notifier);
      const tError = 'Invalid credentials';

      // Primeiro ativamos o loading para garantir que ele é desativado
      notifier.setLoading();
      notifier.setError(tError);

      final state = container.read(authProvider);
      expect(state.error, tError);
      expect(state.isLoading, false);
    });

    test('logout should clear token and reset state', () {
      final notifier = container.read(authProvider.notifier);
      notifier.setToken('some_token');

      notifier.logout();

      final state = container.read(authProvider);
      expect(state.token, null);
      expect(state.isAuthenticated, false);
    });
  });
}