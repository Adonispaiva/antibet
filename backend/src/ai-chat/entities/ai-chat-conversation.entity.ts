// backend/src/ai-chat/entities/ai-chat-conversation.entity.ts

import { 
  Entity, 
  PrimaryGeneratedColumn, 
  Column, 
  CreateDateColumn, 
  UpdateDateColumn,
  ManyToOne,
  OneToMany,
  JoinColumn,
} from 'typeorm';
import { User } from '../../user/entities/user.entity'; // Entidade do Usuário
import { AiChatMessage } from './ai-chat-message.entity'; // Próxima Entidade a ser criada

/**
 * Entidade que representa uma sessão de conversa com a Inteligência Artificial.
 * * Usada para agrupar mensagens e manter o histórico e contexto.
 */
@Entity('ai_chat_conversations')
export class AiChatConversation {
  @PrimaryGeneratedColumn()
  id: number;

  @Column()
  userId: number; // Chave estrangeira para o usuário

  @ManyToOne(() => User, user => user.id) // Relação N:1 com a entidade User
  @JoinColumn({ name: 'userId' })
  user: User;
  
  // Relação 1:N com as mensagens (uma conversa tem muitas mensagens)
  @OneToMany(() => AiChatMessage, message => message.conversation)
  messages: AiChatMessage[]; 

  @Column({ default: false })
  isArchived: boolean; // Para o usuário poder arquivar conversas antigas

  @Column({ length: 255, nullable: true })
  title: string; // Título gerado automaticamente para a conversa (opcional)

  @CreateDateColumn({ type: 'timestamp', default: () => 'CURRENT_TIMESTAMP' })
  createdAt: Date;

  @UpdateDateColumn({ type: 'timestamp', default: () => 'CURRENT_TIMESTAMP' })
  updatedAt: Date;
}