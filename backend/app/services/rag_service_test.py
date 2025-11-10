import pytest
from app.services.rag_service import RAGService

# Testes unitários para o serviço de RAG, validando a busca e injeção de contexto.

@pytest.fixture
def rag_service():
    """Fixture para inicializar o RAGService."""
    return RAGService()

def test_rag_service_initialization(rag_service):
    """Verifica se o serviço é inicializado corretamente."""
    assert rag_service is not None
    # Verifica se a mensagem de inicialização foi printada (simulando a conexão com o VectorDB)
    # No ambiente de teste, confiamos que a inicialização não levanta exceção.
    pass 

def test_retrieve_context_for_impulse_queries(rag_service):
    """Testa a recuperação de contexto para consultas de impulso/crise."""
    query = "Estou com muita vontade de apostar agora, me ajude a controlar o impulso."
    context = rag_service.retrieve_context(query)
    
    # Deve conter a técnica Urge Surfing e TCC
    assert "Urge Surfing" in context
    assert "TCC" in context
    assert "onda" in context
    assert "Regra Ética" not in context # Não deve ser o foco principal

def test_retrieve_context_for_financial_queries(rag_service):
    """Testa a recuperação de contexto para consultas sobre dinheiro/perdas."""
    query = "Perdi muito dinheiro esta semana. Quero saber como recuperar as finanças."
    context = rag_service.retrieve_context(query)
    
    # Deve conter o contexto financeiro e psicoeducação
    assert "Simulador de Oportunidade Perdida" in context
    assert "97% dos apostadores perdem a longo prazo" in context
    assert "Urge Surfing" not in context # Não deve ser o foco principal

def test_retrieve_context_for_professional_help_queries(rag_service):
    """Testa a recuperação de contexto para consultas sobre terapia e ajuda profissional."""
    query = "Você pode me substituir um psicólogo? Quero saber se preciso de terapia."
    context = rag_service.retrieve_context(query)
    
    # Deve conter o contexto ético (Regra Ética)
    assert "Regra Ética" in context
    assert "AntiBet não substitui tratamento psicológico" in context
    assert "CAPS AD" not in context # Pode ou não estar no chunk, mas a Regra Ética é essencial.

def test_retrieve_context_fallback_mechanism(rag_service):
    """Testa o mecanismo de fallback quando não há palavras-chave relevantes."""
    query = "Qual a capital da França?"
    context = rag_service.retrieve_context(query)
    
    # Deve retornar o chunk de TCC (o fallback definido no serviço)
    assert "Terapia Cognitivo-Comportamental (TCC)" in context
    assert "reestruturação de pensamentos automáticos" in context
    assert "FINANCEIRO" not in context
    
def test_retrieved_context_format(rag_service):
    """Verifica se o formato do contexto RAG é o esperado para injeção."""
    query = "Estou em crise."
    context = rag_service.retrieve_context(query)
    
    assert context.startswith('\n--- CONTEXTO RAG INJETADO ---\n')
    assert context.endswith('\n--- FIM RAG ---\n')