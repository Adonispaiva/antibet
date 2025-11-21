import {
  Entity,
  PrimaryGeneratedColumn,
  Column,
  CreateDateColumn,
  ManyToOne,
} from 'typeorm';
import { User } from '../../user/entities/user.entity';

/**
 * Define o tipo de notificacao (ex: Alerta de Meta, Pagamento, IA).
 */
export enum NotificationType {
  GOAL_ALERT = 'goal_alert',
  PAYMENT_STATUS = 'payment_status',
  SYSTEM_UPDATE = 'system_update',
  AI_RECOMMENDATION = 'ai_recommendation',
  SUBSCRIPTION_END = 'subscription_end',
}

/**
 * Entidade que armazena notificacoes destinadas a um usuario.
 */
@Entity({ name: 'notifications' })
export class Notification {
  @PrimaryGeneratedColumn('uuid')
  id: string;

  /**
   * O usuario que deve receber a notificação.
   */
  @ManyToOne(() => User, { nullable: false })
  recipient: User;

  @Column()
  recipientId: string;

  @Column({ length: 255, nullable: false })
  title: string;

  @Column({ type: 'text', nullable: false })
  message: string;

  @Column({
    type: 'enum',
    enum: NotificationType,
    default: NotificationType.SYSTEM_UPDATE,
  })
  type: NotificationType;

  /**
   * Metadados opcionais (ex: link para o JournalEntry que disparou o alerta).
   */
  @Column({ type: 'jsonb', nullable: true })
  metadata: any;

  @Column({ default: false })
  isRead: boolean;

  // Campos de Controle
  @CreateDateColumn({ type: 'timestamp with time zone', default: () => 'CURRENT_TIMESTAMP' })
  createdAt: Date;
}