"use strict";
Object.defineProperty(exports, "__esModule", { value: true });
exports.AVAILABLE_IA_MODELS = void 0;
exports.AVAILABLE_IA_MODELS = [
    {
        id: 'gemini-flash-free',
        provider: 'GEMINI',
        modelName: 'gemini-2.5-flash',
        iaDepth: 'Moderada',
        costInputPerM: 0.50,
        costOutputPerM: 2.00,
        apiKeyEnvVar: 'GEMINI_API_KEY',
    },
    {
        id: 'claude-haiku-medium',
        provider: 'CLAUDE',
        modelName: 'claude-3-haiku',
        iaDepth: 'Média',
        costInputPerM: 0.25,
        costOutputPerM: 1.25,
        apiKeyEnvVar: 'CLAUDE_API_KEY',
    },
    {
        id: 'gpt-4o-advanced',
        provider: 'GPT',
        modelName: 'gpt-4o-mini',
        iaDepth: 'Avançada',
        costInputPerM: 0.15,
        costOutputPerM: 0.60,
        apiKeyEnvVar: 'GPT_API_KEY',
    },
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
//# sourceMappingURL=ia-models.js.map