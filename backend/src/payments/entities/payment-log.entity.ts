// backend/src/payments/entities/payment-log.entity.ts

import { 
  Entity, 
  PrimaryGeneratedColumn, 
  Column, 
  CreateDateColumn, 
  ManyToOne,
  JoinColumn,
} from 'typeorm';
import { User } from '../../user/entities/user.entity'; // Assumindo a entidade do Usuário

/**
 * Entidade que registra o log de todas as transações de pagamento e eventos de webhook.
 * * É a ferramenta de auditoria para rastrear o histórico financeiro e o status de cada cobrança.
 */
@Entity('payment_logs')
export class PaymentLog {
  @PrimaryGeneratedColumn()
  id: number;

  @Column()
  userId: number; // Chave estrangeira para o usuário

  @ManyToOne(() => User) // Relação N:1 com a entidade User
  @JoinColumn({ name: 'userId' })
  user: User;

  @Column({ length: 255, nullable: true })
  gatewayTransactionId: string; // ID da transação no Gateway de Pagamento

  @Column({ length: 50 })
  type: string; // Tipo de evento (Ex: 'charge.succeeded', 'invoice.payment_failed')

  @Column('decimal', { precision: 10, scale: 2 })
  amount: number; // Valor da transação (usar decimal para precisão monetária)

  @Column({ length: 10 })
  currency: string; // Moeda da transação (Ex: 'BRL', 'USD')

  @Column({ default: 'pending', length: 50 })
  status: string; // Status da transação (Ex: 'succeeded', 'failed', 'refunded')

  @Column('jsonb', { nullable: true })
  rawEventPayload: object; // O payload bruto (JSON) do webhook para auditoria completa

  @CreateDateColumn({ type: 'timestamp', default: () => 'CURRENT_TIMESTAMP' })
  createdAt: Date;
}