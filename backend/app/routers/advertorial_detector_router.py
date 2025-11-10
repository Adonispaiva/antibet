from fastapi import APIRouter, Depends, HTTPException
from pydantic import BaseModel, Field
from typing import Dict, Any, List, Optional

# Importação dos Serviços de Heurística
from app.services.advertorial_detector_service import AdvertorialDetectorService
from app.services.spa_verifier_service import SPAVerifierService
from app.services.education_content_service import EducationContentService # (Card 3)

# --- Modelos de Dados (Pydantic) ---

class DetectRequest(BaseModel):
    """Schema para a requisição de análise."""
    url: str = Field(..., example="https://portal-exemplo.com/publieditorial/como-ganhar-facil")
    text_content: str = Field(..., example="Conteúdo da página... cadastre-se na betano...")

class SPAStatus(BaseModel):
    """Status de verificação de um domínio."""
    domain: str
    status: str
    details: Optional[Dict[str, Any]] = None

class EducationCard(BaseModel):
    """Conteúdo educativo (Card 3)."""
    title: str
    content: str
    help_link_text: str

class DetectResponse(BaseModel):
    """Schema do Relatório JSON final (Card 1 + Card 2 + Card 3)."""
    score: int
    risk_label: str
    advertorial_evidence: Dict[str, Any]
    spa_verification: List[SPAStatus]
    education_card: EducationCard # <-- EVOLUÇÃO (Card 3)
    url_analyzed: str

# --- Inicialização dos Serviços (Singleton Simulado) ---
detector_service = AdvertorialDetectorService()
spa_service = SPAVerifierService()
education_service = EducationContentService() # (Card 3)

# --- Router ---
router = APIRouter()

@router.post("/check", response_model=DetectResponse)
def check_advertorial_risk(request: DetectRequest):
    """
    Endpoint principal (Card 1 + Card 2 + Card 3).
    Recebe uma URL e seu conteúdo, calcula o score de advertorial (Card 1),
    verifica a autorização SPA (Card 2) e seleciona o cartão educativo (Card 3).
   
    """
    
    # --- Card 1: Detecção de Advertorial ---
    try:
        detection_report = detector_service.detect(request.url, request.text_content)
    except Exception as e:
        raise HTTPException(status_code=500, detail=f"Erro no serviço de detecção: {e}")

    # --- Card 2: Verificação SPA ---
    spa_verification_results = []
    detected_domains = detection_report.get("evidence", {}).get("OPERATOR_MATCHES", [])
    verified_domains = set()
    
    for domain in detected_domains:
        if domain not in verified_domains:
            try:
                spa_status = spa_service.check_domain_authorization(domain)
                spa_verification_results.append(SPAStatus(
                    domain=domain,
                    status=spa_status["status"],
                    details=spa_status["details"]
                ))
                verified_domains.add(domain)
            except Exception as e:
                spa_verification_results.append(SPAStatus(
                    domain=domain,
                    status="CHECK_ERROR",
                    details={"error": str(e)}
                ))

    # --- Card 3: Seleção do Conteúdo Educativo ---
    
    # Criamos um relatório consolidado (Cards 1+2) para o serviço de educação
    consolidated_report = {
        "score": detection_report["score"],
        "advertorial_evidence": detection_report["evidence"],
        "spa_verification": [spa.dict() for spa in spa_verification_results] # Converte Pydantic models para dicts
    }
    
    try:
        education_card_data = education_service.get_educational_card(consolidated_report)
        education_card = EducationCard(**education_card_data)
    except Exception as e:
        raise HTTPException(status_code=500, detail=f"Erro no serviço de educação: {e}")

    # 4. Compilação do Relatório Final
    return DetectResponse(
        score=detection_report["score"],
        risk_label=detection_report["risk_label"],
        advertorial_evidence=detection_report["evidence"],
        spa_verification=spa_verification_results,
        education_card=education_card, # <-- EVOLUÇÃO (Card 3)
        url_analyzed=detection_report["url_analyzed"]
    )