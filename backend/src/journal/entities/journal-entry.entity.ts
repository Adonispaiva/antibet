import {
  Entity,
  PrimaryGeneratedColumn,
  Column,
  CreateDateColumn,
  ManyToOne,
} from 'typeorm';
import { User } from '../../user/user.entity'; // (Conforme Relatório 27/10)

/**
 * Enum para os tipos de humor que o usuário pode registrar.
 */
export enum JournalMood {
  POSITIVE = 'positive',
  NEUTRAL = 'neutral',
  NEGATIVE = 'negative',
  VERY_NEGATIVE = 'very_negative',
}

@Entity('journal_entries')
export class JournalEntry {
  @PrimaryGeneratedColumn('uuid')
  id: string;

  /**
   * O conteúdo textual da entrada do diário.
   */
  @Column('text')
  content: string;

  /**
   * O humor registrado pelo usuário no momento da entrada.
   */
  @Column({
    type: 'enum',
    enum: JournalMood,
    default: JournalMood.NEUTRAL,
  })
  mood: JournalMood;

  /**
   * A data em que a entrada foi criada.
   */
  @CreateDateColumn()
  createdAt: Date;

  /**
   * Relação: Muitas entradas de diário pertencem a Um Usuário.
   */
  @ManyToOne(() => User, (user) => user.journalEntries, { onDelete: 'CASCADE' })
  user: User;

  /**
   * Armazena o ID do usuário para facilitar consultas sem joins complexos.
   */
  @Column()
  userId: string;
}