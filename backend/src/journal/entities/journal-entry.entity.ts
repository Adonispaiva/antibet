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
 * Define o sentimento associado a uma entrada do diario.
 */
export enum JournalSentiment {
  POSITIVE = 'positive',
  NEUTRAL = 'neutral',
  NEGATIVE = 'negative',
}

/**
 * Entidade que armazena uma entrada individual no diario (Journal).
 */
@Entity({ name: 'journal_entries' })
export class JournalEntry {
  @PrimaryGeneratedColumn('uuid')
  id: string;

  /**
   * O usuario que criou esta entrada.
   */
  @ManyToOne(() => User, (user) => user.journalEntries, { nullable: false })
  user: User;

  @Column()
  userId: string;

  @Column({ type: 'text' })
  content: string;

  /**
   * O sentimento analisado (pela IA ou pelo usuario)
   */
  @Column({
    type: 'enum',
    enum: JournalSentiment,
    default: JournalSentiment.NEUTRAL,
  })
  sentiment: JournalSentiment;

  /**
   * Valor de P&L (Profit & Loss) associado a esta entrada.
   * (Armazenado em centavos)
   */
  @Column({ type: 'int', default: 0 })
  pnlValue: number;

  /**
   * Tags ou categorias (ex: "Overtrading", "FOMO", "Disciplina")
   */
  @Column({ type: 'simple-array', nullable: true })
  tags: string[];

  /**
   * Data da operacao (pode ser diferente do createdAt)
   */
  @Column({ type: 'timestamp with time zone', default: () => 'CURRENT_TIMESTAMP' })
  tradeDate: Date;

  // Campos de Controle
  @CreateDateColumn({ type: 'timestamp with time zone', default: () => 'CURRENT_TIMESTAMP' })
  createdAt: Date;

  @UpdateDateColumn({ type: 'timestamp with time zone', default: () => 'CURRENT_TIMESTAMP' })
  updatedAt: Date;
}