import {
  Entity,
  PrimaryGeneratedColumn,
  Column,
  CreateDateColumn,
  ManyToOne,
  UpdateDateColumn,
} from 'typeorm';
import { User } from '../../user/user.entity';

@Entity('goals')
export class Goal {
  @PrimaryGeneratedColumn('uuid')
  id: string;

  /**
   * O título ou a definição da meta. (Ex: "Ficar 24h sem apostar")
   */
  @Column()
  title: string;

  /**
   * Detalhes adicionais sobre a meta.
   */
  @Column('text', { nullable: true })
  description: string;

  /**
   * Status da meta (concluída ou pendente).
   */
  @Column({ default: false })
  isCompleted: boolean;

  /**
   * Data opcional para a conclusão da meta.
   */
  @Column({ type: 'timestamp', nullable: true })
  dueDate: Date;

  @CreateDateColumn()
  createdAt: Date;

  @UpdateDateColumn()
  updatedAt: Date;

  /**
   * Relação: Muitas metas pertencem a Um Usuário.
   */
  @ManyToOne(() => User, (user) => user.goals, { onDelete: 'CASCADE' })
  user: User;

  /**
   * Armazena o ID do usuário para facilitar consultas.
   */
  @Column()
  userId: string;
}