import 'package:flutter_test/flutter_test.dart';
import 'package:mockito/mockito.dart';
import 'package:antibet/src/core/services/chat_service.dart';
import 'package:antibet/src/core/services/user_profile_service.dart';
import 'package:antibet/src/core/utils/app_constants.dart';

// Mocks
class MockUserProfileService extends Mock implements UserProfileService {
  @override
  Future<UserProfile> loadProfile() => super.noSuchMethod(
        Invocation.method(#loadProfile, []),
        returnValue: Future.value(UserProfile(
          nickname: 'Lúzia',
          gender: 'Feminino',
          birthYearMonth: '2000-01',
          concernLevel: 5,
        )), // Perfil Mock Padrão
      ) as Future<UserProfile>;
}

void main() {
  late MockUserProfileService mockUserProfileService;
  late ChatService chatService;

  setUp(() {
    mockUserProfileService = MockUserProfileService();
    // Injeta o mock no serviço
    chatService = ChatService(mockUserProfileService);
  });

  group('ChatService Tests', () {
    test('sendMessage should return an IA message and update history', () async {
      const userText = 'Olá Coach, preciso de ajuda com minhas finanças.';
      
      final iaMessage = await chatService.sendMessage(userText);
      
      // 1. Verifica se o loadProfile foi chamado para o contexto
      verify(mockUserProfileService.loadProfile()).called(1);

      // 2. Verifica a estrutura da mensagem de resposta da IA
      expect(iaMessage.senderId, equals(AppConstants.iaName));
      expect(iaMessage.text, isNotEmpty);
      expect(iaMessage.timestamp, isA<DateTime>());
      
      // 3. Verifica se a resposta foi adicionada ao histórico (simulado)
      // O histórico deve conter a mensagem do usuário e a resposta da IA (2 mensagens)
      final history = (chatService as dynamic)._messageHistory as List<ChatMessage>;
      expect(history.length, equals(2));
      expect(history.last.senderId, equals(AppConstants.iaName));
    });

    test('sendMessage should personalize the response using nickname and gender', () async {
      // Setup: O mock retorna 'Lúzia' e 'Feminino'
      const userText = 'Sinto que vou apostar de novo.';
      
      final iaMessage = await chatService.sendMessage(userText);
      
      // Verifica se a resposta contém o nome e o tom personalizado (lógica mockada)
      expect(iaMessage.text, contains('Lúzia'));
      expect(iaMessage.text, contains('para você, Feminino')); // A lógica de mock usa o gênero
    });
    
    test('sendMessage should trigger the "Apostar" logic and use a crisis-like response', () async {
      const userText = 'Estou com muita vontade de apostar AGORA.';
      
      final iaMessage = await chatService.sendMessage(userText);
      
      // A resposta do mock para a palavra "apostar" é específica para crise
      expect(iaMessage.text, contains('A vontade de apostar é grande, mas você tem o controle.'));
    });
    
    test('sendMessage should correctly handle the "default" logic for other inputs', () async {
      const userText = 'O que você acha do meu progresso?';
      
      final iaMessage = await chatService.sendMessage(userText);
      
      // A resposta do mock para a palavra "apostar" é específica para crise
      expect(iaMessage.text, contains('Como podemos focar nas suas metas hoje?'));
    });
  });
}