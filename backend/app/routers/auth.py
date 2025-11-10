from fastapi import APIRouter, HTTPException, Depends
from pydantic import BaseModel, Field
from typing import Dict
import time

# --- MODELOS DE DADOS (Pydantic) ---

class LoginRequest(BaseModel):
    """Schema para a requisição de Login."""
    email: str = Field(..., example="usuario@inovexa.com")
    password: str = Field(..., example="senha_segura_123")

class TokenResponse(BaseModel):
    """Schema para a resposta de sucesso com o token JWT."""
    access_token: str
    token_type: str = "bearer"
    user_id: str

# --- ROTAS DE AUTENTICAÇÃO ---

# Cria um APIRouter para as rotas de autenticação (prefixo será definido no main.py)
router = APIRouter()

# --- SERVIÇO DE AUTENTICAÇÃO (Simulação) ---
# Em um ambiente real, esta lógica estaria em um serviço separado para injeção.

def verify_user_credentials(email: str, password: str) -> bool:
    """Simula a verificação de credenciais no banco de dados (PostgreSQL)."""
    # Regra de Segurança Crítica: Simulação de falha de credenciais para teste
    if password == "fail_login" or email == "fail@inovexa.com":
        return False
    
    # Simulação de credencial válida (aceita qualquer coisa, exceto a falha)
    return True

def create_access_token(user_id: str) -> str:
    """Simula a criação de um JSON Web Token (JWT) com validade."""
    # O token real seria assinado com um segredo (SECRET_KEY) e teria claims (exp, sub, iat).
    timestamp = int(time.time())
    return f"mock.jwt.token.{user_id}.{timestamp}"

# --- ENDPOINTS ---

@router.post("/login", response_model=TokenResponse, status_code=200)
def login_for_access_token(form_data: LoginRequest):
    """
    Autentica o usuário e retorna um token JWT.
    Substitui o mock do AuthService no Front-end.
    """
    email = form_data.email
    password = form_data.password
    
    # 1. Verifica as credenciais
    if not verify_user_credentials(email, password):
        # Lança exceção de erro padrão (401 Unauthorized)
        raise HTTPException(
            status_code=401,
            detail="Credenciais de login inválidas",
            headers={"WWW-Authenticate": "Bearer"},
        )
    
    # 2. Usuário mockado (o ID seria do banco de dados)
    mock_user_id = email.split('@')[0]
    
    # 3. Gera e retorna o token
    access_token = create_access_token(mock_user_id)
    
    return TokenResponse(
        access_token=access_token,
        user_id=mock_user_id
    )

@router.post("/logout", status_code=204)
def logout_user():
    """
    Invalida a sessão do usuário (simulação de blacklist de token no Redis).
    Retorna 204 No Content.
    """
    # Lógica real: Adicionar o token recebido no cabeçalho à blacklist do Redis
    # e remover cookies de sessão.
    
    return {"message": "Logout successful"}

# Exemplo de rota protegida que precisaria de Depends(oauth2_scheme)
# @router.get("/protected_data")
# def read_protected_data(token: str = Depends(oauth2_scheme)):
#     return {"data": "Informação sensível do AntiBet."}