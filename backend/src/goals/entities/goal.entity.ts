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
 * Define o tipo de meta (ex: Financeira, Emocional, Técnica).
 */
export enum GoalType {
  FINANCIAL = 'financial',
  EMOTIONAL = 'emotional',
  TECHNICAL = 'technical',
  OTHER = 'other',
}

/**
 * Entidade que armazena uma meta de trade/investimento definida pelo usuario.
 */
@Entity({ name: 'goals' })
export class Goal {
  @PrimaryGeneratedColumn('uuid')
  id: string;

  /**
   * O usuario dono desta meta.
   */
  @ManyToOne(() => User, { nullable: false })
  user: User;

  @Column()
  userId: string;

  @Column({ length: 255, nullable: false })
  title: string;

  @Column({ type: 'text', nullable: true })
  description: string;

  @Column({
    type: 'enum',
    enum: GoalType,
    default: GoalType.FINANCIAL,
  })
  type: GoalType;

  /**
   * Valor alvo (ex: R$ 5000, 50% de Win Rate).
   */
  @Column({ type: 'float', default: 0 })
  targetValue: number;

  /**
   * Valor atual (para rastreamento de progresso).
   */
  @Column({ type: 'float', default: 0 })
  currentValue: number;

  @Column({ type: 'date', nullable: true })
  targetDate: Date;

  @Column({ default: false })
  isCompleted: boolean;

  @Column({ default: true })
  isActive: boolean;

  // Campos de Controle
  @CreateDateColumn({ type: 'timestamp with time zone', default: () => 'CURRENT_TIMESTAMP' })
  createdAt: Date;

  @UpdateDateColumn({ type: 'timestamp with time zone', default: () => 'CURRENT_TIMESTAMP' })
  updatedAt: Date;
}