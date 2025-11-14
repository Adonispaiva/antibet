import {
  Entity,
  PrimaryGeneratedColumn,
  Column,
  CreateDateColumn,
  UpdateDateColumn,
  OneToMany,
} from 'typeorm';
import { JournalEntry } from '../../journal/entities/journal-entry.entity'; // Assumindo o caminho correto

// Enum para definir os níveis de acesso (Roles)
export enum UserRole {
  ADMIN = 'admin',
  PREMIUM = 'premium',
  BASIC = 'basic',
}

@Entity({ name: 'users' })
export class User {
  @PrimaryGeneratedColumn('uuid')
  id: string;

  @Column({ unique: true, nullable: false })
  email: string;

  // A senha é armazenada com hash (o hash será aplicado no Service)
  @Column({ nullable: false, select: false }) // 'select: false' impede que a senha seja retornada em consultas padrão
  password: string;

  @Column({ default: 'user', nullable: true })
  firstName: string;

  @Column({ default: 'Inovexa', nullable: true })
  lastName: string;

  @Column({
    type: 'enum',
    enum: UserRole,
    default: UserRole.BASIC,
  })
  role: UserRole;

  @Column({ default: true })
  isActive: boolean;

  // Relações
  // Um usuário pode ter múltiplas entradas de diário (JournalEntry)
  @OneToMany(() => JournalEntry, (entry) => entry.user)
  journalEntries: JournalEntry[];

  // Campos de Controle
  @CreateDateColumn({ type: 'timestamp with time zone', default: () => 'CURRENT_TIMESTAMP' })
  createdAt: Date;

  @UpdateDateColumn({ type: 'timestamp with time zone', default: () => 'CURRENT_TIMESTAMP' })
  updatedAt: Date;
}