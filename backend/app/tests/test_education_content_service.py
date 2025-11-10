import pytest
from app.services.education_content_service import EducationContentService

# --- Mocks dos Relatórios de Detecção (Simulando a saída da API) ---

# Risco Máximo: Operadora Não Autorizada (Prioridade 1)
MOCK_REPORT_UNAUTHORIZED = {
    "score": 90,
    "risk_label": "Alto",
    "advertorial_evidence": {"DECEPTIVE_MATCHES": ["hack do tigrinho"], "OPERATOR_MATCHES": ["blaze"]},
    "spa_verification": [{"domain": "blaze", "status": "UNKNOWN_OR_UNAUTHORIZED", "details": None}]
}

# Risco Alto: Linguagem Enganosa (Prioridade 2)
MOCK_REPORT_DECEPTIVE = {
    "score": 80,
    "risk_label": "Alto",
    "advertorial_evidence": {"DECEPTIVE_MATCHES": ["estratégia infalível"], "OPERATOR_MATCHES": ["betano"]},
    "spa_verification": [{"domain": "betano", "status": "AUTHORIZED", "details": {}}]
}

# Risco Moderado: CTA (Prioridade 3)
MOCK_REPORT_CTA = {
    "score": 40,
    "risk_label": "Moderado",
    "advertorial_evidence": {"CTA_MATCHES": ["cadastre-se", "ganhe bônus"]},
    "spa_verification": []
}

# Risco Moderado: Operadora (Prioridade 4)
MOCK_REPORT_OPERATOR_ONLY = {
    "score": 30,
    "risk_label": "Moderado",
    "advertorial_evidence": {"OPERATOR_MATCHES": ["betano"]},
    "spa_verification": [{"domain": "betano", "status": "AUTHORIZED", "details": {}}]
}

# Risco Baixo: Padrão (Fallback)
MOCK_REPORT_LOW_RISK = {
    "score": 0,
    "risk_label": "Baixo",
    "advertorial_evidence": {},
    "spa_verification": []
}

# --- Testes Unitários do Serviço ---

@pytest.fixture
def service():
    """Fixture para inicializar o EducationContentService."""
    return EducationContentService()

def test_priority_1_unauthorized_operator(service):
    """
    Valida se o risco de 'Operadora Não Autorizada' (P1) é selecionado
    mesmo que 'Linguagem Enganosa' (P2) esteja presente.
    """
    card = service.get_educational_card(MOCK_REPORT_UNAUTHORIZED)
    assert card is not None
    assert card["title"] == "Risco Elevado: Operadora Não Autorizada"
    assert "Ministério da Fazenda" in card["content"]

def test_priority_2_deceptive_language(service):
    """
    Valida se 'Linguagem Enganosa' (P2) é selecionada quando a operadora é autorizada.
    """
    card = service.get_educational_card(MOCK_REPORT_DECEPTIVE)
    assert card["title"] == "Cuidado: Promessa de Ganho Fácil"
    assert "RNG" in card["content"] # Verifica se o conteúdo é sobre RNG/RTP

def test_priority_3_cta(service):
    """
    Valida se 'Incentivo ao Cadastro' (P3) é selecionado.
    """
    card = service.get_educational_card(MOCK_REPORT_CTA)
    assert card["title"] == "Alerta: Incentivo ao Cadastro"
    assert "Bônus são estratégias" in card["content"]

def test_priority_4_operator_only(service):
    """
    Valida se 'Publicidade de Aposta' (P4) é selecionado quando é a única evidência.
    """
    card = service.get_educational_card(MOCK_REPORT_OPERATOR_ONLY)
    assert card["title"] == "Aviso: Publicidade de Aposta"
    assert "dependência financeira e emocional" in card["content"]

def test_priority_5_default_fallback(service):
    """
    Valida se o cartão 'Padrão' (Fallback) é selecionado para conteúdo de baixo risco.
    """
    card = service.get_educational_card(MOCK_REPORT_LOW_RISK)
    assert card["title"] == "Jogo Envolve Risco Real"
    assert "Não existe método garantido" in card["content"]