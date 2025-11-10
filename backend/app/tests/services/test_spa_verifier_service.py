import pytest
from unittest.mock import MagicMock

from app.services.spa_verifier_service import SPAVerifierService
from app.services.spa_list_repository import SPAListRepository # Para tipagem do mock

# Testes para o serviço de verificação de SPA (Card 2)

@pytest.fixture
def mock_repository() -> MagicMock:
    """Fixture para criar um mock do repositório."""
    # O mock simula o comportamento da fonte de dados (Card 4)
    return MagicMock(spec=SPAListRepository)

@pytest.fixture
def verifier_service(mock_repository: MagicMock) -> SPAVerifierService:
    """
    Fixture para criar uma instância do serviço, injetando o mock.
    """
    return SPAVerifierService(repository=mock_repository)

# --- Testes de Verificação de Domínio (usando o mock) ---

def test_url_is_authorized(verifier_service: SPAVerifierService, mock_repository: MagicMock):
    """
    Testa se o serviço chama corretamente o repositório para uma URL autorizada.
    """
    # 1. Arrange: Configura o mock para retornar True para o domínio esperado
    expected_domain = "app.exemplo-autorizado.com"
    mock_repository.is_domain_authorized.return_value = True
    
    authorized_url = "https://app.exemplo-autorizado.com/alguma/pagina"
    
    # 2. Act
    result = verifier_service.is_url_authorized(authorized_url)
    
    # 3. Assert
    assert result.is_authorized is True
    assert result.domain == expected_domain
    # Garante que o método do repositório foi chamado com o domínio normalizado
    mock_repository.is_domain_authorized.assert_called_once_with(expected_domain)

def test_url_is_not_authorized(verifier_service: SPAVerifierService, mock_repository: MagicMock):
    """
    Testa se o serviço chama corretamente o repositório para uma URL não autorizada.
    """
    # 1. Arrange: Configura o mock para retornar False
    expected_domain = "www.site-aleatorio.com"
    mock_repository.is_domain_authorized.return_value = False
    
    # O serviço deve remover o 'www.' internamente antes de chamar o repositório
    unauthorized_url = "https://www.site-aleatorio.com"
    
    # 2. Act
    result = verifier_service.is_url_authorized(unauthorized_url)
    
    # 3. Assert
    assert result.is_authorized is False
    assert result.domain == expected_domain # O domínio deve ser o resultado da normalização (sem 'www.')
    # Garante que o método foi chamado com o domínio normalizado ('site-aleatorio.com' após o serviço remover o 'www.')
    mock_repository.is_domain_authorized.assert_called_once_with("site-aleatorio.com")


# --- Testes de Normalização de URL (agora focados apenas no serviço) ---

def test_url_normalization_www(verifier_service: SPAVerifierService, mock_repository: MagicMock):
    """Testa se o 'www.' é removido para a verificação."""
    url = "https://www.exemplo-autorizado.com/login"
    
    verifier_service.is_url_authorized(url)
    
    # Garante que o repositório foi chamado com o domínio normalizado
    mock_repository.is_domain_authorized.assert_called_once_with("exemplo-autorizado.com")

def test_url_normalization_http(verifier_service: SPAVerifierService, mock_repository: MagicMock):
    """Testa se o 'http://' é removido para a verificação."""
    url = "http://app.exemplo-autorizado.com"
    
    verifier_service.is_url_authorized(url)
    
    mock_repository.is_domain_authorized.assert_called_once_with("app.exemplo-autorizado.com")

def test_url_normalization_no_protocol(verifier_service: SPAVerifierService, mock_repository: MagicMock):
    """Testa a verificação quando a URL vem sem protocolo."""
    url = "exemplo-autorizado.com/path"
    
    verifier_service.is_url_authorized(url)
    
    mock_repository.is_domain_authorized.assert_called_once_with("exemplo-autorizado.com")

def test_empty_url(verifier_service: SPAVerifierService, mock_repository: MagicMock):
    """Testa o comportamento com uma URL vazia."""
    url = ""
    
    result = verifier_service.is_url_authorized(url)
    
    assert result.is_authorized is False
    assert result.domain == ""
    # O repositório não deve ser chamado
    mock_repository.is_domain_authorized.assert_not_called()

def test_invalid_url_format(verifier_service: SPAVerifierService, mock_repository: MagicMock):
    """Testa um formato de URL inválido ou que não pode ser 'parseado'."""
    url = "isso nao e uma url"
    
    result = verifier_service.is_url_authorized(url)
    
    assert result.is_authorized is False
    # O domínio é retornado como o input original (minusculizado)
    assert result.domain == "isso nao e uma url"
    # O repositório é chamado com o domínio inválido (esperamos que retorne False)
    mock_repository.is_domain_authorized.assert_called_once_with("isso nao e uma url")