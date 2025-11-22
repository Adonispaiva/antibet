import { Request, Response } from 'express';
import { AiInterventionService } from '../services/AiInterventionService';
import { Logger } from '../utils/Logger';

/**
 * ORION ARCHITECTURE: CONTROLADOR DE INTERVENÇÃO
 * Responsável por gerenciar as requisições HTTP vindas do aplicativo móvel
 * e encaminhá-las para o Agente de IA.
 */
export class AiInterventionController {
  private aiService: AiInterventionService;

  constructor() {
    // Instanciação do serviço (Singleton idealmente, mas direto aqui para MVP)
    this.aiService = new AiInterventionService();
  }

  /**
   * Manipula a interação de chat.
   * Rota: POST /api/ai/chat
   * Body: { "userId": "uuid", "message": "Texto do usuário" }
   */
  public handleChat = async (req: Request, res: Response): Promise<void> => {
    const startTime = Date.now();
    
    try {
      const { userId, message } = req.body;

      // 1. Validação de Entrada (Security Guardrail)
      if (!userId || typeof userId !== 'string') {
        Logger.warn('[AiController] Requisição rejeitada: userId ausente ou inválido.');
        res.status(400).json({ 
          error: 'Bad Request', 
          message: 'O campo userId é obrigatório.' 
        });
        return;
      }

      if (!message || typeof message !== 'string' || message.trim().length === 0) {
        Logger.warn(`[AiController] Requisição rejeitada: mensagem vazia de ${userId}.`);
        res.status(400).json({ 
          error: 'Bad Request', 
          message: 'A mensagem não pode ser vazia.' 
        });
        return;
      }

      Logger.info(`[AiController] Recebendo mensagem de ${userId}: "${message.substring(0, 20)}..."`);

      // 2. Processamento pelo Agente Inteligente
      const aiResponse = await this.aiService.processInteraction(userId, message);

      // 3. Cálculo de latência para monitoramento
      const duration = Date.now() - startTime;
      Logger.info(`[AiController] Resposta gerada em ${duration}ms para ${userId}.`);

      // 4. Resposta de Sucesso
      res.status(200).json({
        status: 'success',
        data: {
          response: aiResponse,
          timestamp: new Date().toISOString(),
        }
      });

    } catch (error) {
      // 5. Tratamento de Erro Global
      Logger.error('[AiController] Erro crítico ao processar chat.', error);
      
      res.status(500).json({
        status: 'error',
        message: 'Erro interno no servidor de Inteligência Artificial.',
        code: 'AI_SERVICE_FAILURE'
      });
    }
  };
}