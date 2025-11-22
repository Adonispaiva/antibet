"use strict";
Object.defineProperty(exports, "__esModule", { value: true });
exports.AiInterventionController = void 0;
const AiInterventionService_1 = require("../services/AiInterventionService");
const Logger_1 = require("../utils/Logger");
class AiInterventionController {
    constructor() {
        this.handleChat = async (req, res) => {
            const startTime = Date.now();
            try {
                const { userId, message } = req.body;
                if (!userId || typeof userId !== 'string') {
                    Logger_1.Logger.warn('[AiController] Requisição rejeitada: userId ausente ou inválido.');
                    res.status(400).json({
                        error: 'Bad Request',
                        message: 'O campo userId é obrigatório.'
                    });
                    return;
                }
                if (!message || typeof message !== 'string' || message.trim().length === 0) {
                    Logger_1.Logger.warn(`[AiController] Requisição rejeitada: mensagem vazia de ${userId}.`);
                    res.status(400).json({
                        error: 'Bad Request',
                        message: 'A mensagem não pode ser vazia.'
                    });
                    return;
                }
                Logger_1.Logger.info(`[AiController] Recebendo mensagem de ${userId}: "${message.substring(0, 20)}..."`);
                const aiResponse = await this.aiService.processInteraction(userId, message);
                const duration = Date.now() - startTime;
                Logger_1.Logger.info(`[AiController] Resposta gerada em ${duration}ms para ${userId}.`);
                res.status(200).json({
                    status: 'success',
                    data: {
                        response: aiResponse,
                        timestamp: new Date().toISOString(),
                    }
                });
            }
            catch (error) {
                Logger_1.Logger.error('[AiController] Erro crítico ao processar chat.', error);
                res.status(500).json({
                    status: 'error',
                    message: 'Erro interno no servidor de Inteligência Artificial.',
                    code: 'AI_SERVICE_FAILURE'
                });
            }
        };
        this.aiService = new AiInterventionService_1.AiInterventionService();
    }
}
exports.AiInterventionController = AiInterventionController;
//# sourceMappingURL=AiInterventionController.js.map