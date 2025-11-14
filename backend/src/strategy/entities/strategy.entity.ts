// backend/src/strategy/entities/strategy.entity.ts

import { 
  Entity, 
  PrimaryGeneratedColumn, 
  Column, 
  CreateDateColumn, 
  UpdateDateColumn,
  ManyToOne,
  JoinColumn,
  Index,
} from 'typeorm';
import { User } from '../../user/entities/user.entity'; // Assumindo a entidade do Usuário

/**
 * Entidade que registra as estratégias de análise criadas e utilizadas pelo usuário.
 * * Usada para categorizar e filtrar as entradas do diário.
 */
@Entity('strategies')
@Index(['name', 'userId'], { unique: true }) // Garante que o usuário não tenha duas estratégias com o mesmo nome
export class Strategy {
  @PrimaryGeneratedColumn()
  id: number;

  @Column()
  userId: number; // Chave estrangeira para o usuário

  @ManyToOne(() => User, user => user.id) // Relação N:1 com a entidade User
  @JoinColumn({ name: 'userId' })
  user: User;

  @Column({ length: 100 })
  name: string; // Nome único da estratégia

  @Column({ length: 1000, nullable: true })
  description: string; // Detalhes da regra da estratégia

  @CreateDateColumn({ type: 'timestamp', default: () => 'CURRENT_TIMESTAMP' })
  createdAt: Date;

  @UpdateDateColumn({ type: 'timestamp', default: () => 'CURRENT_TIMESTAMP' })
  updatedAt: Date;
}