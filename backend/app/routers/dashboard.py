from fastapi import APIRouter, Depends, HTTPException
from pydantic import BaseModel, Field
from typing import List, Dict, Optional
import time

# Reutiliza o modelo do usuário e a função de autenticação (simulada) do módulo chat
from app.routers.chat import jwt_auth_guard, UserModel 

# --- MODELOS DE DADOS (Pydantic) ---

class Goal(BaseModel):
    id: str
    title: str
    is_completed: bool = False

class Reflection(BaseModel):
    title: str
    content: str
    source: str

class DashboardData(BaseModel):
    days_without_betting: int = Field(..., description="Métrica chave de gamificação.")
    daily_reflection: Reflection
    user_goals: List[Goal]
    # Outras métricas (ex: economia acumulada)
    accumulated_savings: float = 7345.50

# --- SIMULAÇÃO DE BANCO DE DADOS (Persistência por usuário) ---

# Dicionário simples para armazenar o estado das metas por ID de usuário
_user_goals_db: Dict[str, List[Goal]] = {
    "user_123": [ # Metas para o usuário mockado 'Adonis'
        Goal(id="g1", title="Evitar o celular na primeira hora do dia", is_completed=True),
        Goal(id="g2", title="Reservar 10 min para Mindfulness", is_completed=False),
        Goal(id="g3", title="Rever o Painel Financeiro antes das 18h", is_completed=False),
    ]
}

def get_daily_reflection() -> Reflection:
    """Simula a seleção da Reflexão Diária (que seria baseada em data)."""
    return Reflection(
        title="O Mito do Ganho e a TCC",
        content="A sensação de 'quase ganhar' é uma armadilha cerebral. Use a TCC para reestruturar esse pensamento automático.",
        source="TCC",
    )

# --- ROTAS DE DASHBOARD E GAMIFICAÇÃO ---

router = APIRouter()

@router.get("/data", response_model=DashboardData)
def get_dashboard_data(
    current_user: UserModel = Depends(jwt_auth_guard)
):
    """
    Fornece todos os dados críticos para a HomeView e ProgressView.
    Substitui os mocks dos Notifiers de Dashboard/Analytics.
    """
    user_id = current_user.id
    
    # 1. Busca metas do "Banco de Dados"
    goals = _user_goals_db.get(user_id, [])
    
    # 2. Simulação de Dias Sem Apostar (real seria cálculo complexo)
    days_without_betting = int((time.time() - 1609459200) / 86400) # Simula 4 anos
    
    # 3. Retorna os dados agregados
    return DashboardData(
        days_without_betting=days_without_betting,
        daily_reflection=get_daily_reflection(),
        user_goals=goals,
    )

@router.post("/goals/complete/{goal_id}", status_code=200)
def complete_goal(
    goal_id: str,
    current_user: UserModel = Depends(jwt_auth_guard)
):
    """
    Marca uma meta do usuário como concluída.
    Atualiza o estado da gamificação.
    """
    user_id = current_user.id
    goals = _user_goals_db.get(user_id)
    
    if not goals:
        raise HTTPException(status_code=404, detail="Usuário não possui metas.")
        
    goal_to_update: Optional[Goal] = None
    for goal in goals:
        if goal.id == goal_id:
            goal_to_update = goal
            break
            
    if not goal_to_update:
        raise HTTPException(status_code=404, detail="Meta não encontrada.")
    
    if goal_to_update.is_completed:
        return {"message": "Meta já estava concluída."}

    # Lógica de atualização (simulação)
    goal_to_update.is_completed = True
    
    # Lógica real: Acionar um evento de Gamificação (ex: +10 XP, Notificação)
    print(f"Meta '{goal_to_update.title}' marcada como completa para {current_user.nickname}.")
    
    return {"message": "Meta marcada como concluída com sucesso."}

# Exemplo de uso para inclusão no main.py:
# from app.routers import dashboard
# app.include_router(dashboard.router, prefix="/api/v1/dashboard", tags=["Dashboard & Goals"])