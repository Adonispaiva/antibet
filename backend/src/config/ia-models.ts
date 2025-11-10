/**
 * Arquivo de Configuração Central para a Arquitetura Multi-IA.
 * Define os modelos disponíveis, suas chaves de ambiente e custos para roteamento.
 */

export interface IaModel {
  id: string; // Nome interno da Inovexa (ex: 'gemini-flash')
  provider: 'GEMINI' | 'CLAUDE' | 'GPT'; // Provedor do serviço
  modelName: string; // Nome do modelo na API (ex: 'gemini-2.5-flash')
  iaDepth: 'Moderada' | 'Média' | 'Avançada' | 'Total'; // Mapeamento com Planos (DESCRIÇÃO PLANOS)
  costInputPerM: number; // Custo de entrada por 1M tokens (USD)
  costOutputPerM: number; // Custo de saída por 1M tokens (USD)
  apiKeyEnvVar: string; // Variável de ambiente para a chave API
}

export const AVAILABLE_IA_MODELS: IaModel[] = [
  // 1. Modelo Base (Plano Free)
  {
    id: 'gemini-flash-free',
    provider: 'GEMINI',
    modelName: 'gemini-2.5-flash',
    iaDepth: 'Moderada',
    costInputPerM: 0.50,
    costOutputPerM: 2.00,
    apiKeyEnvVar: 'GEMINI_API_KEY', // Chave API única para Gemini
  },
  
  // 2. Modelo Balanço (Plano Autocontrole)
  {
    id: 'claude-haiku-medium',
    provider: 'CLAUDE',
    modelName: 'claude-3-haiku',
    iaDepth: 'Média',
    costInputPerM: 0.25,
    costOutputPerM: 1.25,
    apiKeyEnvVar: 'CLAUDE_API_KEY', // Chave API separada para Claude
  },
  
  // 3. Modelo Avançado (Plano Fortaleza)
  {
    id: 'gpt-4o-advanced',
    provider: 'GPT',
    modelName: 'gpt-4o-mini',
    iaDepth: 'Avançada',
    costInputPerM: 0.15,
    costOutputPerM: 0.60,
    apiKeyEnvVar: 'GPT_API_KEY', // Chave API separada para GPT
  },
  
  // 4. Modelo Total (Plano Liberdade) - Usando um modelo mais robusto
  {
    id: 'claude-sonnet-total',
    provider: 'CLAUDE',
    modelName: 'claude-3-sonnet',
    iaDepth: 'Total',
    costInputPerM: 3.00,
    costOutputPerM: 15.00,
    apiKeyEnvVar: 'CLAUDE_API_KEY',
  }
];