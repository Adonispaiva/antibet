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
    private readonly goalRepository: Repository<Goal>,
  ) {}

  /**
   * Cria uma nova meta para um usuário.
   */
  async createGoal(
    userId: string,
    createDto: CreateGoalDto,
  ): Promise<Goal> {
    const newGoal = this.goalRepository.create({
      ...createDto,
      userId: userId, // Associa ao usuário
    });
    return this.goalRepository.save(newGoal);
  }

  /**
   * Busca todas as metas de um usuário.
   */
  async findGoalsByUserId(userId: string): Promise<Goal[]> {
    return this.goalRepository.find({
      where: { userId: userId },
      order: {
        isCompleted: 'ASC', // Pendentes primeiro
        createdAt: 'DESC',  // Mais recentes primeiro
      },
    });
  }

  /**
   * Busca uma meta (usado internamente para verificação de propriedade).
   */
  private async findOneOrFail(
    userId: string,
    goalId: string,
  ): Promise<Goal> {
    const goal = await this.goalRepository.findOne({
      where: { id: goalId, userId: userId },
    });
    if (!goal) {
      throw new NotFoundException(
        'Meta não encontrada ou não pertence ao usuário.',
      );
    }
    return goal;
  }

  /**
   * Atualiza uma meta (ex: marcar como concluída).
   */
  async updateGoal(
    userId: string,
    goalId: string,
    updateDto: UpdateGoalDto,
  ): Promise<Goal> {
    // 1. Verifica se a meta existe e pertence ao usuário
    const goal = await this.findOneOrFail(userId, goalId);

    // 2. Mescla as atualizações
    const updatedGoal = this.goalRepository.merge(goal, updateDto);

    return this.goalRepository.save(updatedGoal);
  }

  /**
   * Deleta uma meta.
   */
  async deleteGoal(userId: string, goalId: string): Promise<void> {
    // 1. Verifica se a meta existe e pertence ao usuário
    const goal = await this.findOneOrFail(userId, goalId);

    // 2. Deleta
    await this.goalRepository.remove(goal);
  }
}