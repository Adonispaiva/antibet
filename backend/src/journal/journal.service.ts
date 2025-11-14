// backend/src/journal/journal.service.ts

import { Injectable, NotFoundException } from '@nestjs/common';
import { InjectRepository } from '@nestjs/typeorm';
import { Repository } from 'typeorm';
import { JournalEntry } from './entities/journal-entry.entity';
import { CreateJournalEntryDto } from './dto/create-journal-entry.dto'; // DTO de Criação
import { UpdateJournalEntryDto } from './dto/update-journal-entry.dto'; // DTO de Atualização
import { GetJournalEntriesFilterDto } from './dto/get-journal-entries-filter.dto'; // DTO de Filtro

@Injectable()
export class JournalService {
  constructor(
    @InjectRepository(JournalEntry)
    private readonly journalRepository: Repository<JournalEntry>,
  ) {}

  /**
   * Cria uma nova entrada no diário para o usuário especificado.
   * @param createJournalEntryDto Os dados validados da entrada.
   * @param userId O ID do usuário logado (obtido via JWT).
   * @returns A entidade de JournalEntry salva.
   */
  async create(
    createJournalEntryDto: CreateJournalEntryDto,
    userId: number,
  ): Promise<JournalEntry> {
    // A lógica de negócio aqui deve traduzir strategyName para strategyId se necessário,
    // mas por enquanto, assume-se que o DTO já contém o ID ou o Service lida com a busca.
    // Para simplificar, assumimos que o DTO contém o strategyId ou que o name será usado para busca.
    // Vamos mapear o DTO diretamente para a Entidade, assumindo que `strategyId` está presente.
    const newEntry = this.journalRepository.create({
      ...createJournalEntryDto,
      userId,
      entryDate: new Date(createJournalEntryDto.entryDate), // Converte a string ISO de volta para Date
      // NOTE: A tradução de `strategyName` para `strategyId` está omitida,
      // pois requer a injeção do StrategyService (que seria adicionada em refatoração posterior).
      // Por enquanto, assumimos a existência do campo.
    });

    return this.journalRepository.save(newEntry);
  }

  /**
   * Obtém todas as entradas do diário para o usuário logado, aplicando filtros.
   * @param filterDto Os critérios de filtro.
   * @param userId O ID do usuário logado.
   * @returns Uma lista de entradas do diário.
   */
  async findAll(
    filterDto: GetJournalEntriesFilterDto,
    userId: number,
  ): Promise<JournalEntry[]> {
    const query = this.journalRepository.createQueryBuilder('journalEntry');
    query.where('journalEntry.userId = :userId', { userId });

    // Lógica de Filtragem
    if (filterDto.strategyName) {
      // NOTE: Filtragem por nome de estratégia requer um JOIN com a tabela 'strategies'.
      // Esta lógica é complexa e será adicionada em uma refatoração de Ampliação.
      // Por agora, filtramos por um campo de StrategyName direto (se existisse) ou ignoramos.
    }

    if (filterDto.startDate) {
      query.andWhere('journalEntry.entryDate >= :startDate', {
        startDate: filterDto.startDate,
      });
    }

    if (filterDto.endDate) {
      query.andWhere('journalEntry.entryDate <= :endDate', {
        endDate: filterDto.endDate,
      });
    }

    if (filterDto.resultType) {
      // Lógica complexa para Win/Loss/Even
      if (filterDto.resultType === 'Win') {
        query.andWhere('journalEntry.finalResult > 0');
      } else if (filterDto.resultType === 'Loss') {
        query.andWhere('journalEntry.finalResult < 0');
      } else if (filterDto.resultType === 'Even') {
        query.andWhere('journalEntry.finalResult = 0');
      }
    }

    // Ordenação padrão: mais recente primeiro
    query.orderBy('journalEntry.entryDate', 'DESC');

    return query.getMany();
  }

  /**
   * Obtém uma entrada específica pelo ID, garantindo que pertença ao usuário logado.
   * @param id O ID da entrada.
   * @param userId O ID do usuário logado.
   * @returns A entidade de JournalEntry.
   * @throws NotFoundException se a entrada não existir ou não pertencer ao usuário.
   */
  async findOne(id: number, userId: number): Promise<JournalEntry> {
    const entry = await this.journalRepository.findOne({
      where: { id, userId },
    });

    if (!entry) {
      throw new NotFoundException(`Entrada de diário com ID "${id}" não encontrada.`);
    }
    return entry;
  }

  /**
   * Atualiza uma entrada específica, garantindo a posse.
   * @param id O ID da entrada.
   * @param updateJournalEntryDto Os dados a serem atualizados.
   * @param userId O ID do usuário logado.
   * @returns A entidade de JournalEntry atualizada.
   */
  async update(
    id: number,
    updateJournalEntryDto: UpdateJournalEntryDto,
    userId: number,
  ): Promise<JournalEntry> {
    const entry = await this.findOne(id, userId); // findOne já verifica a posse

    // Aplica as atualizações do DTO
    Object.assign(entry, updateJournalEntryDto);
    
    // Converte a data de volta, se estiver presente no update
    if (updateJournalEntryDto.entryDate) {
        entry.entryDate = new Date(updateJournalEntryDto.entryDate);
    }
    
    return this.journalRepository.save(entry);
  }

  /**
   * Remove uma entrada específica, garantindo a posse.
   * @param id O ID da entrada.
   * @param userId O ID do usuário logado.
   */
  async remove(id: number, userId: number): Promise<void> {
    const result = await this.journalRepository.delete({ id, userId });

    if (result.affected === 0) {
      throw new NotFoundException(`Entrada de diário com ID "${id}" não encontrada ou não pertence ao usuário.`);
    }
  }
}