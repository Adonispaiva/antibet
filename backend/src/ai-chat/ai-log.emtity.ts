import { Entity, Column, PrimaryGeneratedColumn, CreateDateColumn, ManyToOne, JoinColumn } from 'typeorm';
import { User } from '../user/user.entity';

@Entity('ai_interaction_log')
export class AiInteractionLog {
  @PrimaryGeneratedColumn('uuid')
  id: string;

  // Chave estrangeira para o usuário que fez a requisição
  @Column()
  userId: string;
  
  @ManyToOne(() => User, user => user.id, { onDelete: 'CASCADE' })
  @JoinColumn({ name: 'userId' })
  user: User;

  // Informações da Interação
  @Column({ type: 'text' })
  prompt: string; // A mensagem do usuário (ou prompt completo)

  @Column({ type: 'text', nullable: true })
  response: string; // A resposta da IA

  // Dados de Custos/Monetização
  @Column({ length: 50 })
  modelId: string; // Ex: 'gemini-flash-free', 'claude-haiku-medium'

  @Column({ type: 'int', default: 0 })
  inputTokens: number;

  @Column({ type: 'int', default: 0 })
  outputTokens: number;

  @Column({ type: 'decimal', precision: 10, scale: 6, default: 0.0 })
  costUsd: number; // Custo real da interação (para cálculo de margem)

  @CreateDateColumn({ type: 'timestamp' })
  timestamp: Date;
}