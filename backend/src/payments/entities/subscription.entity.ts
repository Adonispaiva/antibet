// backend/src/payments/entities/subscription.entity.ts

import { 
  Entity, 
  PrimaryGeneratedColumn, 
  Column, 
  CreateDateColumn, 
  UpdateDateColumn,
  OneToOne, 
  JoinColumn,
} from 'typeorm';
import { User } from '../../user/entities/user.entity'; // Assumindo a entidade do Usuário

/**
 * Entidade que representa a assinatura ativa de um usuário (ou o registro do plano básico).
 * * Esta entidade é a fonte de verdade para o status de acesso Premium.
 * * É vinculada 1:1 ao Usuário (um usuário pode ter apenas uma assinatura ativa/básica).
 */
@Entity('subscriptions')
export class Subscription {
  @PrimaryGeneratedColumn()
  id: number;

  @Column()
  userId: number; // Chave estrangeira para o usuário

  @OneToOne(() => User, user => user.id) // Relação 1:1 com a entidade User
  @JoinColumn({ name: 'userId' }) // Define a coluna de junção
  user: User;

  @Column()
  planId: number; // ID do plano de assinatura (0 para Básico/Free, 1+ para Pagos)

  @Column({ default: 'active' })
  status: string; // Ex: 'active', 'canceled', 'expired', 'trialing'

  @Column({ default: true })
  isActive: boolean; // Flag de estado para verificações rápidas (usado pelo PremiumGuard)

  @Column({ length: 255, nullable: true })
  gatewaySubscriptionId: string; // ID da assinatura no gateway (Stripe, MP, etc.)

  @CreateDateColumn({ type: 'timestamp' })
  startDate: Date;

  @Column({ type: 'timestamp', nullable: true })
  endDate: Date; // Data de término, se for plano fixo ou cancelado

  @Column({ type: 'timestamp', nullable: true })
  nextBillingDate: Date; // Próxima data de cobrança (crucial para renovações)

  @CreateDateColumn({ type: 'timestamp', default: () => 'CURRENT_TIMESTAMP' })
  createdAt: Date;

  @UpdateDateColumn({ type: 'timestamp', default: () => 'CURRENT_TIMESTAMP' })
  updatedAt: Date;
}