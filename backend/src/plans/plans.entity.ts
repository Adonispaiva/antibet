import { Entity, Column, PrimaryGeneratedColumn, CreateDateColumn, UpdateDateColumn } from 'typeorm';

@Entity('plan')
export class Plan {
  @PrimaryGeneratedColumn('uuid')
  id: string;

  @Column({ unique: true, length: 100 })
  name: string; // Ex: Free, Autocontrole, Fortaleza, Liberdade

  @Column({ type: 'decimal', precision: 10, scale: 2, default: 0.00 })
  monthlyPrice: number; // Valor mensal (R$)

  @Column({ default: 10 })
  limitationsPerDay: number; // Limite de interações com IA por dia

  @Column({ type: 'text' })
  features: string; // Descrição dos recursos adicionais (ex: 'Voz do avatar (TTS), dark mode opcional')

  @Column({ default: 'Moderada' })
  iaDepth: string; // Profundidade da IA (Moderada, Média, Avançada, Total)

  @Column({ default: true })
  isActive: boolean; // Indica se o plano está disponível para compra

  @CreateDateColumn({ type: 'timestamp' })
  createdAt: Date;

  @UpdateDateColumn({ type: 'timestamp' })
  updatedAt: Date;
}