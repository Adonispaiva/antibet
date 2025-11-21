import { Injectable, NotFoundException } from '@nestjs/common';
import { InjectRepository } from '@nestjs/typeorm';
import { Repository } from 'typeorm';
import { Strategy } from './entities/strategy.entity';
import { User } from '../../user/entities/user.entity';

@Injectable()
export class StrategiesService {
  constructor(
    @InjectRepository(Strategy)
    private readonly strategyRepository: Repository<Strategy>,
  ) {}

  /**
   * Cria uma nova estratégia para um usuário.
   * @param user O objeto do usuário que está criando a estratégia.
   * @param createStrategyDto DTO contendo o nome, foco, risco, etc.
   * @returns A nova estratégia.
   */
  async createStrategy(user: User, createStrategyDto: any): Promise<Strategy> {
    const newStrategy = this.strategyRepository.create({
      ...createStrategyDto,
      user: user,
      userId: user.id,
    });
    
    return this.strategyRepository.save(newStrategy);
  }

  /**
   * Retorna todas as estratégias de um usuário específico.
   * @param userId O ID do usuário.
   * @returns Lista de estratégias.
   */
  async findAllUserStrategies(userId: string): Promise<Strategy[]> {
    return this.strategyRepository.find({
      where: { userId: userId, isActive: true },
      order: { createdAt: 'DESC' },
    });
  }

  /**
   * Encontra uma estratégia pelo ID e verifica a posse.
   * @param id ID da estratégia.
   * @param userId ID do usuário logado.
   * @returns A estratégia, se pertencer ao usuário.
   */
  async findOneStrategy(id: string, userId: string): Promise<Strategy> {
    const strategy = await this.strategyRepository.findOne({
      where: { id: id, userId: userId },
    });
    
    if (!strategy) {
      throw new NotFoundException('Estrategia nao encontrada ou nao pertence a este usuario.');
    }
    return strategy;
  }

  /**
   * Atualiza uma estratégia existente.
   */
  async updateStrategy(strategy: Strategy, updateStrategyDto: any): Promise<Strategy> {
    const updatedStrategy = this.strategyRepository.merge(strategy, updateStrategyDto);
    return this.strategyRepository.save(updatedStrategy);
  }

  /**
   * Remove (desativa) uma estratégia.
   * Não deletamos o registro, apenas marcamos como inativo.
   */
  async removeStrategy(id: string, userId: string): Promise<void> {
    const strategy = await this.findOneStrategy(id, userId);
    
    // Marcar como inativo em vez de deletar para manter o historico
    strategy.isActive = false;
    await this.strategyRepository.save(strategy);
  }
}