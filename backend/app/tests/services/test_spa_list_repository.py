import pytest
import json
import builtins
from unittest.mock import patch, mock_open

from app.services.spa_list_repository import SPAListRepository, get_spa_list_repository

# Forçamos a re-criação da instância para cada teste
@pytest.fixture(autouse=True)
def reset_repository_singleton():
    """
    Garante que cada teste receba uma instância 'limpa' do repositório,
    resetando o cache do singleton.
    """
    SPAListRepository._instance = None
    SPAListRepository._initialized = False # Flag de inicialização interna
    get_spa_list_repository.cache_clear()


@pytest.fixture
def mock_config_path(monkeypatch):
    """Muda o caminho do arquivo de config para um mock."""
    monkeypatch.setattr(
        'app.services.spa_list_repository.CONFIG_FILE_PATH', 
        '/mock/path/spa_list.json'
    )

# --- Testes de Q.R. ---

def test_successful_load(mock_config_path):
    """
    Testa o carregamento bem-sucedido de uma lista JSON válida.
    """
    # 1. Arrange: Dados mockados do JSON
    mock_data = {
        "authorized_domains": [
            "dominio1.com",
            "app.dominio2.com.br",
            "DOMINIO1.COM" # Testa normalização (deve contar como 1)
        ]
    }
    mock_json = json.dumps(mock_data)
    
    # 2. Act: Mocka a abertura do arquivo (open)
    with patch(
        'builtins.open', 
        mock_open(read_data=mock_json)
    ) as mock_file:
        
        repo = get_spa_list_repository()
        domains = repo.get_authorized_domains()

    # 3. Assert
    mock_file.assert_called_with('/mock/path/spa_list.json', 'r', encoding='utf-8')
    assert len(domains) == 2 # "dominio1.com" e "app.dominio2.com.br" (ignora duplicata case-insensitive)
    assert "dominio1.com" in domains
    assert "app.dominio2.com.br" in domains
    
    # Testa a função de verificação (case-insensitive)
    assert repo.is_domain_authorized("DOMINIO1.COM") is True
    assert repo.is_domain_authorized("app.dominio2.com.br") is True

def test_unauthorized_domain(mock_config_path):
    """Testa a verificação de um domínio que não está na lista."""
    mock_data = {"authorized_domains": ["dominio1.com"]}
    
    with patch(
        'builtins.open', 
        mock_open(read_data=json.dumps(mock_data))
    ):
        repo = get_spa_list_repository()

    assert repo.is_domain_authorized("dominio-aleatorio.com") is False
    assert repo.is_domain_authorized("") is False # Teste de borda

def test_file_not_found_error(mock_config_path, caplog):
    """Testa o comportamento se o JSON não for encontrado."""
    
    # 1. Arrange: Configura o mock 'open' para lançar FileNotFoundError
    with patch('builtins.open', mock_open()) as mock_file:
        mock_file.side_effect = FileNotFoundError("Arquivo mock não encontrado")
        
        # 2. Act
        repo = get_spa_list_repository()
        domains = repo.get_authorized_domains()

    # 3. Assert
    assert len(domains) == 0 # O set deve estar vazio
    assert repo.is_domain_authorized("dominio1.com") is False
    
    # Verifica o log de erro (Q.R. de Observabilidade)
    assert "Arquivo de configuração de SPA não encontrado" in caplog.text

def test_json_decode_error(mock_config_path, caplog):
    """Testa o comportamento se o JSON estiver mal formatado."""
    
    # 1. Arrange: JSON inválido
    mock_json = '{"domains": ["list"]' # Falta '}'
    
    # 2. Act
    with patch(
        'builtins.open', 
        mock_open(read_data=mock_json)
    ):
        repo = get_spa_list_repository()
        domains = repo.get_authorized_domains()

    # 3. Assert
    assert len(domains) == 0 # O set deve estar vazio
    
    # Verifica o log de erro
    assert "Erro ao decodificar JSON de SPAs" in caplog.text

def test_singleton_behavior(mock_config_path):
    """Garante que a mesma instância seja sempre retornada."""
    
    mock_data = {"authorized_domains": ["dominio1.com"]}
    
    with patch(
        'builtins.open', 
        mock_open(read_data=json.dumps(mock_data))
    ) as mock_file:
        
        repo1 = get_spa_list_repository()
        repo2 = get_spa_list_repository()

    # Devem ser a MESMA instância
    assert repo1 is repo2
    
    # O arquivo deve ter sido lido apenas UMA vez (na primeira chamada)
    mock_file.assert_called_once()