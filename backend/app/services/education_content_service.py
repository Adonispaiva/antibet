from typing import Dict, Any, List

# --- BASE DE CONHECIMENTO DOS CARTÕES EDUCATIVOS (Card 3) ---
#

_EDUCATION_CARDS: Dict[str, Dict[str, str]] = {
    "DECEPTIVE": {
        "title": "Cuidado: Promessa de Ganho Fácil",
        "content": "Conteúdos que prometem 'estratégia infalível' ou 'hack' são enganosos. Em jogos de azar (RNG), o resultado é aleatório e a casa sempre tem a vantagem (RTP).",
        "help_link_text": "Entenda o que é RNG e RTP"
    },
    "CTA": {
        "title": "Alerta: Incentivo ao Cadastro",
        "content": "Este conteúdo está ativamente incentivando o cadastro ou depósito. Bônus são estratégias para atrair jogadores, mas geralmente possuem regras que dificultam saques reais.",
        "help_link_text": "Precisa de ajuda? Fale com o AntiBet Coach."
    },
    "OPERATOR": {
        "title": "Aviso: Publicidade de Aposta",
        "content": "Esta página promove ativamente uma ou mais casas de apostas. O jogo pode causar dependência financeira e emocional.",
        "help_link_text": "Conheça os riscos (DSM-5)"
    },
    "UNAUTHORIZED_OPERATOR": {
        "title": "Risco Elevado: Operadora Não Autorizada",
        "content": "A(s) operadora(s) mencionada(s) nesta página NÃO possuem autorização da Secretaria de Prêmios e Apostas (SPA) do Ministério da Fazenda. O risco de fraude é maior.",
        "help_link_text": "Verifique a lista oficial (Card 2)"
    },
    "DEFAULT": {
        "title": "Jogo Envolve Risco Real",
        "content": "Todo jogo de azar envolve risco real de perda financeira e pode levar à dependência. Não existe método garantido para ganhar.",
        "help_link_text": "Precisa de ajuda? Fale com o AntiBet Coach."
    }
}


class EducationContentService:
    """
    Serviço para fornecer os textos educativos (Card 3) com base no 
    risco detectado pelo Card 1 e na verificação do Card 2.
   
    """

    def __init__(self):
        print("EducationContentService inicializado com cartões educativos.")

    def get_educational_card(self, advertorial_report: Dict[str, Any]) -> Dict[str, str]:
        """
        Seleciona o cartão educativo mais relevante com base no relatório 
        consolidado do detector de advertorial (API).
        """
        
        # 1. Verifica o Risco de Autorização (Card 2) - PRIORIDADE ALTA
        spa_verification = advertorial_report.get("spa_verification", [])
        if any(v["status"] == "UNKNOWN_OR_UNAUTHORIZED" for v in spa_verification):
            return _EDUCATION_CARDS["UNAUTHORIZED_OPERATOR"]
            
        # 2. Verifica Evidências de Linguagem Enganosa (Card 1) - PRIORIDADE ALTA
        evidence = advertorial_report.get("advertorial_evidence", {})
        if "DECEPTIVE_MATCHES" in evidence:
            return _EDUCATION_CARDS["DECEPTIVE"]
            
        # 3. Verifica CTAs (Card 1)
        if "CTA_MATCHES" in evidence:
            return _EDUCATION_CARDS["CTA"]
            
        # 4. Verifica Menção a Operadoras (Card 1)
        if "OPERATOR_MATCHES" in evidence:
            return _EDUCATION_CARDS["OPERATOR"]

        # 5. Fallback Padrão
        return _EDUCATION_CARDS["DEFAULT"]

# Exemplo de uso (para ser usado pelo Router ou UI):
# if __name__ == "__main__":
#     service = EducationContentService()
    
#     # Simulação de um relatório de Risco Alto (Linguagem Enganosa)
#     mock_report_deceptive = {
#         "score": 80,
#         "risk_label": "Alto",
#         "advertorial_evidence": {"DECEPTIVE_MATCHES": ["hack do tigrinho"]},
#         "spa_verification": []
#     }
#     card = service.get_educational_card(mock_report_deceptive)
#     print(f"Risco: DECEPTIVE -> Título: {card['title']}")

#     # Simulação de um relatório de Risco Baixo (Apenas Operadora Autorizada)
#     mock_report_auth_operator = {
#         "score": 30,
#         "risk_label": "Moderado",
#         "advertorial_evidence": {"OPERATOR_MATCHES": ["betano"]},
#         "spa_verification": [{"domain": "betano", "status": "AUTHORIZED", "details": {}}]
#     }
#     card = service.get_educational_card(mock_report_auth_operator)
#     print(f"Risco: OPERATOR -> Título: {card['title']}")