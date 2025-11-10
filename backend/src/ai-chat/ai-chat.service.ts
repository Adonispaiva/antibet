import { Injectable, ForbiddenException } from '@nestjs/common';
import { AiLogService } from './ai-log.service'; // NOVO: Importação do Log Service

@Injectable()
export class AiChatService {
  constructor(
    private readonly aiLogService: AiLogService,
    // Futuramente: private readonly aiGatewayService: AiGatewayService
  ) {}

  /**
   * Processa a mensagem do usuário, verifica o limite de uso e loga o débito.
   * @param userId O ID do usuário logado.
   * @param message A mensagem a ser enviada para a IA.
   * @returns A resposta simulada da IA.
   */
  async sendMessage(userId: string, message: string): Promise<any> {
    // 1. Check de Limite de Uso
    const canProceed = await this.aiLogService.canUseChat(userId);
    
    if (!canProceed) {
      // Lança exceção 403 Forbidden se o limite for excedido
      throw new ForbiddenException('Limite de uso excedido. Considere um plano premium.');
    }

    // 2. Simulação de Chamada à IA (AiGatewayService)
    // const gptResponse = await this.aiGatewayService.sendToGPT(message);

    // Stub de resposta para teste de integração
    const gptResponse = {
      text: `Olá ${userId}, sua pergunta sobre "${message}" foi processada. (Débito simulado: 5 tokens)`,
      tokenUsage: 5,
    };

    // 3. Débito de Uso
    const debitSuccess = await this.aiLogService.logAndDebitUsage(userId, gptResponse.tokenUsage);

    if (!debitSuccess) {
      // Logar erro crítico: a resposta veio, mas o débito falhou.
      console.error(`ERRO CRÍTICO: Falha ao debitar uso para o usuário ${userId}`);
    }

    return gptResponse;
  }
}