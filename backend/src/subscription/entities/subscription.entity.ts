import {
  Entity,
  PrimaryGeneratedColumn,
  Column,
  CreateDateColumn,
  UpdateDateColumn,
  OneToOne,
  JoinColumn,
} from 'typeorm';
import { User, UserRole } from '../../user/entities/user.entity';

/**
 * Status da Assinatura
 */
export enum SubscriptionStatus {
  ACTIVE = 'active', // Pagamento em dia, acesso liberado
  CANCELED = 'canceled', // Cancelada pelo usuario, mas ativa ate o fim do ciclo
  INACTIVE = 'inactive', // Ciclo encerrado apos o cancelamento
  PAST_DUE = 'past_due', // Pagamento falhou, aguardando
  TRIALING = 'trialing', // Periodo de teste
}

/**
 * Entidade que armazena o *estado* da assinatura de um usuario.
 * Essencial para controlar o nivel de acesso (Role) do usuario.
 */
@Entity({ name: 'subscriptions' })
export class Subscription {
  @PrimaryGeneratedColumn('uuid')
  id: string;

  /**
   * O usuario dono desta assinatura.
   * (Relacao 1-para-1: Um usuario tem uma assinatura)
   */
  @OneToOne(() => User, { nullable: false })
  @JoinColumn()
  user: User;

  @Column({ unique: true })
  userId: string;

  /**
   * O ID da assinatura no gateway de pagamento (ex: Stripe Subscription ID).
   * Essencial para webhooks de renovacao ou cancelamento.
   */
  @Column({ unique: true, nullable: true })
  paymentGatewaySubscriptionId: string;

  @Column({
    type: 'enum',
    enum: SubscriptionStatus,
    default: SubscriptionStatus.INACTIVE,
  })
  status: SubscriptionStatus;

  /**
   * O nivel de acesso (Role) que esta assinatura concede.
   */
  @Column({
    type: 'enum',
    enum: UserRole,
    default: UserRole.BASIC,
  })
  currentRole: UserRole;

  /**
   * O ID do plano (interno) que o usuario assinou.
   */
  @Column()
  planId: string;

  /**
   * Data em que o ciclo de cobranca atual expira (e o acesso deve ser revogado).
   */
  @Column({ type: 'timestamp with time zone', nullable: true })
  currentPeriodEnd: Date;

  /**
   * Data em que a assinatura foi cancelada.
   */
  @Column({ type: 'timestamp with time zone', nullable: true })
  canceledAt: Date;

  // Campos de Controle
  @CreateDateColumn({ type: 'timestamp with time zone', default: () => 'CURRENT_TIMESTAMP' })
  createdAt: Date;

  @UpdateDateColumn({ type: 'timestamp with time zone', default: () => 'CURRENT_TIMESTAMP' })
  updatedAt: Date;
}