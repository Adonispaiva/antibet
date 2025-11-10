from fastapi import APIRouter, Body, Depends, HTTPException

from app.services.advertorial_detector_service import AdvertorialDetectorService, AdvertorialResult, get_advertorial_detector_service
from app.services.spa_verifier_service import SPAVerifierService, SPAScanResult, get_spa_verifier_service
from app.services.education_content_service import EducationContentService, EducationContent, get_education_content_service
from app.models.advertorial_detector_models import AdvertorialDetectorResponse

# 1. Definição do Router
advertorial_detector_router = APIRouter()

# 2. Definição do Request Body
class CheckContentRequest(BaseModel):
    url: str = Field(..., description="A URL da página a ser verificada.")
    content: str = Field(..., description="O conteúdo de texto extraído da página.")

# 3. Rota principal de verificação
@advertorial_detector_router.post(
    "/check",
    response_model=AdvertorialDetectorResponse,
    summary="Executa a análise de Advertorial, Verificação SPA e Cartão Educativo.",
    status_code=200
)
async def check_content_and_spa(
    request: CheckContentRequest,
    # Injeção de Dependência para os três serviços
    detector: AdvertorialDetectorService = Depends(get_advertorial_detector_service),
    verifier: SPAVerifierService = Depends(get_spa_verifier_service), # << REFATORAÇÃO AQUI
    educator: EducationContentService = Depends(get_education_content_service)
):
    """
    Orquestra os Cards 1, 2 e 3:
    - Card 1: Detecta o conteúdo de advertorial.
    - Card 2: Verifica se o domínio é um SPA autorizado (usando a fonte dinâmica Card 4).
    - Card 3: Seleciona o cartão educativo baseado nos resultados.
    """

    # --- Card 1: Detecção de Advertorial ---
    detector_result: AdvertorialResult = detector.check_content(request.content)
    
    # --- Card 2/4: Verificação de SPA ---
    # O verifier agora usa o repositório dinâmico (Card 4)
    spa_result: SPAScanResult = verifier.is_url_authorized(request.url)
    
    # --- Card 3: Seleção de Conteúdo Educativo ---
    # O educador usa os resultados do Card 1 e Card 2 para determinar a prioridade
    education_content: EducationContent = educator.select_education_card(
        is_advertorial=detector_result.is_advertorial,
        is_spa_authorized=spa_result.is_authorized
    )

    # 4. Agrega e retorna a resposta final
    return AdvertorialDetectorResponse(
        detector=detector_result,
        spa=spa_result,
        education=education_content
    )