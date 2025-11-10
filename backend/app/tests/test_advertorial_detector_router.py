import pytest
from fastapi.testclient import TestClient
from main import app # Importa a aplicação FastAPI principal

# Cliente de Teste para simular requisições HTTP
client = TestClient(app)

# --- Cenários de Teste ---

# Cenário 1: Risco Alto (Advertorial claro, Domínio Autorizado)
MOCK_PAYLOAD_RISCO_ALTO = {
    "url": "https://portal-exemplo.com/publieditorial/como-ganhar-facil",
    "text_content": """
        Este é um conteúdo patrocinado. A melhor estratégia infalível 
        é usar o hack do tigrinho. Cadastre-se na Betano agora e ganhe bônus!
        A Bet365 também é boa.
    """
}

# Cenário 2: Risco Alto (Advertorial claro, Domínio Não Autorizado)
MOCK_PAYLOAD_RISCO_ALTO_NAO_AUTORIZADO = {
    "url": "https://portal-exemplo.com/afiliado/ganhe-dinheiro",
    "text_content": """
        Publi. Use o hack do tigrinho na Blaze. 
        Aposte agora e cadastre-se.
    """
}

# Cenário 3: Risco Baixo (Conteúdo Legítimo)
MOCK_PAYLOAD_RISCO_BAIXO = {
    "url": "https://portal-legitimo.com/noticia/economia",
    "text_content": "O banco central anunciou novas taxas de juros."
}

# --- Testes de Integração da API (/api/v1/detector/check) ---

def test_check_advertorial_risco_alto_autorizado():
    """
    Valida a detecção de Risco Alto (Card 1) e a verificação 
    de operadoras autorizadas (Card 2).
    
    """
    response = client.post("/api/v1/detector/check", json=MOCK_PAYLOAD_RISCO_ALTO)
    
    assert response.status_code == 200
    data = response.json()
    
    # 1. Validação do Score (Card 1)
    assert data["score"] > 70
    assert data["risk_label"] == "Alto"
    assert "DECEPTIVE_MATCHES" in data["advertorial_evidence"]
    assert "OPERATOR_MATCHES" in data["advertorial_evidence"]
    
    # 2. Validação da Verificação SPA (Card 2)
    assert len(data["spa_verification"]) == 2 # Betano e Bet365
    
    betano_check = next(item for item in data["spa_verification"] if item["domain"] == "betano")
    bet365_check = next(item for item in data["spa_verification"] if item["domain"] == "bet365")
    
    assert betano_check["status"] == "AUTHORIZED"
    assert bet365_check["status"] == "AUTHORIZED"

def test_check_advertorial_risco_alto_nao_autorizado():
    """
    Valida a detecção de Risco Alto (Card 1) e a verificação 
    de operadora NÃO autorizada (Card 2).
    
    """
    response = client.post("/api/v1/detector/check", json=MOCK_PAYLOAD_RISCO_ALTO_NAO_AUTORIZADO)
    
    assert response.status_code == 200
    data = response.json()

    # 1. Validação do Score (Card 1)
    assert data["score"] > 70
    assert data["risk_label"] == "Alto"
    assert "DECEPTIVE_MATCHES" in data["advertorial_evidence"]
    assert "OPERATOR_MATCHES" in data["advertorial_evidence"]
    
    # 2. Validação da Verificação SPA (Card 2)
    assert len(data["spa_verification"]) == 1 # Apenas Blaze
    
    blaze_check = data["spa_verification"][0]
    assert blaze_check["domain"] == "blaze"
    assert blaze_check["status"] == "UNKNOWN_OR_UNAUTHORIZED"

def test_check_advertorial_risco_baixo():
    """
    Valida o Risco Baixo (Card 1) e a ausência de verificação SPA (Card 2).
    
    """
    response = client.post("/api/v1/detector/check", json=MOCK_PAYLOAD_RISCO_BAIXO)
    
    assert response.status_code == 200
    data = response.json()

    # 1. Validação do Score (Card 1)
    assert data["score"] == 0
    assert data["risk_label"] == "Baixo"
    assert not data["advertorial_evidence"] # Sem evidências
    
    # 2. Validação da Verificação SPA (Card 2)
    # Como nenhum domínio de operadora foi encontrado, a verificação deve estar vazia.
    assert len(data["spa_verification"]) == 0