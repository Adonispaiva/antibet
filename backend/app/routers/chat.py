from fastapi import APIRouter, HTTPException, Depends
from pydantic import BaseModel, Field
from typing import List, Dict
import time

# --- IMPORTAÇÃO DO NOVO SERVIÇO RAG ---
from app.services.rag_service import RAGService 

# --- MODELOS DE DADOS (Pydantic) ---

# Simulação de um modelo de usuário autenticado (retornado após a validação do JWT)
class UserModel(BaseModel):
    id: str
    nickname: str = "Adonis"
    gender: str = "Masculino"
    age: int = 35

# Simulação da mensagem de entrada
class ChatRequest(BaseModel):
    message: str = Field(..., example="Estou com vontade de apostar.")
    history: List[Dict[str, str]] = Field(default_factory=list) # Histórico para contexto

# Simulação da mensagem de resposta da IA
class ChatResponse(BaseModel):
    response: str
    sender: str = "AntiBet Coach"
    token_usage: int = 1 # Simulação do consumo de tokens (para Freemium/Limitado)

# --- DEPENDÊNCIAS (Guarda de Segurança) ---

def jwt_auth_guard(token: str = "mock_valid_token") -> UserModel:
    """Simula a decodificação do JWT e retorna o modelo do usuário."""
    if not token or "fail" in token:
         raise HTTPException(status_code=401, detail="Token inválido ou expirado.")
    return UserModel(id="user_123", nickname="Adonis", gender="Masculino", age=35)

# --- INICIALIZAÇÃO DE SERVIÇOS CORE (Simulação de Injeção) ---

# Em um sistema real, o RAGService seria injetado no construtor
# do LLMController, mas aqui ele é instanciado para uso direto.
rag_service = RAGService()

# --- PROMPT DE SISTEMA DA IA (ORQUESTRADOR) ---

SYSTEM_PROMPT = """
Você é o AntiBet Coach. Sua missão é fornecer apoio psicológico e educacional de forma empática e sem julgamentos.
REGRAS:
1. Responda como uma amiga digital, solidária e empática (Zero Julgamento).
2. Use Terapia Cognitivo-Comportamental (TCC) e Mindfulness (Urge Surfing).
3. Adapte seu tom ao gênero e idade do usuário.
4. Chame o usuário pelo apelido.
5. NUNCA substitua tratamento clínico.
"""

# --- ROTAS DE CHAT E IA ---

router = APIRouter()

@router.post("/send", response_model=ChatResponse)
def send_message_to_ia(
    request: ChatRequest,
    current_user: UserModel = Depends(jwt_auth_guard)
):
    """
    Recebe a mensagem do usuário, injeta o contexto do RAG e devolve a resposta do LLM (simulado).
    """
    
    # 1. PREPARAÇÃO DO CONTEXTO DE SISTEMA + PERSONALIZAÇÃO
    
    # Contexto de Personalização do Usuário (do JWT/Banco de Dados)
    user_context = f"""
    --- CONTEXTO DO USUÁRIO ---
    Apelido: {current_user.nickname}
    Gênero: {current_user.gender}
    Idade: {current_user.age}
    """
    
    # 2. BUSCA DO CONTEXTO RAG REAL
    # Busca o contexto científico relevante (TCC, Urge Surfing, Financeiro)
    rag_context = rag_service.retrieve_context(request.message)
    
    # Constrói o Prompt final que será enviado ao LLM
    final_prompt = (
        SYSTEM_PROMPT + 
        user_context + 
        rag_context + # CONTEXTO RAG INJETADO AQUI
        "\n--- MENSAGEM DO USUÁRIO ---\n" + request.message
    )
    
    print(f"Prompt Final (Enviado ao LLM Simulado): {final_prompt[:800]}...")

    # 3. CHAMADA AO LLM (Simulação)
    # A lógica real chamaria a API da OpenAI/Claude aqui.
    ia_response = _generate_mock_ia_response(request.message, current_user.nickname)

    return ChatResponse(
        response=ia_response,
        token_usage=len(request.message) // 10 + 20
    )

def _generate_mock_ia_response(user_message: str, nickname: str) -> str:
    """Lógica de mock para simular uma resposta relevante da IA."""
    if "apostar" in user_message.lower() or "jogar" in user_message.lower() or "impulso" in user_message.lower():
        return f"Sinto muito que você esteja sentindo esse impulso, {nickname}. É um momento difícil. Lembre-se do Urge Surfing: deixe o impulso passar. Quer tentar a respiração 4-7-8 comigo agora?"
    elif "finanças" in user_message.lower() or "dinheiro" in user_message.lower():
        return f"As finanças são um ponto chave, {nickname}. Tente rever seu Painel Financeiro e veja o dinheiro que você já economizou. Podemos traçar uma meta simples para esta semana."
    else:
        return f"Obrigada por compartilhar, {nickname}. Lembre-se que estou aqui para te apoiar em qualquer desafio. Como posso te ajudar a reestruturar seus pensamentos neste momento?"