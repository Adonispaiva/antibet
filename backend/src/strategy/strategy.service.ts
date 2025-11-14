// backend/src/strategy/strategy.service.ts

import { Injectable, ConflictException, NotFoundException } from '@nestjs/common';
import { InjectRepository } from '@nestjs/typeorm';
import { Repository } from 'typeorm';
import { Strategy } from './entities/strategy.entity';
import { CreateStrategyDto } from './dto/create-strategy.dto';
import { UpdateStrategyDto } from './dto/update-strategy.dto';

@Injectable()
export class StrategyService {
  constructor(
    @InjectRepository(Strategy)
    private readonly strategyRepository: Repository<Strategy>,
  ) {}

  /**
   * Cria uma nova estratégia, garantindo que o nome seja único para o usuário.
   * @param createStrategyDto Os dados validados da estratégia.
   * @param userId O ID do usuário logado.
   * @returns A entidade de Strategy salva.
   */
  async create(createStrategyDto: CreateStrategyDto, userId: number): Promise<Strategy> {
    // 1. Verifica se já existe uma estratégia com o mesmo nome para este usuário
    const existingStrategy = await this.strategyRepository.findOne({
      where: { name: createStrategyDto.name, userId },
    });

    if (existingStrategy) {
      throw new ConflictException(
        `Já existe uma estratégia com o nome "${createStrategyDto.name}" para este usuário.`,
      );
    }

    // 2. Cria e salva
    const newStrategy = this.strategyRepository.create({
      ...createStrategyDto,
      userId,
    });

    return this.strategyRepository.save(newStrategy);
  }

  /**
   * Obtém todas as estratégias do usuário logado.
   * @param userId O ID do usuário logado.
   * @returns Uma lista de estratégias.
   */
  async findAll(userId: number): Promise<Strategy[]> {
    // Retorna todas as estratégias, ordenadas por nome.
    return this.strategyRepository.find({
      where: { userId },
      order: { name: 'ASC' },
    });
  }

  /**
   * Obtém uma estratégia específica pelo ID, garantindo que pertença ao usuário logado.
   * @param id O ID da estratégia.
   * @param userId O ID do usuário logado.
   * @returns A entidade de Strategy.
   * @throws NotFoundException se não existir ou não pertencer ao usuário.
   */
  async findOne(id: number, userId: number): Promise<Strategy> {
    const strategy = await this.strategyRepository.findOne({
      where: { id, userId },
    });

    if (!strategy) {
      throw new NotFoundException(`Estratégia com ID "${id}" não encontrada.`);
    }
    return strategy;
  }

  /**
   * Atualiza uma estratégia específica, garantindo a posse e a unicidade do nome.
   * @param id O ID da estratégia.
   * @param updateStrategyDto Os dados a serem atualizados.
   * @param userId O ID do usuário logado.
   * @returns A entidade de Strategy atualizada.
   */
  async update(
    id: number,
    updateStrategyDto: UpdateStrategyDto,
    userId: number,
  ): Promise<Strategy> {
    const strategy = await this.findOne(id, userId); // findOne já verifica a posse

    // 1. Verifica a unicidade do nome, se ele for alterado
    if (updateStrategyDto.name && updateStrategyDto.name !== strategy.name) {
      const existingStrategy = await this.strategyRepository.findOne({
        where: { name: updateStrategyDto.name, userId },
      });

      if (existingStrategy) {
        throw new ConflictException(
          `Já existe outra estratégia com o nome "${updateStrategyDto.name}" para este usuário.`,
        );
      }
    }

    // 2. Aplica as atualizações do DTO e salva
    Object.assign(strategy, updateStrategyDto);
    return this.strategyRepository.save(strategy);
  }

  /**
   * Remove uma estratégia específica, garantindo a posse.
   * @param id O ID da estratégia.
   * @param userId O ID do usuário logado.
   */
  async remove(id: number, userId: number): Promise<void> {
    const result = await this.strategyRepository.delete({ id, userId });

    if (result.affected === 0) {
      throw new NotFoundException(`Estratégia com ID "${id}" não encontrada ou não pertence ao usuário.`);
    }
  }
}