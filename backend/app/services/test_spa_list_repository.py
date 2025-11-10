import pytest
import json
from unittest.mock import patch, mock_open, MagicMock

# Importa os módulos a serem testados
from app.services.spa_list_repository import SPAListRepository, get_spa_list_repository
from app.config.settings import Settings # Para criar o mock de Settings

# --- Fixtures e Configuração ---

@pytest.fixture(autouse=True)
def reset_repository_singleton():
    """
    Garante que cada teste receba uma instância 'limpa' do repositório,
    resetando o cache do singleton e a flag de inicialização interna.
    """
    SPAListRepository._instance = None
    if hasattr(SPAListRepository, '_initialized'):
        del SPAListRepository._initialized
    get_spa_list_repository.cache_clear()


@pytest.fixture
def mock_settings():
    """Cria um mock do objeto Settings, fornecendo um caminho de arquivo simulado."""
    # Usamos um MagicMock, mas com o atributo que o Repositório espera
    mock_set = MagicMock(spec=Settings)
    mock_set.SPA_LIST_FILE_PATH = '/mock/path/spa_list.json'
    return mock_set

@pytest.fixture
def mock_get_settings(mock_settings):
    """
    Mocka o ponto de injeção de dependência do FastAPI para retornar nosso mock de Settings.
    
    Usado para testar o get_spa_list_repository (o factory).
    """
    with patch('app.services.spa_list_repository.settings', new=mock_settings):
        # O Repositório e o Factory usam o objeto 'settings' global, este patch é crucial
        yield mock_settings

# --- Testes de Q.R. de Carregamento ---

def test_successful_load(mock_settings):
    """
    Testa o carregamento bem-sucedido de uma lista JSON válida, injetando Settings.
    """
    # 1. Arrange: Dados mockados do JSON
    mock_data = {
        "authorized_domains": [
            "dominio1.com",
            "app.dominio2.com.br"
        ]
    }
    mock_json = json.dumps(mock_data)
    
    # 2. Act: Mocka a abertura do arquivo
    with patch(
        'builtins.open', 
        mock_open(read_data=mock_json)
    ) as mock_file:
        
        # Instancia diretamente, injetando o mock_settings
        repo = SPAListRepository(settings_obj=mock_settings)
        domains = repo.get_authorized_domains()

    # 3. Assert
    # O caminho usado deve ser o que foi injetado pelo mock_settings
    mock_file.assert_called_with('/mock/path/spa_list.json', 'r', encoding='utf-8')
    assert len(domains) == 2 
    
    # Testa a função de verificação (a lógica de busca)
    assert repo.is_domain_authorized("DOMINIO1.COM") is True
    assert repo.is_domain_authorized("dominio-aleatorio.com") is False

def test_file_not_found_error(mock_settings, caplog):
    """Testa o comportamento se o JSON não for encontrado."""
    
    # 1. Arrange: Configura o mock 'open' para lançar FileNotFoundError
    with patch('builtins.open', mock_open()) as mock_file:
        mock_file.side_effect = FileNotFoundError("Arquivo mock não encontrado")
        
        # 2. Act
        repo = SPAListRepository(settings_obj=mock_settings)
        domains = repo.get_authorized_domains()

    # 3. Assert
    assert len(domains) == 0 # O set deve estar vazio
    assert "Arquivo de configuração de SPA não encontrado" in caplog.text


def test_json_decode_error(mock_settings, caplog):
    """Testa o comportamento se o JSON estiver mal formatado."""
    
    # 1. Arrange: JSON inválido
    mock_json = '{"domains": ["list"]' # Falta '}'
    
    # 2. Act
    with patch(
        'builtins.open', 
        mock_open(read_data=mock_json)
    ):
        repo = SPAListRepository(settings_obj=mock_settings)
        domains = repo.get_authorized_domains()

    # 3. Assert
    assert len(domains) == 0 # O set deve estar vazio
    assert "Erro ao decodificar JSON de SPAs" in caplog.text

# --- Teste de Comportamento Arquitetural (Singleton) ---

def test_singleton_behavior(mock_get_settings):
    """
    Garante que o factory (get_spa_list_repository) retorna a mesma instância,
    e que o arquivo é lido apenas uma vez, mesmo com a injeção de dependência.
    """
    mock_data = {"authorized_domains": ["teste.com"]}
    
    with patch(
        'builtins.open', 
        mock_open(read_data=json.dumps(mock_data))
    ) as mock_file:
        
        repo1 = get_spa_list_repository()
        repo2 = get_spa_list_repository()

    # 1. Assert: Devem ser a MESMA instância
    assert repo1 is repo2
    
    # 2. Assert: O arquivo deve ter sido lido apenas UMA vez (Comportamento Singleton)
    mock_file.assert_called_once()