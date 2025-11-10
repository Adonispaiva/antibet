import { Injectable, NotFoundException } from '@nestjs/common';
import { InjectRepository } from '@nestjs/typeorm';
import { Repository } from 'typeorm';
import { JournalEntry } from './entities/journal-entry.entity';
import { CreateJournalEntryDto } from './dto/create-journal-entry.dto';

@Injectable()
export class JournalService {
  constructor(
    @InjectRepository(JournalEntry)
    private readonly journalRepository: Repository<JournalEntry>,
  ) {}

  /**
   * Cria uma nova entrada de diário para um usuário específico.
   * @param userId O ID do usuário (vindo do token JWT)
   * @param createDto Os dados da nova entrada
   */
  async createEntry(
    userId: string,
    createDto: CreateJournalEntryDto,
  ): Promise<JournalEntry> {
    const newEntry = this.journalRepository.create({
      ...createDto,
      userId: userId, // Associa a entrada ao usuário
    });

    return this.journalRepository.save(newEntry);
  }

  /**
   * Busca todas as entradas de diário de um usuário específico.
   * @param userId O ID do usuário (vindo do token JWT)
   */
  async findEntriesByUserId(userId: string): Promise<JournalEntry[]> {
    return this.journalRepository.find({
      where: { userId: userId },
      order: {
        createdAt: 'DESC', // Retorna as mais recentes primeiro
      },
    });
  }

  /**
   * Deleta uma entrada de diário (se pertencer ao usuário).
   * @param userId O ID do usuário (vindo do token JWT)
   * @param entryId O ID da entrada a ser deletada
   */
  async deleteEntry(userId: string, entryId: string): Promise<void> {
    const result = await this.journalRepository.delete({
      id: entryId,
      userId: userId, // Garante que o usuário só delete suas próprias entradas
    });

    if (result.affected === 0) {
      throw new NotFoundException(
        'Entrada do diário não encontrada ou não pertence ao usuário.',
      );
    }
  }
}