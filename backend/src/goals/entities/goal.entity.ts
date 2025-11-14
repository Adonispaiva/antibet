// backend/src/goals/entities/goal.entity.ts

import { 
  Entity, 
  PrimaryGeneratedColumn, 
  Column, 
  CreateDateColumn, 
  UpdateDateColumn,
  ManyToOne,
  JoinColumn,
} from 'typeorm';
import { User } from '../../user/entities/user.entity'; // Entidade do Usuário

/**
 * Entidade que registra os objetivos financeiros (metas) definidos pelo usuário.
 */
@Entity('goals')
export class Goal {
  @PrimaryGeneratedColumn()
  id: number;

  @Column()
  userId: number; // Chave estrangeira para o usuário

  @ManyToOne(() => User, user => user.id) // Relação N:1 com a entidade User
  @JoinColumn({ name: 'userId' })
  user: User;

  @Column({ length: 100 })
  title: string;

  @Column({ length: 500, nullable: true })
  description: string;

  @Column('decimal', { precision: 10, scale: 2 })
  targetAmount: number; // Valor alvo da meta (Ex: 5000.00)

  @Column('decimal', { precision: 10, scale: 2, default: 0.0 })
  currentAmount: number; // Progresso atual (pode ser atualizado pelo serviço)

  @Column({ type: 'date' })
  targetDate: Date; // Data limite para alcançar a meta

  @Column({ default: false })
  isCompleted: boolean; // Status de conclusão

  @Column({ type: 'timestamp', nullable: true })
  completionDate: Date; // Data em que a meta foi atingida/concluída

  @CreateDateColumn({ type: 'timestamp', default: () => 'CURRENT_TIMESTAMP' })
  createdAt: Date;

  @UpdateDateColumn({ type: 'timestamp', default: () => 'CURRENT_TIMESTAMP' })
  updatedAt: Date;
}