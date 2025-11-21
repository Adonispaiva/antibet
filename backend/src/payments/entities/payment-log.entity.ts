import {
  Entity,
  PrimaryGeneratedColumn,
  Column,
  CreateDateColumn,
  UpdateDateColumn,
  ManyToOne,
} from 'typeorm';
import { User } from '../../user/entities/user.entity';

/**
 * Status do Pagamento
 */
export enum PaymentStatus {
  PENDING = 'pending',
  COMPLETED = 'completed',
  FAILED = 'failed',
  REFUNDED = 'refunded',
}

/**
 * Gateway de Pagamento (ex: Stripe, PagSeguro)
 */
export enum PaymentGateway {
  STRIPE = 'stripe',
  PAGSEGURO = 'pagseguro',
  MERCADOPAGO = 'mercadopago',
  MANUAL = 'manual',
}

/**
 * Entidade para registrar todas as transacoes financeiras (logs).
 * Isso e crucial para auditoria e gerenciamento de assinaturas.
 */
@Entity({ name: 'payment_logs' })
export class PaymentLog {
  @PrimaryGeneratedColumn('uuid')
  id: string;

  /**
   * O usuario que realizou o pagamento.
   */
  @ManyToOne(() => User, { nullable: false })
  user: User;

  @Column()
  userId: string;

  /**
   * O ID da transacao no gateway de pagamento (ex: Stripe Checkout Session ID).
   */
  @Column({ unique: true })
  transactionId: string;

  @Column({
    type: 'enum',
    enum: PaymentGateway,
    default: PaymentGateway.STRIPE,
  })
  gateway: PaymentGateway;

  @Column({
    type: 'enum',
    enum: PaymentStatus,
    default: PaymentStatus.PENDING,
  })
  status: PaymentStatus;

  /**
   * Valor pago (em centavos).
   */
  @Column({ type: 'int' })
  amount: number;

  @Column({ default: 'BRL' })
  currency: string;

  /**
   * O ID do plano que foi comprado (referencia interna).
   */
  @Column({ nullable: true })
  planId: string;

  /**
   * Armazena o evento bruto (raw payload) vindo do webhook do gateway.
   * Essencial para debug e auditoria.
   */
  @Column({ type: 'jsonb', nullable: true })
  gatewayPayload: any;

  // Campos de Controle
  @CreateDateColumn({ type: 'timestamp with time zone', default: () => 'CURRENT_TIMESTAMP' })
  createdAt: Date;

  @UpdateDateColumn({ type: 'timestamp with time zone', default: () => 'CURRENT_TIMESTAMP' })
  updatedAt: Date;
}