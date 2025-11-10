# Backlog AntiBet — Advertorial de apostas (09/10/2025)

**Contexto:** proliferam “matérias” de casas de apostas travestidas de reportagem (advertoriais). Precisamos blindar usuários e criar ferramentas internas para detectar, alertar e educar.

---

## Card 1 — Detector de Advertorial pró‑aposta (web/article scanner)
- **Objetivo:** identificar páginas com características de publicidade de apostas (ex.: “conteúdo patrocinado”, CTAs de cadastro/bônus, linguagem de “estratégia/como ganhar”).
- **MVP (escopo):**
  - Heurística local (regex + regras) sobre URL, HTML e texto:
    - URL contém: `conteudo-patrocinado|publ(i|ieditorial)|branded|afiliado|parceria`.
    - Texto/HTML contém rótulos: “conteúdo patrocinado”, “publi”, “parceria paga”, “advertorial”.
    - Presença de CTAs: “cadastre‑se”, “ganhe bônus”, “aposte agora”.
    - Palavras-chave operadoras: `bet|kto|blaze|pixbet|betano|stake|bet365|leoVegas|1xbet` (lista extensível).
    - Linguagem enganosa: “estratégia infalível”, “como ganhar sempre”, “hack do tigrinho”.
  - Score de risco (0–100) + rótulo: **Baixo/Moderado/Alto**.
  - SDK AntiBet (Python/Node) + CLI: `antibet detect <url|html>`.
  - Integração com Command Center: log de escaneios, revisão manual e ajuste das regras em UI.
- **Critérios de aceite:**
  - >=90% de recall em amostra rotulada interna; FP ≤15% em portais legítimos.
  - Exportar relatório JSON (motivos + trechos citados) e gerar badge visual para extensão/navegador.
- **Privacidade/LGPD:** processamento local por padrão; opt‑in para envio anônimo de amostras.
- **Prioridade:** P1 | **Esforço:** M | **Owner:** GPT‑Inovexa (Leo Vinci)
- **Dependências:** lista de marcas/termos; módulo de scraping seguro; UI de tuning no Command Center.

---

## Card 2 — Verificador SPA (autorização de operadora)
- **Objetivo:** conferir se a casa de apostas vinculada à página está **autorizada** pela Secretaria de Prêmios e Apostas (SPA/MF) — **autorizada ≠ segura**, mas informa o usuário.
- **MVP (escopo):**
  - Ingestão periódica (CSV/JSON) da lista oficial da SPA.
  - Normalização de nomes/domínios (fuzzy match e WHOIS simplificado quando possível).
  - API local: `GET /antibet/spa/check?domain=...` retornando {status: authorized|unknown|revoked, evidências}.
  - Integração no detector (Card 1) para compor score e mensagem ao usuário.
- **Critérios de aceite:**
  - Cache atualizado ≤24h; acurácia de domínio ≥95% em amostra rotulada.
  - UI no Command Center com histórico de verificações e diffs de listas.
- **Privacidade/LGPD:** zero PII; apenas metadados de domínio.
- **Prioridade:** P1 | **Esforço:** M | **Owner:** GPT‑Inovexa (Leo Vinci)
- **Dependências:** job de ingestão; storage leve; módulo de normalização de domínios.

---

## Card 3 — Rotulagem de Risco + Educação (extensão/app)
- **Objetivo:** alertar e educar o usuário no momento do consumo do conteúdo.
- **MVP (escopo):**
  - Extensão de navegador (Chrome/Edge) e widget mobile dentro dos apps da Inovexa.
  - Badge visível: “Risco Alto • Slot/RNG • Promessa de ganho” (mensagens baseadas no score + tipo de jogo).
  - Cartão educativo 1‑clique: explica **RNG/RTP**, risco de dependência e oferece ajuda (AntiBet/recursos).
  - Botões: **Denunciar** (gera pacote com URL + evidências), **Bloquear domínio/termos** (lista local + DNS opcional).
- **Critérios de aceite:**
  - UX não intrusiva; opt‑out por site; acessibilidade (atalhos/aria‑labels).
  - Telemetria opt‑in, anonimizável.
- **Privacidade/LGPD:** sem coleta pessoal por padrão; consentimento granular.
- **Prioridade:** P1 | **Esforço:** M | **Owner:** GPT‑Inovexa (Leo Vinci)
- **Dependências:** SDK do Detector (Card 1); integração SPA (Card 2); módulo de UI.

---

### Plano de 7 dias (sugestão)
- **D1–D2:** protótipo do **Detector** (regex+score) + CLI; base de testes.
- **D3:** serviço **Verificador SPA** (ingestão mock + API).
- **D4–D5:** extensão Chromium mínima (badge + popup com resultado).
- **D6:** painel no Command Center (logs, ajuste de regras, importar lista de termos).
- **D7:** testes, pacote instalador da extensão, guia de uso e versionamento.

**Observações:**
- Mensagens anti‑promessa e de suporte devem ser claras: *“Jogo envolve risco real de perda; não há método garantido”*.
- Reaproveitar no **Clara** o cartão educativo (visão prevenção/apoio).

