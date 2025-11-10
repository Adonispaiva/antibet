import pytest
from fastapi.testclient import TestClient
from main import app
from app.config.settings import settings

# Cria o cliente de teste para a aplicação FastAPI
client = TestClient(app)

# --- Dados de Teste ---
# Payload de teste que atende ao modelo CheckContentRequest
TEST_PAYLOAD = {
    "url": "https://www.site-teste-validacao.com/page",
    "content": "Aproveite esta oportunidade exclusiva! Clique agora para ganhar um prêmio GARANTIDO."
}


# --- Testes de Q.R. de Integração ---

def test_health_check_root():
    """
    Testa a rota de saúde (Health Check) em /
    Garante que a API está de pé e retornando 200 OK.
    """
    response = client.get("/")
    
    assert response.status_code == 200
    assert response.json()["message"] == "AntiBet Backend API is running smoothly."
    assert "project" in response.json()
    assert response.json()["debug"] == settings.DEBUG

def test_advertorial_check_endpoint_is_reachable():
    """
    Testa se o endpoint principal /api/v1/check está acessível.
    Verifica se o retorno possui o formato de AdvertorialDetectorResponse.
    """
    # A rota é /api/v1/check, onde /api/v1 é o prefixo (settings.API_V1_STR)
    response = client.post(f"{settings.API_V1_STR}/check", json=TEST_PAYLOAD)

    # Esperamos 200 OK se a orquestração funcionar
    assert response.status_code == 200
    data = response.json()

    # Verifica a estrutura (AdvertorialDetectorResponse)
    assert "detector" in data
    assert "spa" in data
    assert "education" in data
    
    # Verifica um resultado esperado do Detector (o payload é um advertorial claro)
    assert data["detector"]["is_advertorial"] is True
    assert data["education"]["priority"] >= 1 # Deve ter alguma prioridade
    
    # O domínio não está na lista autorizada default, então is_authorized deve ser False
    assert data["spa"]["is_authorized"] is False

def test_advertorial_check_with_invalid_payload():
    """
    Testa o comportamento do FastAPI com um payload inválido (erro de Pydantic).
    """
    invalid_payload = {
        "url": "https://url.com",
        "conteudo": "faltou o campo 'content'" # Campo errado
    }
    
    response = client.post(f"{settings.API_V1_STR}/check", json=invalid_payload)
    
    # Esperamos um erro 422 (Unprocessable Entity) do FastAPI
    assert response.status_code == 422
    assert "detail" in response.json()
    # Verifica a mensagem de erro esperada do Pydantic
    assert "Field required" in str(response.json()["detail"])