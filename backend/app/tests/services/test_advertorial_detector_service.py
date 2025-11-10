import pytest
from app.services.advertorial_detector_service import AdvertorialDetectorService, AdvertorialResult

# Testes para o serviço de detecção (Card 1)

@pytest.fixture
def detector_service():
    """Fixture para criar uma instância reutilizável do serviço de detecção."""
    return AdvertorialDetectorService()

def test_detection_high_score_is_advertorial(detector_service: AdvertorialDetectorService):
    """
    Testa se o conteúdo com múltiplas palavras-chave de advertorial
    recebe uma pontuação alta (>= 3) e é classificado como advertorial.
    """
    # Texto carregado de gatilhos
    content = """
    Descubra o segredo! Este método exclusivo mudou minha vida.
    Aproveite a oportunidade única. Garantido!
    Clique aqui para saber mais sobre esta oferta especial.
    Não perca tempo, últimas unidades! Renda extra agora.
    """
    # Pontos esperados (lógica do serviço):
    # "método exclusivo": 1
    # "oportunidade única": 1
    # "Garantido": 1
    # "Clique aqui": 1
    # "oferta especial": 1
    # "últimas unidades": 1
    # "Renda extra": 1
    # Total = 7

    result = detector_service.check_content(content)

    assert result.is_advertorial is True
    assert result.score == 7
    assert len(result.matched_keywords) == 7
    assert "oportunidade única" in result.matched_keywords
    assert "garantido" in result.matched_keywords
    assert "clique aqui" in result.matched_keywords

def test_detection_low_score_not_advertorial(detector_service: AdvertorialDetectorService):
    """
    Testa se um conteúdo legítimo (ex: notícia) recebe pontuação baixa (< 3)
    e não é classificado como advertorial.
    """
    content = """
    O banco central anunciou hoje novas medidas para conter a inflação.
    A reunião ocorreu em Brasília e definiu a taxa de juros.
    Economistas analisam o impacto no mercado financeiro.
    """
    
    result = detector_service.check_content(content)

    assert result.is_advertorial is False
    assert result.score == 0
    assert len(result.matched_keywords) == 0

def test_detection_borderline_score_is_advertorial(detector_service: AdvertorialDetectorService):
    """
    Testa o limite (threshold = 3).
    Se a pontuação for exatamente 3, deve ser classificado como advertorial.
    """
    content = """
    Esta é uma oferta especial que garante sua vaga.
    Aproveite esta oportunidade.
    """
    # "oferta especial" (1), "garante" (1), "oportunidade" (1) = 3
    
    result = detector_service.check_content(content)

    assert result.is_advertorial is True
    assert result.score == 3
    assert "oferta especial" in result.matched_keywords
    assert "garante" in result.matched_keywords

def test_detection_empty_content(detector_service: AdvertorialDetectorService):
    """Testa o comportamento com entrada vazia."""
    content = ""
    result = detector_service.check_content(content)

    assert result.is_advertorial is False
    assert result.score == 0
    assert len(result.matched_keywords) == 0

def test_normalization_and_case_insensitivity(detector_service: AdvertorialDetectorService):
    """Garante que a detecção ignora maiúsculas/minúsculas e acentos."""
    
    # "GARANTIDO" (1), "OFERTA ESPECIAL" (1), "MÉTODO EXCLUSIVO" (1) = 3
    content = "GARANTIDO! OFERTA ESPECIAL. MÉTODO EXCLUSIVO."
    
    result = detector_service.check_content(content)

    assert result.is_advertorial is True
    assert result.score == 3
    assert "garantido" in result.matched_keywords
    assert "oferta especial" in result.matched_keywords
    assert "método exclusivo" in result.matched_keywords

def test_detection_accent_normalization(detector_service: AdvertorialDetectorService):
    """Testa a normalização de acentos."""
    
    # "últimas" (1), "unica" (de oportunidade única) (1) = 2
    content = "Veja as ultimas vagas desta oportunidade unica."
    
    result = detector_service.check_content(content)
    
    # Score 2 (abaixo de 3)
    assert result.is_advertorial is False
    assert result.score == 2
    assert "últimas" in result.matched_keywords
    assert "oportunidade única" in result.matched_keywords