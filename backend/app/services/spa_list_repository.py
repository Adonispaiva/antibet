import json
import threading
import os
from functools import lru_cache
from typing import Set

import logging
from fastapi import Depends

# Importa as configurações do Card 5
from app.config.settings import Settings, settings

# Configuração de logging
logger = logging.getLogger(__name__)

class SPAListRepository:
    """
    Gerencia o acesso à lista de domínios SPA autorizados (Card 4).

    Lê a partir de um arquivo JSON (simulando uma fonte de dados externa).
    O caminho do arquivo é fornecido via objeto Settings.
    """
    _instance = None
    _lock = threading.Lock()

    def __new__(cls, settings_obj: Settings):
        # Implementação de Singleton thread-safe (Apenas a primeira chamada cria)
        if cls._instance is None:
            with cls._lock:
                if cls._instance is None:
                    # Passa o settings_obj para a nova instância
                    cls._instance = super(SPAListRepository, cls).__new__(cls)
                    cls._instance._settings = settings_obj # Armazena settings no new
        return cls._instance

    def __init__(self, settings_obj: Settings):
        # A flag protege a inicialização (que carrega o arquivo)
        if not hasattr(self, '_initialized'):
            with self._lock:
                if not hasattr(self, '_initialized'):
                    # O settings_obj já foi armazenado no __new__
                    self._authorized_domains: Set[str] = set()
                    self._load_domains()
                    self._initialized = True
        
        # O self._settings deve ser o settings_obj injetado
        self._settings = settings_obj


    def _load_domains(self):
        """
        Carrega os domínios do arquivo JSON para a memória (em um set),
        usando o caminho fornecido pelo Settings.
        """
        config_file_path = self._settings.SPA_LIST_FILE_PATH # << USO DO CARD 5
        
        try:
            logger.info(f"Carregando lista de SPAs autorizados de: {config_file_path}")
            with open(config_file_path, 'r', encoding='utf-8') as f:
                data = json.load(f)
                
                # Espera-se que o JSON seja: { "authorized_domains": ["exemplo.com", ...] }
                domains = data.get("authorized_domains", [])
                
                if not isinstance(domains, list):
                    raise ValueError("Chave 'authorized_domains' não é uma lista.")
                    
                self._authorized_domains = {str(domain).lower() for domain in domains}
                logger.info(f"{len(self._authorized_domains)} domínios SPA carregados.")

        except FileNotFoundError:
            logger.error(f"Arquivo de configuração de SPA não encontrado: {config_file_path}")
            self._authorized_domains = set()
        except json.JSONDecodeError:
            logger.error(f"Erro ao decodificar JSON de SPAs: {config_file_path}")
            self._authorized_domains = set()
        except Exception as e:
            logger.error(f"Erro inesperado ao carregar domínios SPA: {e}")
            self._authorized_domains = set()

    def get_authorized_domains(self) -> Set[str]:
        """
        Retorna o conjunto (set) de domínios autorizados.
        """
        return self._authorized_domains

    def is_domain_authorized(self, domain: str) -> bool:
        """
        Verifica se um domínio específico está no 'set' (Busca O(1)).
        """
        return domain.lower() in self._authorized_domains

# --- Factory para Injeção de Dependência (FastAPI) ---

@lru_cache(maxsize=1)
def get_spa_list_repository(
    settings_obj: Settings = Depends(lambda: settings) # Injeta o singleton settings
) -> SPAListRepository:
    """
    Ponto de entrada (Singleton) para o sistema de injeção de dependência.
    
    Injeta as configurações e garante que o repositório seja criado
    e inicializado apenas uma vez.
    """
    return SPAListRepository(settings_obj=settings_obj)