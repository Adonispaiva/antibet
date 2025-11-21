import {
  Entity,
  PrimaryGeneratedColumn,
  Column,
  CreateDateColumn,
  ManyToOne,
} from 'typeorm';
import { User } from '../../user/entities/user.entity';

/**
 * Define a origem da mensagem (Usuario ou IA).
 */
export enum MessageRole {
  USER = 'user',
  ASSISTANT = 'assistant',
  SYSTEM = 'system', // Usado para instruções iniciais da IA
}

/**
 * Entidade que armazena uma mensagem individual dentro de uma conversa.
 */
@Entity({ name: 'chat_messages' })
export class ChatMessage {
  @PrimaryGeneratedColumn('uuid')
  id: string;

  /**
   * O usuario dono desta mensagem.
   */
  @ManyToOne(() => User, { nullable: false })
  user: User;

  @Column()
  userId: string;

  @Column({
    type: 'enum',
    enum: MessageRole,
    default: MessageRole.USER,
  })
  role: MessageRole;

  @Column({ type: 'text', nullable: false })
  content: string;

  /**
   * O custo em centavos (ou outro valor) associado a esta mensagem/resposta da IA.
   */
  @Column({ type: 'float', default: 0 })
  cost: number;

  /**
   * Metadados brutos da resposta da API de IA (ex: contagem de tokens).
   */
  @Column({ type: 'jsonb', nullable: true })
  aiMetadata: any;

  // Campos de Controle
  @CreateDateColumn({ type: 'timestamp with time zone', default: () => 'CURRENT_TIMESTAMP' })
  createdAt: Date;
}