#!/bin/bash
# Script: db-seed.sh
# Uso: Popula o banco de dados com os dados iniciais dos Planos de Assinatura.
#
# É crucial que este script seja executado antes de iniciar a aplicação pela primeira vez.
# Requer Node.js, npm, e as dependências (typeorm, pg) instaladas.

echo "--- Iniciando Seeding do Banco de Dados AntiBet (Planos) ---"

# Exporta o ambiente de desenvolvimento (que contém as credenciais do DB)
export NODE_ENV=development

# Executa o script TypeScript de seed usando ts-node
# O parâmetro -P ./tsconfig-seed.json garante que a configuração correta seja usada
ts-node -P ./tsconfig-seed.json src/db-seed.ts

# Verifica o status da execução
if [ $? -eq 0 ]; then
  echo "--- Seeding de Planos concluído com sucesso. ---"
else
  echo "--- ERRO: Falha durante a execução do Seeding. Verifique o log do TypeORM. ---"
fi