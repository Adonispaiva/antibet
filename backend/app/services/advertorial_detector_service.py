import re
from typing import Dict, List, Any

# Constantes de Heurística baseadas no Backlog

# Palavras-chave de Operadoras (Peso Alto)
OPERATOR_KEYWORDS = r'bet|kto|blaze|pixbet|betano|stake|bet365|leoVegas|1xbet'

# CTAs (Call to Action) (Peso Alto)
CTA_KEYWORDS = r'cadastre-se|ganhe bônus|aposte agora|deposite aqui|jogue agora'

# Linguagem Enganosa (Peso Muito Alto)
DECEPTIVE_KEYWORDS = r'estratégia infalível|como ganhar sempre|hack do tigrinho|ganhe fácil|dinheiro rápido'

# Rótulos de Advertorial (Peso Médio)
LABEL_KEYWORDS = r'conteúdo patrocinado|publi|parceria paga|advertorial|branded|afiliado|parceria'

# URL suspeita (Peso Médio)
URL_KEYWORDS = r'conteudo-patrocinado|publ(i|ieditorial)|branded|afiliado|parceria'


class AdvertorialDetectorService:
    """
    Serviço de Heurística para detectar Advertoriais pró-aposta (Card 1).
    Analisa URL e conteúdo de texto para gerar um Score de Risco.
    """

    def __init__(self):
        # Compila os padrões Regex para performance
        self.rules = {
            "OPERATOR": (re.compile(OPERATOR_KEYWORDS, re.IGNORECASE), 25),
            "CTA": (re.compile(CTA_KEYWORDS, re.IGNORECASE), 20),
            "DECEPTIVE": (re.compile(DECEPTIVE_KEYWORDS, re.IGNORECASE), 40),
            "LABEL": (re.compile(LABEL_KEYWORDS, re.IGNORECASE), 15),
            "URL": (re.compile(URL_KEYWORDS, re.IGNORECASE), 15),
        }
        print("AdvertorialDetectorService inicializado com heurísticas.")

    def _find_matches(self, pattern: re.Pattern, text: str) -> List[str]:
        """Helper para encontrar todas as correspondências de um padrão."""
        return list(set(pattern.findall(text))) # Lista de correspondências únicas

    def detect(self, url: str, text_content: str) -> Dict[str, Any]:
        """
        Executa a detecção na URL e no conteúdo de texto, retornando o Score e as Evidências.
       
        """
        score = 0
        evidence = {}
        
        # 1. Análise da URL
        url_matches = self._find_matches(self.rules["URL"][0], url)
        if url_matches:
            score += self.rules["URL"][1]
            evidence["URL_MATCHES"] = url_matches
            
        # 2. Análise do Conteúdo de Texto
        
        # Operadoras
        op_matches = self._find_matches(self.rules["OPERATOR"][0], text_content)
        if op_matches:
            # Peso maior para múltiplas menções
            score += self.rules["OPERATOR"][1] + (len(op_matches) * 2) 
            evidence["OPERATOR_MATCHES"] = op_matches

        # CTAs
        cta_matches = self._find_matches(self.rules["CTA"][0], text_content)
        if cta_matches:
            score += self.rules["CTA"][1] + (len(cta_matches) * 5)
            evidence["CTA_MATCHES"] = cta_matches

        # Linguagem Enganosa
        deceptive_matches = self._find_matches(self.rules["DECEPTIVE"][0], text_content)
        if deceptive_matches:
            score += self.rules["DECEPTIVE"][1] + (len(deceptive_matches) * 10)
            evidence["DECEPTIVE_MATCHES"] = deceptive_matches

        # Rótulos
        label_matches = self._find_matches(self.rules["LABEL"][0], text_content)
        if label_matches:
            score += self.rules["LABEL"][1]
            evidence["LABEL_MATCHES"] = label_matches

        # 3. Normalização do Score (0-100)
        final_score = min(score, 100)
        
        # 4. Definição do Rótulo de Risco
        if final_score >= 70:
            risk_label = "Alto"
        elif final_score >= 30:
            risk_label = "Moderado"
        else:
            risk_label = "Baixo"

        return {
            "score": final_score,
            "risk_label": risk_label,
            "evidence": evidence,
            "url_analyzed": url
        }

# Exemplo de uso (para ser usado pelo Router):
# if __name__ == "__main__":
#     service = AdvertorialDetectorService()
#     mock_url = "https://portal-exemplo.com/publieditorial/como-ganhar-facil"
#     mock_content = """
#         Este é um conteúdo patrocinado. A melhor estratégia infalível 
#         é usar o hack do tigrinho. Cadastre-se na Blaze agora e ganhe bônus!
#         A Betano também é boa.
#     """
#     report = service.detect(mock_url, mock_content)
#     print(report)