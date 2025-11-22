"use strict";
Object.defineProperty(exports, "__esModule", { value: true });
exports.AiInterventionService = void 0;
const dotenv = require("dotenv");
dotenv.config();
const generative_ai_1 = require("@google/generative-ai");
const Logger_1 = require("../utils/Logger");
const UserService_1 = require("./UserService");
const BlockService_1 = require("./BlockService");
const SystemPrompts_1 = require("../utils/SystemPrompts");
class AiInterventionService {
    constructor() {
        this.API_KEY = process.env.GOOGLE_API_KEY || '';
        if (!this.API_KEY) {
            Logger_1.Logger.error('[AiService] CRÍTICO: GOOGLE_API_KEY não encontrada no .env');
            Logger_1.Logger.error(`[AiService] Valor atual lido: "${this.API_KEY}"`);
        }
        else {
            Logger_1.Logger.info('[AiService] ✅ API Key do Google carregada com sucesso.');
        }
        this.genAI = new generative_ai_1.GoogleGenerativeAI(this.API_KEY);
        this.userService = new UserService_1.UserService();
        this.blockService = new BlockService_1.BlockService();
        const tools = [
            {
                functionDeclarations: [
                    {
                        name: 'enable_block_mode',
                        description: 'ATIVAR BLOQUEIO IMEDIATO. Use se o usuário expressar desejo urgente de apostar ou recaída.',
                        parameters: {
                            type: generative_ai_1.FunctionDeclarationSchemaType.OBJECT,
                            properties: {
                                duration_minutes: {
                                    type: generative_ai_1.FunctionDeclarationSchemaType.NUMBER,
                                    description: 'Duração do bloqueio em minutos.',
                                },
                                reason: {
                                    type: generative_ai_1.FunctionDeclarationSchemaType.STRING,
                                    description: 'Motivo clínico da intervenção.',
                                },
                            },
                            required: ['duration_minutes'],
                        },
                    },
                    {
                        name: 'save_trigger',
                        description: 'Registrar um gatilho emocional ou situacional no prontuário do usuário.',
                        parameters: {
                            type: generative_ai_1.FunctionDeclarationSchemaType.OBJECT,
                            properties: {
                                trigger_category: {
                                    type: generative_ai_1.FunctionDeclarationSchemaType.STRING,
                                    description: 'Categoria: ansiedade, tédio, financeiro, social, euforia.',
                                },
                                intensity: {
                                    type: generative_ai_1.FunctionDeclarationSchemaType.NUMBER,
                                    description: 'Intensidade de 1 a 10.',
                                },
                            },
                            required: ['trigger_category', 'intensity'],
                        },
                    },
                ],
            },
        ];
        this.model = this.genAI.getGenerativeModel({
            model: 'gemini-pro',
            tools: tools,
            generationConfig: {
                temperature: 0.2,
                maxOutputTokens: 800,
            },
            safetySettings: [
                { category: generative_ai_1.HarmCategory.HARM_CATEGORY_HARASSMENT, threshold: generative_ai_1.HarmBlockThreshold.BLOCK_MEDIUM_AND_ABOVE },
                { category: generative_ai_1.HarmCategory.HARM_CATEGORY_HATE_SPEECH, threshold: generative_ai_1.HarmBlockThreshold.BLOCK_MEDIUM_AND_ABOVE },
            ]
        });
    }
    async processInteraction(userId, userMessage) {
        try {
            Logger_1.Logger.info(`[Gemini] Processando mensagem de ${userId}: "${userMessage}"`);
            const chat = this.model.startChat({
                history: [
                    {
                        role: 'user',
                        parts: [{ text: SystemPrompts_1.ANTIBET_SYSTEM_PROMPT }],
                    },
                    {
                        role: 'model',
                        parts: [{ text: 'Entendido. Assumindo a persona AntiBet Coach com acesso às ferramentas de intervenção.' }],
                    },
                ],
            });
            const result = await chat.sendMessage(userMessage);
            const response = result.response;
            const functionCalls = response.functionCalls();
            if (functionCalls && functionCalls.length > 0) {
                Logger_1.Logger.warn(`[Gemini Agent] 🤖 IA DECIDIU AGIR! Ferramentas acionadas: ${functionCalls.length}`);
                for (const call of functionCalls) {
                    const name = call.name;
                    const args = call.args;
                    Logger_1.Logger.warn(`[Gemini Action] Executando >>> ${name.toUpperCase()} <<< com args: ${JSON.stringify(args)}`);
                    let functionResponse = {};
                    if (name === 'enable_block_mode') {
                        const duration = args.duration_minutes || 60;
                        await this.blockService.enforceBlock(userId, Number(duration));
                        functionResponse = { status: 'blocked', duration: duration, message: 'Bloqueio ativo.' };
                    }
                    else if (name === 'save_trigger') {
                        await this.userService.logTrigger(userId, args);
                        functionResponse = { status: 'saved', message: 'Gatilho registrado.' };
                    }
                    const result2 = await chat.sendMessage([
                        {
                            functionResponse: {
                                name: name,
                                response: functionResponse,
                            },
                        }
                    ]);
                    return result2.response.text();
                }
            }
            return response.text();
        }
        catch (error) {
            Logger_1.Logger.error('[Gemini] Erro na intervenção:', error);
            return "Estou conectando aos meus sistemas de segurança. Por favor, aguarde um instante e tente novamente.";
        }
    }
}
exports.AiInterventionService = AiInterventionService;
//# sourceMappingURL=AiInterventionService.js.map