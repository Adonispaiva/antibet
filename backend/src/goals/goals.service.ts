// backend/src/goals/goals.service.ts

import { Injectable, NotFoundException } from '@nestjs/common';
import { InjectRepository } from '@nestjs/typeorm';
import { Repository } from 'typeorm';
import { Goal } from './entities/goal.entity';
import { CreateGoalDto } from './dto/create-goal.dto';
import { UpdateGoalDto } from './dto/update-goal.dto';

@Injectable()
export class GoalsService {
  constructor(
    @InjectRepository(Goal)
    private readonly goalsRepository: Repository<Goal>,
  ) {}

  /**
   * Cria uma nova meta para o usuário especificado.
   * @param createGoalDto Os dados validados da meta.
   * @param userId O ID do usuário logado (obtido via JWT).
   * @returns A entidade de Goal salva.
   */
  async create(createGoalDto: CreateGoalDto, userId: number): Promise<Goal> {
    const newGoal = this.goalsRepository.create({
      ...createGoalDto,
      userId,
      targetDate: new Date(createGoalDto.targetDate), // Converte a string ISO para Date
    });

    return this.goalsRepository.save(newGoal);
  }

  /**
   * Obtém todas as metas do diário para o usuário logado.
   * @param userId O ID do usuário logado.
   * @returns Uma lista de metas.
   */
  async findAll(userId: number): Promise<Goal[]> {
    // Retorna todas as metas, ordenadas por data alvo.
    return this.goalsRepository.find({
      where: { userId },
      order: { targetDate: 'ASC' },
    });
  }

  /**
   * Obtém uma meta específica pelo ID, garantindo que pertença ao usuário logado.
   * @param id O ID da meta.
   * @param userId O ID do usuário logado.
   * @returns A entidade de Goal.
   * @throws NotFoundException se a meta não existir ou não pertencer ao usuário.
   */
  async findOne(id: number, userId: number): Promise<Goal> {
    const goal = await this.goalsRepository.findOne({
      where: { id, userId },
    });

    if (!goal) {
      throw new NotFoundException(`Meta com ID "${id}" não encontrada.`);
    }
    return goal;
  }

  /**
   * Atualiza uma meta específica, garantindo a posse.
   * @param id O ID da meta.
   * @param updateGoalDto Os dados a serem atualizados.
   * @param userId O ID do usuário logado.
   * @returns A entidade de Goal atualizada.
   */
  async update(
    id: number,
    updateGoalDto: UpdateGoalDto,
    userId: number,
  ): Promise<Goal> {
    const goal = await this.findOne(id, userId); // findOne já verifica a posse

    // Aplica as atualizações do DTO
    Object.assign(goal, updateGoalDto);
    
    // Lógica para atualizar a data de conclusão se isCompleted for true
    if (updateGoalDto.isCompleted === true && !goal.completionDate) {
      goal.completionDate = new Date();
    } else if (updateGoalDto.isCompleted === false) {
      goal.completionDate = null;
    }

    // Converte a data de volta, se estiver presente no update
    if (updateGoalDto.targetDate) {
      goal.targetDate = new Date(updateGoalDto.targetDate);
    }
    
    return this.goalsRepository.save(goal);
  }

  /**
   * Remove uma meta específica, garantindo a posse.
   * @param id O ID da meta.
   * @param userId O ID do usuário logado.
   */
  async remove(id: number, userId: number): Promise<void> {
    const result = await this.goalsRepository.delete({ id, userId });

    if (result.affected === 0) {
      throw new NotFoundException(`Meta com ID "${id}" não encontrada ou não pertence ao usuário.`);
    }
  }
}