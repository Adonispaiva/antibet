// backend/src/ai-chat/ai-chat.service.ts

import { Injectable, ForbiddenException, InternalServerErrorException } from '@nestjs/common';
import { InjectRepository } from '@nestjs/typeorm';
import { Repository } from 'typeorm';
import { AiChatConversation } from './entities/ai-chat-conversation.entity';
import { AiChatMessage } from './entities/ai-chat-message.entity';
import { CreateChatMessageDto } from './dto/create-chat-message.dto';
import { AiChatResponseDto } from './dto/ai-chat-response.dto';
import { PaymentsService } from '../payments/payments.service'; // Assumindo a injeção
import { UserService } from '../user/user.service'; // Assumindo a injeção

// Constantes de Limite (Em produção, viriam do ConfigService/BD)
const MAX_FREE_INTERACTIONS = 50;

@Injectable()
export class AiChatService {
  constructor(
    @InjectRepository(AiChatConversation)
    private readonly conversationRepository: Repository<AiChatConversation>,
    @InjectRepository(AiChatMessage)
    private readonly messageRepository: Repository<AiChatMessage>,
    // Injetando serviços intermodulares
    private readonly paymentsService: PaymentsService,
    private readonly userService: UserService,
  ) {}

  /**
   * Verifica se o usuário excedeu o limite de interações de IA do seu plano.
   * @param userId O ID do usuário logado.
   * @returns O número de interações restantes e o status de limite.
   */
  private async checkUserLimits(userId: number): Promise<{ remaining: number; limitExceeded: boolean }> {
    // 1. Verificar status Premium (simplificado)
    const subscriptionStatus = await this.paymentsService.getSubscriptionStatus(userId);

    if (subscriptionStatus.isPremiumActive) {
        // Usuários Premium têm interações ilimitadas
        return { remaining: -1, limitExceeded: false };
    }

    // 2. Contar interações do Free Tier (último mês)
    const oneMonthAgo = new Date();
    oneMonthAgo.setMonth(oneMonthAgo.getMonth() - 1);

    const interactionsCount = await this.messageRepository
        .createQueryBuilder('message')
        .innerJoin('message.conversation', 'conversation')
        .where('conversation.userId = :userId', { userId })
        .andWhere('message.sender = :sender', { sender: 'user' }) // Contar apenas as requisições do usuário
        .andWhere('message.createdAt >= :oneMonthAgo', { oneMonthAgo })
        .getCount();

    const remaining = Math.max(0, MAX_FREE_INTERACTIONS - interactionsCount);
    const limitExceeded = interactionsCount >= MAX_FREE_INTERACTIONS;

    return { remaining, limitExceeded };
  }

  /**
   * Processa a mensagem do usuário, salva, interage com a IA e retorna a resposta.
   * @param createMessageDto A mensagem e o ID da conversa.
   * @param userId O ID do usuário logado.
   * @returns O DTO de resposta do chat de IA.
   */
  async sendMessage(
    createMessageDto: CreateChatMessageDto,
    userId: number,
  ): Promise<AiChatResponseDto> {
    const { remaining, limitExceeded } = await this.checkUserLimits(userId);

    if (limitExceeded) {
      // Retorna a resposta de erro/limite no formato DTO para o Front-end gerenciar o Gating
      return {
          message: 'Você atingiu o limite de interações de IA do seu plano Básico. Assine o Premium para acesso ilimitado.',
          conversationId: createMessageDto.conversationId || 0,
          limitExceeded: true,
          remainingInteractions: remaining,
      } as AiChatResponseDto;
    }

    // 1. Gerenciar/Criar a Conversa
    let conversation: AiChatConversation;
    if (createMessageDto.conversationId) {
      conversation = await this.conversationRepository.findOne({
        where: { id: createMessageDto.conversationId, userId },
      });
      if (!conversation) {
        throw new NotFoundException('Conversa não encontrada.');
      }
    } else {
      conversation = await this.conversationRepository.save(this.conversationRepository.create({ userId }));
    }

    // 2. Salvar Mensagem do Usuário
    await this.messageRepository.save(
      this.messageRepository.create({
        conversationId: conversation.id,
        content: createMessageDto.message,
        sender: 'user',
      }),
    );
    
    // 3. Simular Interação com a API de LLM
    await new Promise(resolve => setTimeout(resolve, 1500)); // Simula latência de IA

    // 4. Gerar Resposta da IA (Simulação de LLM)
    const aiResponseContent = `(Resposta da IA para: ${createMessageDto.message}). Analisando...`;
    
    // 5. Salvar Mensagem da IA
    const aiMessage = await this.messageRepository.save(
      this.messageRepository.create({
        conversationId: conversation.id,
        content: aiResponseContent,
        sender: 'ai',
      }),
    );
    
    // 6. Atualizar título da conversa se for a primeira mensagem
    if (!conversation.title) {
        conversation.title = createMessageDto.message.substring(0, 50) + '...';
        await this.conversationRepository.save(conversation);
    }

    // 7. Retornar DTO de Sucesso
    return {
      message: aiResponseContent,
      conversationId: conversation.id,
      limitExceeded: false,
      remainingInteractions: remaining - 1,
    } as AiChatResponseDto;
  }
}