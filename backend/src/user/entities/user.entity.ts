import {
  Entity,
  PrimaryGeneratedColumn,
  Column,
  CreateDateColumn,
  UpdateDateColumn,
  OneToMany,
  OneToOne,
} from 'typeorm';
import { JournalEntry } from '../../journal/entities/journal-entry.entity';
import { Subscription } from '../../subscription/entities/subscription.entity';

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

  /**
   * O ID de cliente no gateway de pagamento (ex: Stripe Customer ID).
   * Essencial para vincular pagamentos e assinaturas a um cliente no gateway.
   */
  @Column({ unique: true, nullable: true, select: false })
  stripeCustomerId: string;

  // Relações
  @OneToMany(() => JournalEntry, (entry) => entry.user)
  journalEntries: JournalEntry[];

  @OneToOne(() => Subscription, (subscription) => subscription.user)
  subscription: Subscription;

  // Campos de Controle
  @CreateDateColumn({ type: 'timestamp with time zone', default: () => 'CURRENT_TIMESTAMP' })
  createdAt: Date;

  @UpdateDateColumn({ type: 'timestamp with time zone', default: () => 'CURRENT_TIMESTAMP' })
  updatedAt: Date;
}