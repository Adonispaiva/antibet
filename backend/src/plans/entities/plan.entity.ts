import { Entity, PrimaryGeneratedColumn, Column, CreateDateColumn, UpdateDateColumn } from 'typeorm';

@Entity('plans')
export class Plan {
  @PrimaryGeneratedColumn('uuid')
  id: string;

  @Column({ unique: true })
  name: string; // CRÍTICO: Nome do plano (propriedade que o TS está reclamando)

  @Column({ type: 'text', nullable: true })
  description: string;

  @Column({ type: 'decimal', precision: 10, scale: 2 })
  price: number; // Preço em BRL/USD (ex: 29.90)

  @Column({ type: 'int' })
  aiTokens: number; // Tokens de IA que o plano oferece

  @Column({ unique: true, nullable: false })
  stripePriceId: string; // ID do Preço no Stripe (crucial para o Checkout)

  @Column({ default: false })
  isSubscription: boolean; // Se é recorrente

  @CreateDateColumn()
  createdAt: Date;

  @UpdateDateColumn()
  updatedAt: Date;
}