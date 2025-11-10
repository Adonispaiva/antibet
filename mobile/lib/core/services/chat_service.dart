import 'package:antibet/src/core/services/user_profile_service.dart';
import 'package:antibet/src/core/utils/app_constants.dart';

// Modelo de Dados da Mensagem
class ChatMessage {
  final String text;
  final String senderId; // 'user' ou 'ia'
  final DateTime timestamp;

  ChatMessage({required this.text, required this.senderId, required this.timestamp});
}

// SIMULAÇÃO DO PROMPT DE SISTEMA DA IA (ORQUESTRADOR)
// O prompt real estaria em um arquivo externo ou configuração de backend (ex: ia-prompts.ts)
const String _systemPrompt = """
Você é o AntiBet Coach. Sua missão é fornecer apoio psicológico e educacional.
REGRAS:
1. Responda como uma amiga digital, solidária e empática (Zero Julgamento).
2. Baseie seu conteúdo em TCC, Entrevista Motivacional e Psicoeducação.
3. Chame o usuário pelo apelido.
4. NUNCA substitua tratamento clínico.
5. Adapte seu tom ao gênero e idade do usuário.
""";


class ChatService {
  final UserProfileService _userProfileService;
  
  // Histórico simples da conversa (simulado)
  final List<ChatMessage> _messageHistory = []; 

  ChatService(this._userProfileService);

  // Adiciona a mensagem ao histórico interno (simulação de banco de dados/cache)
  void _addToHistory(ChatMessage message) {
    _messageHistory.add(message);
    // Limita o histórico a 20 mensagens para contexto (simulação de LangChain/memória)
    if (_messageHistory.length > 20) {
      _messageHistory.removeAt(0);
    }
  }

  /// Simula o envio de uma mensagem ao Orquestrador da IA e recebe a resposta.
  Future<ChatMessage> sendMessage(String userText) async {
    final now = DateTime.now();
    final userMessage = ChatMessage(text: userText, senderId: 'user', timestamp: now);
    _addToHistory(userMessage);

    // 1. Recupera o Perfil do Usuário para Contexto (Personalização)
    final userProfile = await _userProfileService.loadProfile();
    final contextNickname = userProfile.nickname ?? 'Usuário';
    final contextGender = userProfile.gender ?? 'Não Informado';
    final contextAge = userProfile.birthYearMonth != null ? (now.year - (int.tryParse(userProfile.birthYearMonth!.substring(0, 4)) ?? 0)).toString() : '25';
    
    // 2. Monta o Contexto de Sistema + RAG (Simulação do Orquestrador)
    final contextualPrompt = """
    --- CONTEXTO DO USUÁRIO ---
    Apelido: $contextNickname
    Gênero para Tom: $contextGender
    Idade Estimada: $contextAge
    Nível de Preocupação: ${userProfile.concernLevel}
    
    --- PROMPT DE SISTEMA ---
    $_systemPrompt

    --- HISTÓRICO DE CONVERSA (últimas 5) ---
    ${_messageHistory.reversed.take(5).map((m) => '${m.senderId}: ${m.text}').join('\n')}

    --- SOLICITAÇÃO ATUAL ---
    $userText
    """;
    
    // 3. Simulação da Chamada ao LLM (FastAPI Backend)
    await Future.delayed(const Duration(seconds: 1)); 

    // 4. Gera uma resposta simulada (usando o contexto)
    final iaResponseText = _generateMockResponse(userText, contextNickname, contextGender);
    
    final iaMessage = ChatMessage(text: iaResponseText, senderId: AppConstants.iaName, timestamp: DateTime.now());
    _addToHistory(iaMessage);
    
    print('Contexto enviado ao LLM (Simulado): ${contextualPrompt.substring(0, 500)}...');
    
    return iaMessage;
  }
  
  // Lógica de resposta simples para fins de MVP e teste
  String _generateMockResponse(String userText, String nickname, String gender) {
    if (userText.toLowerCase().contains('apostar')) {
      return 'Entendo, $nickname. A vontade de apostar é grande, mas você tem o controle. Que tal tentarmos uma técnica de respiração que funciona muito bem para você, $gender?';
    }
    return 'Obrigada por compartilhar, $nickname. Lembre-se, estou aqui para você. Como podemos focar nas suas metas hoje?';
  }
}