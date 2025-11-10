# INSTRUÇÕES DE INSTALAÇÃO DE DEPENDÊNCIAS (BACKEND)
# Projeto AntiBet (NestJS)
# v1.2

Execute o comando abaixo para instalar as dependências necessárias.

## Dependências de Produção

npm install --save \
  @nestjs/common \
  @nestjs/core \
  @nestjs/config \
  @nestjs/typeorm \
  @nestjs/jwt \
  @nestjs/passport \
  @nestjs/mapped-types \
  pg \
  typeorm \
  bcrypt \
  class-validator \
  class-transformer \
  passport \
  passport-jwt \
  passport-local \
  openai \
  stripe # (Novo - Adicionado para Módulo de Pagamentos)

## Dependências de Desenvolvimento

npm install --save-dev \
  @nestjs/cli \
  @nestjs/schematics \
  @nestjs/testing \
  @types/express \
  @types/node \
  @types/jest \
  @types/supertest \
  @types/bcrypt \
  @types/passport-jwt \
  @types/passport-local \
  ts-loader \
  ts-node \
  tsconfig-paths \
  typescript