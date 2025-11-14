// backend/src/journal/entities/journal-entry.entity.ts

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
import { User } from '../../user/entities/user.entity'; // Entidade do Usuário
import { Strategy } from '../../strategy/entities/strategy.entity'; // Entidade de Estratégia

/**
 * Entidade que registra uma entrada individual no diário de análises do usuário.
 * * É o dado mais importante do AntiBet, contendo o registro financeiro e a análise.
 */
@Entity('journal_entries')
export class JournalEntry {
  @PrimaryGeneratedColumn()
  id: number;

  @Column()
  userId: number; // Chave estrangeira para o usuário
  
  @ManyToOne(() => User, user => user.id) // Relação N:1 com a entidade User
  @JoinColumn({ name: 'userId' })
  user: User;

  @Column()
  strategyId: number; // Chave estrangeira para a estratégia utilizada
  
  @ManyToOne(() => Strategy, strategy => strategy.id) // Relação N:1 com a entidade Strategy
  @JoinColumn({ name: 'strategyId' })
  strategy: Strategy;

  @Column('decimal', { precision: 10, scale: 2 })
  stake: number; // Valor apostado/investido

  @Column('decimal', { precision: 10, scale: 2 })
  finalResult: number; // Lucro/Prejuízo (Pode ser negativo)

  @Column({ type: 'timestamp' })
  entryDate: Date; // Data e hora da entrada (para ordenação e filtros)

  @Column({ length: 255, nullable: true })
  market: string; // Ex: Futebol, Over/Under, etc.

  @Column('text')
  preAnalysis: string; // Análise feita antes do resultado

  @Column('text', { nullable: true })
  postAnalysis: string; // Análise feita após o resultado (opcional)

  @CreateDateColumn({ type: 'timestamp', default: () => 'CURRENT_TIMESTAMP' })
  createdAt: Date;

  @UpdateDateColumn({ type: 'timestamp', default: () => 'CURRENT_TIMESTAMP' })
  updatedAt: Date;
}