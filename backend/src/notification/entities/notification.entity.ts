// backend/src/notification/entities/notification.entity.ts

import { 
  Entity, 
  PrimaryGeneratedColumn, 
  Column, 
  CreateDateColumn, 
  ManyToOne,
  JoinColumn,
} from 'typeorm';
import { User } from '../../user/entities/user.entity'; // Entidade do Usuário

/**
 * Entidade que armazena notificações e alertas do sistema para usuários específicos.
 */
@Entity('notifications')
export class Notification {
  @PrimaryGeneratedColumn()
  id: number;

  @Column()
  userId: number; // Chave estrangeira para o usuário

  @ManyToOne(() => User, user => user.id) // Relação N:1 com a entidade User
  @JoinColumn({ name: 'userId' })
  user: User;

  @Column({ length: 100 })
  title: string; // Título da notificação

  @Column({ length: 500 })
  message: string; // Conteúdo detalhado da notificação

  @Column({ default: false })
  isRead: boolean; // Status de leitura (false = não lida)

  @CreateDateColumn({ type: 'timestamp', default: () => 'CURRENT_TIMESTAMP' })
  createdAt: Date;
}