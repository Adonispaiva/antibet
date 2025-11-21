import {
  Entity,
  PrimaryGeneratedColumn,
  Column,
  CreateDateColumn,
  UpdateDateColumn,
} from 'typeorm';
import { UserRole } from '../../user/entities/user.entity';

/**
 * Define os intervalos de cobranca (ex: Mensal, Anual)
 */
export enum PlanInterval {
  MONTHLY = 'month',
  YEARLY = 'year',
}

@Entity({ name: 'plans' })
export class Plan {
  @PrimaryGeneratedColumn('uuid')
  id: string;

  @Column({ unique: true, nullable: false })
  name: string;

  @Column({ type: 'text', nullable: true })
  description: string;

  /**
   * Preco em centavos (integer) para evitar problemas de arredondamento.
   * Ex: R$ 19,90 = 1990
   */
  @Column({ type: 'int', default: 0 })
  price: number;

  @Column({
    type: 'enum',
    enum: PlanInterval,
    default: PlanInterval.MONTHLY,
  })
  interval: PlanInterval;

  /**
   * O UserRole que este plano concede ao usuario.
   * Ex: Um plano "Premium" concede o UserRole.PREMIUM.
   */
  @Column({
    type: 'enum',
    enum: UserRole,
    default: UserRole.BASIC,
  })
  grantedRole: UserRole;

  /**
   * Lista de features (beneficios) do plano.
   */
  @Column({ type: 'simple-array', nullable: true })
  features: string[];

  /**
   * ID do plano no gateway de pagamento (ex: Stripe, PagSeguro).
   * Essencial para o checkout.
   */
  @Column({ unique: true, nullable: true })
  paymentGatewayId: string;

  @Column({ default: true })
  isActive: boolean;

  // Campos de Controle
  @CreateDateColumn({ type: 'timestamp with time zone', default: () => 'CURRENT_TIMESTAMP' })
  createdAt: Date;

  @UpdateDateColumn({ type: 'timestamp with time zone', default: () => 'CURRENT_TIMESTAMP' })
  updatedAt: Date;
}