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
 * Define o tipo de foco da estrategia (Ex: Swing, Scalping, Position).
 */
export enum StrategyFocus {
  SWING = 'swing',
  SCALPING = 'scalping',
  POSITION = 'position',
}

/**
 * Entidade que armazena uma estrategia de trade/investimento definida pelo usuario.
 */
@Entity({ name: 'strategies' })
export class Strategy {
  @PrimaryGeneratedColumn('uuid')
  id: string;

  /**
   * O usuario dono desta estrategia.
   */
  @ManyToOne(() => User, { nullable: false })
  user: User;

  @Column()
  userId: string;

  @Column({ length: 100, nullable: false })
  name: string;

  @Column({ type: 'text', nullable: true })
  description: string;

  @Column({
    type: 'enum',
    enum: StrategyFocus,
    default: StrategyFocus.SWING,
  })
  focus: StrategyFocus;

  /**
   * Percentual de risco aceito por operacao (ex: 1 = 1%).
   */
  @Column({ type: 'float', default: 1.0 })
  riskPerTrade: number;

  /**
   * Metas de taxa de acerto (Win Rate)
   */
  @Column({ type: 'float', nullable: true })
  targetWinRate: number;

  @Column({ default: true })
  isActive: boolean;

  // Campos de Controle
  @CreateDateColumn({ type: 'timestamp with time zone', default: () => 'CURRENT_TIMESTAMP' })
  createdAt: Date;

  @UpdateDateColumn({ type: 'timestamp with time zone', default: () => 'CURRENT_TIMESTAMP' })
  updatedAt: Date;
}