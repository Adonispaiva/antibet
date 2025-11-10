import os
from pydantic_settings import BaseSettings # Importação ajustada para Pydantic V2+

# Define o diretório base do projeto (D:\projetos-inovexa-m\antibet\backend)
BASE_DIR = os.path.dirname(os.path.dirname(os.path.abspath(__file__)))

class Settings(BaseSettings):
    """
    Configurações da aplicação AntiBet Backend.

    As configurações são carregadas automaticamente de:
    1. Variáveis de ambiente
    2. Arquivo .env (se configurado, que faremos a seguir)
    """

    # --- Configurações de Ambiente ---

    # Exemplo de configuração FastAPI/Uvicorn
    PROJECT_NAME: str = "AntiBet Backend"
    API_V1_STR: str = "/api/v1"
    DEBUG: bool = True # Deve ser False em produção
    
    # --- Configuração do Card 4 (SPA List Repository) ---
    
    # O caminho completo para o arquivo JSON da lista autorizada de SPAs.
    # Por padrão, assume que está na raiz do backend (onde colocamos agora)
    # Ex: D:\projetos-inovexa-m\antibet\backend\spa_authorized_list.json
    SPA_LIST_FILE_PATH: str = os.path.join(
        os.path.dirname(BASE_DIR), # Volta para D:\projetos-inovexa-m\antibet
        "backend",
        "spa_authorized_list.json"
    )

    # Nota sobre Pydantic Settings:
    # Por padrão, ele procura um arquivo .env, mas para o ambiente
    # de desenvolvimento, definimos a variável manualmente acima.
    
    class Config:
        # Pydantic V1/V2 - Define o arquivo de variáveis de ambiente
        env_file = ".env"
        # Permite que as configurações sejam injetadas em outros módulos
        # Não é estritamente necessário para BaseSettings, mas é boa prática
        extra = 'allow' 

# Instância única das configurações
settings = Settings()