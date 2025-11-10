from typing import List, Dict
import random

# --- BASE DE CONHECIMENTO (Extraído de Base_de_Conhecimento_AntiBet_v2.md) ---

# Em produção, este texto seria carregado de um arquivo, chunkado e inserido em um VectorDB.
_KNOWLEDGE_BASE_TEXT = [
    {
        "id": "TCC",
        "keywords": ["impulso", "ansiedade", "pensamento automático", "crise", "recaída"],
        "content": "A Terapia Cognitivo-Comportamental (TCC) foca no reconhecimento e reestruturação de pensamentos automáticos (ex: 'eu preciso recuperar o dinheiro'). Isso é o primeiro passo para quebrar o ciclo. Use a TCC para desafiar a lógica da aposta.",
        "source": "Fundamentos Psicológicos"
    },
    {
        "id": "URGE_SURFING",
        "keywords": ["vontade de jogar", "impulso", "ansiedade", "controle"],
        "content": "Mindfulness e Urge Surfing: Quando o impulso vier, imagine-o como uma onda. Você não precisa surfá-la. Deixe-a passar, e ela perderá a força em 15 minutos. Use técnicas de respiração (ex: 4-7-8) para aterrar a crise.",
        "source": "Técnicas Aplicadas"
    },
    {
        "id": "FINANCEIRO",
        "keywords": ["dinheiro", "perdas", "economia", "lucro"],
        "content": "Psicoeducação: Lembre-se, 97% dos apostadores perdem a longo prazo. O foco deve ser no Simulador de Oportunidade Perdida e na Economia Acumulada. Redirecione o pensamento de perda para o ganho real (saúde financeira).",
        "source": "Conteúdo Educativo e Financeiro"
    },
    {
        "id": "ETICA",
        "keywords": ["terapia", "clínico", "psicólogo", "ajuda profissional"],
        "content": "Regra Ética: O AntiBet não substitui tratamento psicológico ou médico. Sempre reitere a importância de buscar ajuda profissional (CAPS AD, CVV).",
        "source": "Princípios Éticos"
    }
]

# --- SERVIÇO RAG ---

class RAGService:
    """
    Simula o serviço de Retrieval-Augmented Generation (RAG).
    Responsável por buscar o contexto relevante na Base de Conhecimento para injetar no Prompt do LLM.
    """

    def __init__(self):
        # Em produção, aqui seria a conexão com o cliente do VectorDB (ex: ChromaDB)
        print("RAGService inicializado. Base de Conhecimento carregada (4 chunks).")

    def _get_relevant_chunks(self, keywords: List[str]) -> List[str]:
        """Simula a busca semântica no VectorDB."""
        
        relevant_chunks = []
        
        # Simulação de Score de Relevância (busca por palavra-chave)
        for chunk in _KNOWLEDGE_BASE_TEXT:
            if any(kw in keywords for kw in chunk["keywords"]):
                # Retorna o conteúdo relevante formatado
                relevant_chunks.append(f"({chunk['id']} - Fonte: {chunk['source']}): {chunk['content']}")
                
        return relevant_chunks

    def retrieve_context(self, user_query: str) -> str:
        """
        Busca e compila o contexto mais relevante para a query do usuário.
        """
        user_query_lower = user_query.lower()
        
        # 1. Identificação de Intenção (Keywords)
        keywords_detected = []
        if "apostar" in user_query_lower or "jogar" in user_query_lower or "impulso" in user_query_lower:
            keywords_detected.extend(["crise", "impulso", "ansiedade", "vontade de jogar"])
        
        if "dinheiro" in user_query_lower or "perdi" in user_query_lower or "finanças" in user_query_lower:
            keywords_detected.extend(["dinheiro", "perdas", "economia"])
            
        if "psicólogo" in user_query_lower or "terapia" in user_query_lower:
             keywords_detected.extend(["terapia", "clínico", "psicólogo"])

        # 2. Busca dos Chunks Relevantes (sem duplicação)
        chunks = self._get_relevant_chunks(keywords_detected)
        
        if not chunks:
            # Se não houver relevância direta, injeta um princípio básico de segurança (Ética/TCC)
            return _KNOWLEDGE_BASE_TEXT[0]["content"] # Retorna o chunk de TCC

        # 3. Compilação do Contexto
        context_string = "\n".join(chunks)
        
        return f"""
--- CONTEXTO RAG INJETADO ---
{context_string}
--- FIM RAG ---
"""

# --- EXEMPLO DE USO (Para ser importado pelo chat.py) ---
# rag_service = RAGService()
# contexto = rag_service.retrieve_context("Estou com vontade de apostar e preciso de ajuda.")
# print(contexto)