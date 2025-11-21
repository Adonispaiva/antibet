# 🛡️ AntiBet - Diário e Controle Emocional de Apostas (MVP - Versão Mobile)

Este projeto implementa o Mínimo Produto Viável (MVP) do AntiBet, um aplicativo dedicado ao controle e gestão de apostas. A arquitetura foi desenvolvida com foco em segurança, escalabilidade e manutenibilidade.

## ⚙️ Arquitetura e Stack Tecnológica

O módulo `mobile` (Flutter) segue o padrão de **Clean Architecture** e **Service Layer** para desacoplamento de responsabilidades:

* **Linguagem:** Dart (Flutter 3.x+)
* **Gestão de Estado:** Riverpod (Provider/Notifier Pattern)
* **Navegação:** GoRouter (Roteamento declarativo seguro)
* **Rede/API:** Dio (com Interceptors para Segurança e Logs)
* **Testes:** flutter_test, integration_test, mocktail (para testes unitários).

A estrutura de pastas (`lib/features/{feature}/data | presentation`) separa claramente o UI (Widgets/Screens) da Lógica de Negócio (Providers) e da Camada de Dados (Services/Models).

## 🚀 Como Executar o Projeto Mobile

Para iniciar o projeto em seu ambiente de desenvolvimento:

1.  **Pré-requisitos:** Certifique-se de ter o **Flutter SDK (3.x+)** e o **Dart SDK** instalados.
2.  **Diretório:** Navegue até o diretório do projeto mobile.

```bash
cd D:\projetos-inovexa\antibet\mobile