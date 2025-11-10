export interface IaModel {
    id: string;
    provider: 'GEMINI' | 'CLAUDE' | 'GPT';
    modelName: string;
    iaDepth: 'Moderada' | 'Média' | 'Avançada' | 'Total';
    costInputPerM: number;
    costOutputPerM: number;
    apiKeyEnvVar: string;
}
export declare const AVAILABLE_IA_MODELS: IaModel[];
