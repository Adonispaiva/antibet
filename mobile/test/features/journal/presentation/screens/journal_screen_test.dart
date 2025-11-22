import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:go_router/go_router.dart';
import 'package:mocktail/mocktail.dart';
import 'package:antibet/features/journal/data/models/journal_model.dart';
import 'package:antibet/features/journal/data/models/journal_entry_model.dart';
import 'package:antibet/features/journal/presentation/providers/journal_provider.dart';
import 'package:antibet/features/journal/presentation/screens/journal_screen.dart';
import 'package:antibet/features/journal/presentation/widgets/journal_stats.dart';
import 'package:antibet/features/auth/presentation/providers/auth_provider.dart';
import 'package:antibet/features/auth/data/services/auth_service.dart';

// Mocks
class MockJournalNotifier extends StateNotifier<AsyncValue<JournalModel>> with Mock implements JournalNotifier {
  MockJournalNotifier() : super(const AsyncValue.data(JournalModel(
        entries: [],
        totalInvested: 0,
        totalWins: 0,
        totalLosses: 0,
      )));

  @override
  Future<void> getJournal() async {}

  @override
  Future<bool> createEntry(String description, double amount, bool isWin) async => true;
}

class MockAuthNotifier extends StateNotifier<AuthState> with Mock implements AuthNotifier {
  MockAuthNotifier() : super(const AuthState(token: 'active_token', isAuthenticated: true));

  @override
  Future<void> logout() async {}
}

class MockAuthService extends Mock implements AuthService {
  @override
  Future<void> logout() async {}
}

// Wrapper para simular o ProviderScope e o contexto de navegação
class TestJournalWrapper extends StatelessWidget {
  final Widget child;
  final MockJournalNotifier mockJournalNotifier;
  final MockAuthNotifier mockAuthNotifier;
  final MockAuthService mockAuthService;

  const TestJournalWrapper({
    super.key, 
    required this.child, 
    required this.mockJournalNotifier,
    required this.mockAuthNotifier,
    required this.mockAuthService,
  });

  @override
  Widget build(BuildContext context) {
    return ProviderScope(
      overrides: [
        journalProvider.overrideWithValue(mockJournalNotifier),
        authProvider.overrideWithValue(mockAuthNotifier),
        authServiceProvider.overrideWithValue(mockAuthService),
      ],
      child: MaterialApp(
        home: Builder(
          builder: (context) {
            // Usa um GoRouter simples para capturar a navegação
            return GoRouter(
              routes: [
                GoRoute(path: '/', builder: (c, s) => child),
                GoRoute(path: '/journal/add', builder: (c, s) => const Text('Add Entry')),
                GoRoute(path: '/journal/edit', builder: (c, s) => const Text('Edit Entry')),
                GoRoute(path: '/login', builder: (c, s) => const Text('Login Screen')),
                GoRoute(path: '/settings', builder: (c, s) => const Text('Settings Screen')), // Rota de Settings para teste
              ],
              initialLocation: '/',
            );
          },
        ),
      ),
    );
  }
}

void main() {
  late MockJournalNotifier mockJournalNotifier;
  late MockAuthNotifier mockAuthNotifier;
  late MockAuthService mockAuthService;

  setUp(() {
    mockJournalNotifier = MockJournalNotifier();
    mockAuthNotifier = MockAuthNotifier();
    mockAuthService = MockAuthService();
    // Garante que o mock de logout seja registrado
    when(() => mockAuthNotifier.logout()).thenAnswer((_) async {});
    when(() => mockAuthService.logout()).thenAnswer((_) async {});
  });

  group('JournalScreen Widget', () {
    final tEntry = JournalEntryModel(
      id: '1',
      description: 'First Bet',
      amount: 10.0,
      isWin: false,
      date: DateTime.now(),
    );
    final tJournal = JournalModel(
      entries: [tEntry],
      totalInvested: 10.0,
      totalWins: 0,
      totalLosses: 1,
    );

    testWidgets('should show stats and list when data is available', (WidgetTester tester) async {
      // Arrange
      mockJournalNotifier.setState(AsyncValue.data(tJournal));
      
      await tester.pumpWidget(TestJournalWrapper(
        mockJournalNotifier: mockJournalNotifier,
        mockAuthNotifier: mockAuthNotifier,
        mockAuthService: mockAuthService,
        child: const JournalScreen(),
      ));
      await tester.pumpAndSettle();

      // Assert
      expect(find.byType(JournalStats), findsOneWidget);
      expect(find.text(tEntry.description), findsOneWidget); 
    });
    
    testWidgets('tapping Settings button navigates to /settings', (WidgetTester tester) async {
      // Arrange
      mockJournalNotifier.setState(AsyncValue.data(tJournal));
      
      await tester.pumpWidget(TestJournalWrapper(
        mockJournalNotifier: mockJournalNotifier,
        mockAuthNotifier: mockAuthNotifier,
        mockAuthService: mockAuthService,
        child: const JournalScreen(),
      ));
      await tester.pumpAndSettle();

      // Act
      await tester.tap(find.byIcon(Icons.settings));
      await tester.pumpAndSettle(const Duration(seconds: 1)); 

      // Assert
      expect(find.text('Settings Screen'), findsOneWidget);
    });

    testWidgets('tapping Logout button calls AuthNotifier.logout and navigates to /login', (WidgetTester tester) async {
      // Arrange
      mockJournalNotifier.setState(AsyncValue.data(tJournal));
      
      await tester.pumpWidget(TestJournalWrapper(
        mockJournalNotifier: mockJournalNotifier,
        mockAuthNotifier: mockAuthNotifier,
        mockAuthService: mockAuthService,
        child: const JournalScreen(),
      ));
      await tester.pumpAndSettle();

      // Act
      await tester.tap(find.byIcon(Icons.logout));
      await tester.pumpAndSettle(const Duration(seconds: 1)); 

      // Assert
      // 1. Verifica se o logout no serviço de backend foi chamado
      verify(() => mockAuthService.logout()).called(1);
      
      // 2. Verifica se o logout no notifier (limpeza local/persistência) foi chamado
      verify(() => mockAuthNotifier.logout()).called(1);
      
      // 3. Verifica a navegação para a tela de login
      expect(find.text('Login Screen'), findsOneWidget);
    });
  });
}