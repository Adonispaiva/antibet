import * as dotenv from 'dotenv';
// FORÇA O CARREGAMENTO IMEDIATO DO .ENV
dotenv.config(); 

import { GoogleGenerativeAI, FunctionDeclarationSchemaType, HarmCategory, HarmBlockThreshold } from '@google/generative-ai';
import { Logger } from '../utils/Logger';
import { UserService } from './UserService';
import { BlockService } from './BlockService';
import { ANTIBET_SYSTEM_PROMPT } from '../utils/SystemPrompts';

/**
 * ORION ARCHITECTURE: CORE DE INTERVENÇÃO (GEMINI PRO 1.5)
 * * Cérebro do sistema AntiBet.
 */
export class AiInterventionService {
  private genAI: GoogleGenerativeAI;
  private model: any;
  private userService: UserService;
  private blockService: BlockService;

  private readonly API_KEY = process.env.GOOGLE_API_KEY || '';

  constructor() {
    // Log de Debug para vermos o que está acontecendo
    if (!this.API_KEY) {
      Logger.error('[AiService] CRÍTICO: GOOGLE_API_KEY não encontrada no .env');
      Logger.error(`[AiService] Valor atual lido: "${this.API_KEY}"`);
    } else {
      Logger.info('[AiService] ✅ API Key do Google carregada com sucesso.');
    }

    this.genAI = new GoogleGenerativeAI(this.API_KEY);
    this.userService = new UserService();
    this.blockService = new BlockService();
    
    // === FERRAMENTAS (TOOLS) ===
    const tools = [
      {
        functionDeclarations: [
          {
            name: 'enable_block_mode',
            description: 'ATIVAR BLOQUEIO IMEDIATO. Use se o usuário expressar desejo urgente de apostar ou recaída.',
            parameters: {
              type: FunctionDeclarationSchemaType.OBJECT,
              properties: {
                duration_minutes: {
                  type: FunctionDeclarationSchemaType.NUMBER,
                  description: 'Duração do bloqueio em minutos.',
                },
                reason: {
                  type: FunctionDeclarationSchemaType.STRING,
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
              type: FunctionDeclarationSchemaType.OBJECT,
              properties: {
                trigger_category: {
                  type: FunctionDeclarationSchemaType.STRING,
                  description: 'Categoria: ansiedade, tédio, financeiro, social, euforia.',
                },
                intensity: {
                  type: FunctionDeclarationSchemaType.NUMBER,
                  description: 'Intensidade de 1 a 10.',
                },
              },
              required: ['trigger_category', 'intensity'],
            },
          },
        ],
      },
    ];

    // === CONFIGURAÇÃO DO MODELO ===
    this.model = this.genAI.getGenerativeModel({ 
      model: 'gemini-pro',
      tools: tools,
      generationConfig: {
        temperature: 0.2, 
        maxOutputTokens: 800,
      },
      safetySettings: [
        { category: HarmCategory.HARM_CATEGORY_HARASSMENT, threshold: HarmBlockThreshold.BLOCK_MEDIUM_AND_ABOVE },
        { category: HarmCategory.HARM_CATEGORY_HATE_SPEECH, threshold: HarmBlockThreshold.BLOCK_MEDIUM_AND_ABOVE },
      ]
    });
  }

  public async processInteraction(userId: string, userMessage: string): Promise<string> {
    try {
      Logger.info(`[Gemini] Processando mensagem de ${userId}: "${userMessage}"`);

      const chat = this.model.startChat({
        history: [
          {
            role: 'user',
            parts: [{ text: ANTIBET_SYSTEM_PROMPT }],
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
        Logger.warn(`[Gemini Agent] 🤖 IA DECIDIU AGIR! Ferramentas acionadas: ${functionCalls.length}`);
        
        for (const call of functionCalls) {
          const name = call.name;
          const args = call.args;
          
          Logger.warn(`[Gemini Action] Executando >>> ${name.toUpperCase()} <<< com args: ${JSON.stringify(args)}`);

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

    } catch (error) {
      Logger.error('[Gemini] Erro na intervenção:', error);
      return "Estou conectando aos meus sistemas de segurança. Por favor, aguarde um instante e tente novamente.";
    }
  }
}