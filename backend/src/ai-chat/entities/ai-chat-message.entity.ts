// backend/src/ai-chat/entities/ai-chat-message.entity.ts

import { 
  Entity, 
  PrimaryGeneratedColumn, 
  Column, 
  CreateDateColumn, 
  ManyToOne,
  JoinColumn,
  Index,
} from 'typeorm';
import { AiChatConversation } from './ai-chat-conversation.entity'; // Entidade de Conversa

/**
 * Entidade que armazena uma mensagem individual dentro de uma conversa de IA.
 */
@Entity('ai_chat_messages')
@Index(['conversationId', 'createdAt']) // Otimiza buscas por histórico de conversa
export class AiChatMessage {
  @PrimaryGeneratedColumn()
  id: number;

  @Column()
  conversationId: number; // Chave estrangeira para a conversa

  @ManyToOne(() => AiChatConversation, conversation => conversation.messages, { onDelete: 'CASCADE' }) // Relacionamento com exclusão em cascata
  @JoinColumn({ name: 'conversationId' })
  conversation: AiChatConversation;

  @Column('text')
  content: string; // Conteúdo da mensagem (texto)

  @Column({ length: 10 })
  sender: 'user' | 'ai'; // Remetente da mensagem

  @CreateDateColumn({ type: 'timestamp', default: () => 'CURRENT_TIMESTAMP' })
  createdAt: Date;
  
  // Nenhuma coluna 'updatedAt', pois mensagens de chat não são tipicamente atualizadas.
}