# 🏛️ Sumário da Arquitetura do MVP Funcional AntiBet Mobile

**Data:** 07 de Novembro de 2025
**Status:** **MVP Funcional (Frontend & Backend) - ARQUITETURA CONCLUÍDA**
**Objetivo:** Este documento serve como o blueprint final do Produto Mínimo Viável (MVP), detalhando todos os módulos e a interconexão entre o Frontend (Flutter) e o Backend (FastAPI).

---

## I. 📱 Frontend (Flutter) - Módulos e Arquitetura

A arquitetura do Frontend segue o padrão Flutter/Provider, com uma clara separação de responsabilidades (Service -> Notifier -> View).

### 1. Módulos Core Anti-Vício (Pânico, Risco, Autocontrole)

| Tipo | Componente | Função |
|:---|:---|:---|
| **Service** | `lockdown_service.dart` | Lógica de ativação e timer do modo de pânico. |
| **Service** | `behavioral_analytics_service.dart` | Cálculo do Escore de Risco e registro de eventos. |
| **Service** | `block_list_service.dart` | Gerenciamento e persistência da lista de bloqueio de sites/apps. |
| **Notifier**| `lockdown_notifier.dart` | Estado reativo do modo de pânico (timer, status). |
| **Notifier**| `behavioral_analytics_notifier.dart` | Estado reativo do Escore de Risco e alerta (`isHighRisk`). |
| **Notifier**| `block_list_notifier.dart` | Estado reativo da lista de bloqueio. |
| **Views** | `lockdown_view.dart` | Tela de contagem regressiva e contenção do pânico. |
| **Views** | `autoblock_settings_view.dart` | Tela de gerenciamento da lista de bloqueio. |

### 2. Módulos de Fluxo e Interface (Onboarding, Auth, Navegação)

| Tipo | Componente | Função |
|:---|:---|:---|
| **Service** | `auth_service.dart` | Mock para login, logout e persistência de token. |
| **Service** | `user_profile_service.dart` | Persistência dos dados de perfil (nome, gênero, idade). |
| **Notifier**| `auth_notifier.dart` | Estado de autenticação (`isLoggedIn`) e controle de acesso. |
| **Notifier**| `user_profile_notifier.dart` | Estado reativo dos dados de perfil para personalização da IA. |
| **Views** | `splash_screen.dart` | Ponto de entrada e roteamento condicional (Consentimento/Login/Home). |
| **Views** | `consent_screen.dart` | Tela de aceite ético e LGPD. |
| **Views** | `register_screen.dart` | Tela de cadastro inicial (coleta dados de personalização da IA). |
| **Views** | `login_view.dart` | Tela de autenticação para usuários existentes. |
| **Views** | `forgot_password_view.dart` | Tela de recuperação de senha. |
| **Views** | `risk_assessment_screen.dart` | Formulário de Autoavaliação de Risco (DSM-5 simplificado). |

### 3. Módulos de Experiência e Conteúdo (Dashboard, Chat, Ajuda)

| Tipo | Componente | Função |
|:---|:---|:---|
| **Service** | `dashboard_service.dart` | Gerenciamento e carregamento de Metas e Reflexões diárias. |
| **Notifier**| `dashboard_notifier.dart` | Estado reativo das Metas e Reflexões. |
| **Views** | `home_view.dart` | Dashboard principal (integra risco, metas, SOS). |
| **Views** | `chat_view.dart` | Interface conversacional com o AntiBet Coach. |
| **Views** | `progress_view.dart` | Placar de Metas e Dias sem Apostar (Gamificação). |
| **Views** | `finance_view.dart` | Painel de Economia Acumulada e simuladores financeiros. |
| **Views** | `family_support_view.dart` | Área de suporte para familiares e parceiros. |
| **Views** | `settings_view.dart` | Gerenciamento de conta, tema (`AppConfigNotifier`) e Logout. |

---

## II. 💻 Backend (FastAPI) - Serviços e Rotas da API

O Backend é a camada de segurança, autenticação e inteligência (LLM/RAG).

### 1. Core de Segurança e Autenticação

| Tipo | Componente | Rotas/Endpoints | Função |
|:---|:---|:---|:---|
| **Entrypoint** | `main.py` | `/health`, Montagem de Rotas | Inicialização do FastAPI e Middleware CORS. |
| **Routers** | `auth.py` | `/login`, `/logout` | Validação de credenciais e emissão de tokens JWT (simulados). |
| **Dependency**| `jwt_auth_guard` (em `chat.py`) | N/A | Validação do token JWT e injeção do `UserModel` nas rotas protegidas. |

### 2. Core de Inteligência Artificial (Orquestrador)

| Tipo | Componente | Rotas/Endpoints | Função |
|:---|:---|:---|:---|
| **Routers** | `chat.py` | `/send` | Orquestra a IA. Recebe a mensagem, injeta contexto e retorna resposta. |
| **Service** | `rag_service.py` | N/A | **Camada RAG:** Busca e injeta o contexto científico (TCC, Urge Surfing) no Prompt do LLM, usando a Base de Conhecimento. |
| **Service** | `_system_prompt` (em `chat.py`) | N/A | Define o tom (Empático, Zero Julgamento) e as regras de interação do AntiBet Coach. |

### 3. Core de Dados Dinâmicos (Gamificação e Dashboard)

| Tipo | Componente | Rotas/Endpoints | Função |
|:---|:---|:---|:---|
| **Routers** | `dashboard.py` | `/data`, `/goals/complete/{goal_id}` | Fornece dados agregados (Dias sem Apostar, Economia) e gerencia o status das Metas Pessoais. |
| **Models** | `DashboardData`, `Goal`, `Reflection` | N/A | Definição do schema de dados de gamificação e dashboard. |