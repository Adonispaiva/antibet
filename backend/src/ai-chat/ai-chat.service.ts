import { Injectable, BadRequestException } from '@nestjs/common';
import { InjectRepository } from '@nestjs/typeorm';
import { Repository } from 'typeorm';
import axios from 'axios';

import { AppConfigService } from '../../config/app-config.service';
import { ChatMessage, MessageRole } from './entities/chat-message.entity';
import { CreateChatMessageDto } from './dto/create-chat-message.dto';
import { User } from '../../user/entities/user.entity';

@Injectable()
export class AiChatService {
  private readonly AI_MODEL = 'claude-sonnet-4-20250514'; // Exemplo de modelo
  private readonly API_URL = 'https://api.anthropic.com/v1/messages'; // Exemplo de endpoint

  constructor(
    @InjectRepository(ChatMessage)
    private readonly chatMessageRepository: Repository<ChatMessage>,
    private readonly configService: AppConfigService,
  ) {}

  /**
   * Recupera o historico de mensagens do usuario logado.
   * @param userId O ID do usuario.
   * @returns Lista de mensagens ordenadas.
   */
  async getChatHistory(userId: string): Promise<ChatMessage[]> {
    return this.chatMessageRepository.find({
      where: { userId: userId },
      order: { createdAt: 'ASC' },
      take: 20, // Limita o historico para evitar tokens excessivos
    });
  }

  /**
   * Processa a mensagem do usuario, salva no DB e chama a API de IA.
   * @param user O objeto do usuario logado.
   * @param createChatMessageDto O conteudo da mensagem.
   * @returns A resposta da IA.
   */
  async processUserMessage(user: User, createChatMessageDto: CreateChatMessageDto): Promise<ChatMessage> {
    // 1. Salva a mensagem do usuario no historico
    await this.saveMessage(user, createChatMessageDto.content, MessageRole.USER);

    // 2. Chama a API de IA
    const aiResponse = await this.callAIModel(user.id, createChatMessageDto.content);

    // 3. Salva a resposta da IA no historico
    const assistantMessage = await this.saveMessage(
      user,
      aiResponse.content,
      MessageRole.ASSISTANT,
      aiResponse.cost,
      aiResponse.metadata,
    );

    return assistantMessage;
  }

  /**
   * Metodo privado para salvar uma mensagem no banco de dados.
   */
  private async saveMessage(
    user: User,
    content: string,
    role: MessageRole,
    cost: number = 0,
    metadata: any = null,
  ): Promise<ChatMessage> {
    const newMessage = this.chatMessageRepository.create({
      user: user,
      userId: user.id,
      content: content,
      role: role,
      cost: cost,
      aiMetadata: metadata,
    });
    return this.chatMessageRepository.save(newMessage);
  }

  /**
   * Funcao que realiza a chamada HTTP para o modelo de IA.
   */
  private async callAIModel(userId: string, prompt: string): Promise<any> {
    // 1. Busca o historico para dar contexto a IA
    const history = await this.getChatHistory(userId);
    const messages = history.map(msg => ({
      role: msg.role === MessageRole.USER ? 'user' : 'assistant',
      content: msg.content,
    }));
    
    // 2. Adiciona a mensagem atual
    messages.push({ role: 'user', content: prompt });

    try {
      const response = await axios.post(
        this.API_URL,
        {
          model: this.AI_MODEL,
          messages: messages,
          max_tokens: 1024,
        },
        {
          headers: {
            // A chave da API deve ser injetada de forma segura
            'x-api-key': this.configService.get<string>('ANTHROPIC_API_KEY'), // Assumindo chave no AppConfigService
            'anthropic-version': '2023-06-01',
          },
        },
      );

      // Logica de extracao e custo (simplificada)
      const cost = 0.005; // Custo estimado (deve ser calculado com base nos tokens)
      const content = response.data.content[0].text;
      const metadata = response.data.usage;

      return { content, cost, metadata };

    } catch (error) {
      console.error('Erro na chamada da API de IA:', error.response?.data || error.message);
      throw new BadRequestException('Falha ao obter resposta da IA. Tente novamente mais tarde.');
    }
  }
}