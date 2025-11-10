from urllib.parse import urlparse
from pydantic import BaseModel
from fastapi import Depends
from .spa_list_repository import SPAListRepository, get_spa_list_repository

class SPAScanResult(BaseModel):
    """Modelo de Pydantic para o resultado da verificação de SPA."""
    is_authorized: bool
    domain: str

class SPAVerifierService:
    """
    Serviço de verificação de SPA (Card 2).

    Agora utiliza o SPAListRepository (Card 4) para verificar
    se uma URL pertence a uma lista autorizada de SPAs.
    """
    
    def __init__(self, repository: SPAListRepository):
        """
        Inicializa o serviço com o repositório injetado.
        
        Args:
            repository (SPAListRepository): O repositório (singleton)
                                            que contém a lista de domínios.
        """
        self.repository = repository

    def _extract_and_normalize_domain(self, url: str) -> str:
        """
        Extrai e normaliza o domínio de uma URL.
        (ex: 'https://www.exemplo.com/path' -> 'exemplo.com')
        """
        if not url:
            return ""
        
        try:
            # Garante que a URL tenha um schema para o urlparse funcionar
            if '://' not in url:
                url = f"http://{url}"
                
            parsed_url = urlparse(url)
            domain = parsed_url.netloc
            
            # Remove 'www.' se existir
            if domain.startswith('www.'):
                domain = domain[4:]
                
            return domain.lower()
        except Exception:
            # Se a URL for inválida (ex: "texto aleatório"), 
            # retorna o input original (que falhará a verificação, como esperado)
            return url.lower()

    def is_url_authorized(self, url: str) -> SPAScanResult:
        """
        Verifica se a URL pertence a um domínio SPA autorizado.
        """
        domain = self._extract_and_normalize_domain(url)
        
        if not domain:
            return SPAScanResult(is_authorized=False, domain="")

        # Lógica refatorada: usa o repositório (Card 4) em vez do mock
        is_auth = self.repository.is_domain_authorized(domain)
        
        return SPAScanResult(is_authorized=is_auth, domain=domain)

# --- Factory para Injeção de Dependência (FastAPI) ---

def get_spa_verifier_service(
    repo: SPAListRepository = Depends(get_spa_list_repository)
) -> SPAVerifierService:
    """
    Ponto de entrada do FastAPI para obter o serviço.
    
    O FastAPI injetará o singleton do repositório (get_spa_list_repository)
    e o passará para o construtor do serviço.
    """
    return SPAVerifierService(repository=repo)