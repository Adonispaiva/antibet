import { Injectable } from '@nestjs/common';
import { InjectRepository } from '@nestjs/typeorm';
import { Repository } from 'typeorm';
import { JournalEntry, JournalSentiment } from './entities/journal-entry.entity';
import { User } from '../../user/entities/user.entity';

@Injectable()
export class JournalService {
  constructor(
    @InjectRepository(JournalEntry)
    private readonly journalEntryRepository: Repository<JournalEntry>,
  ) {}

  /**
   * Cria uma nova entrada no diário para um usuário específico.
   * @param user O objeto do usuário que está criando a entrada.
   * @param createJournalEntryDto DTO contendo o conteúdo, tags, PnL, etc.
   * @returns A nova entrada do diário.
   */
  async createEntry(user: User, createJournalEntryDto: any): Promise<JournalEntry> {
    const newEntry = this.journalEntryRepository.create({
      ...createJournalEntryDto,
      user: user,
      userId: user.id,
      // A análise de sentimento (JournalSentiment) pode ser feita aqui por uma IA (futuro)
      sentiment: JournalSentiment.NEUTRAL,
    });
    
    return this.journalEntryRepository.save(newEntry);
  }

  /**
   * Retorna todas as entradas do diário para um usuário específico.
   * @param userId O ID do usuário.
   * @returns Lista de entradas do diário.
   */
  async findAllEntries(userId: string): Promise<JournalEntry[]> {
    return this.journalEntryRepository.find({
      where: { userId: userId },
      order: { tradeDate: 'DESC' }, // Ordena da mais recente para a mais antiga
    });
  }

  /**
   * Encontra uma entrada do diário pelo ID e verifica a posse.
   * @param id ID da entrada.
   * @param userId ID do usuário logado.
   * @returns A entrada do diário, se pertencer ao usuário.
   */
  async findOneEntry(id: string, userId: string): Promise<JournalEntry | undefined> {
    return this.journalEntryRepository.findOne({
      where: { id: id, userId: userId },
    });
  }

  /**
   * Atualiza uma entrada do diário.
   */
  async updateEntry(entry: JournalEntry, updateJournalEntryDto: any): Promise<JournalEntry> {
    const updatedEntry = this.journalEntryRepository.merge(entry, updateJournalEntryDto);
    return this.journalEntryRepository.save(updatedEntry);
  }

  /**
   * Remove uma entrada do diário.
   */
  async removeEntry(id: string, userId: string): Promise<void> {
    await this.journalEntryRepository.delete({ id: id, userId: userId });
  }
}