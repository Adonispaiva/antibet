# AntiBet (Mobile) 🌌

> **Versão:** 1.0.0 (MVP Funcional)
> **Status:** Fase II Concluída (Integração API & CRUD)
> **Arquitetura:** Clean Architecture + Riverpod

## 📋 Sobre o Projeto

O **AntiBet** é uma aplicação móvel projetada para auxiliar usuários no controle e gestão de apostas, oferecendo ferramentas de diário (Journal), monitoramento de estatísticas financeiras e prevenção de perdas.

Esta versão **MVP (Mínimo Produto Viável)** foca na integridade dos dados e no fluxo completo de Criação, Leitura, Atualização e Exclusão (CRUD) de entradas no diário.

## 🛠️ Tech Stack & Decisões Arquiteturais

O projeto segue rigorosos padrões de engenharia de software para garantir escalabilidade e manutenibilidade.

- **Linguagem:** Dart 3.x
- **Framework:** Flutter 3.16+
- **Gerenciamento de Estado:** `flutter_riverpod` (Reatividade e Injeção de Dependência Segura)
- **Networking:** `dio` (com Interceptors personalizados para Auth e Logging)
- **Persistência Local:** `shared_preferences` (Gestão de Sessão/Tokens)
- **Serialização:** `json_serializable` & `json_annotation`
- **Testes:** `mockito`, `flutter_test`, `integration_test`

### Estrutura de Pastas (Clean Architecture)

lib/ ├── core/ # Camada de Infraestrutura e Utils │ ├── network/ # Configuração Dio, Interceptors │ └── ui/ # FeedbackManager, Temas ├── features/ # Módulos Funcionais (DDD) │ ├── auth/ # Autenticação (Login, Perfil) │ └── journal/ # Diário (Listagem, CRUD, Stats) └── main.dart # Entry Point & App Wrapper


## 🚀 Configuração e Execução

### Pré-requisitos
- Flutter SDK instalado e configurado no PATH.
- Emulador Android/iOS ou dispositivo físico conectado.

### Instalação

1. **Clonar o repositório:**
   ```bash
   git clone [https://github.com/Adonispaiva/antibet.git](https://github.com/Adonispaiva/antibet.git)
   cd antibet/mobile