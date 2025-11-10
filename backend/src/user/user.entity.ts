import { Entity, PrimaryGeneratedColumn, Column, CreateDateColumn, UpdateDateColumn } from 'typeorm';

@Entity('users')
export class User {
  @PrimaryGeneratedColumn('uuid')
  id: string;

  @Column({ unique: true })
  email: string;

  @Column()
  firstName: string;

  @Column({ nullable: true })
  lastName: string;

  // CRÍTICO para segurança: A senha deve ser armazenada como hash
  @Column({ select: false }) // Não carregar hash por padrão
  passwordHash: string; 

  // CRÍTICO para monetização: Saldo de tokens de IA
  @Column({ default: 0 })
  aiTokens: number;

  // CRÍTICO para monetização: Status de plano (ou referência de plano)
  @Column({ default: false })
  isPremium: boolean; 

  @CreateDateColumn()
  createdAt: Date;

  @UpdateDateColumn()
  updatedAt: Date;
}