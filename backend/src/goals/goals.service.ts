import { Injectable, NotFoundException } from '@nestjs/common';
import { InjectRepository } from '@nestjs/typeorm';
import { Repository } from 'typeorm';
import { Goal } from './entities/goal.entity';
import { User } from '../../user/entities/user.entity';

@Injectable()
export class GoalsService {
  constructor(
    @InjectRepository(Goal)
    private readonly goalRepository: Repository<Goal>,
  ) {}

  /**
   * Cria uma nova meta para um usuário.
   * @param user O objeto do usuário.
   * @param createGoalDto DTO contendo o título, valor alvo, etc.
   * @returns A nova meta.
   */
  async createGoal(user: User, createGoalDto: any): Promise<Goal> {
    const newGoal = this.goalRepository.create({
      ...createGoalDto,
      user: user,
      userId: user.id,
    });
    
    return this.goalRepository.save(newGoal);
  }

  /**
   * Retorna todas as metas ativas de um usuário.
   * @param userId O ID do usuário.
   * @returns Lista de metas.
   */
  async findAllUserGoals(userId: string): Promise<Goal[]> {
    return this.goalRepository.find({
      where: { userId: userId, isActive: true },
      order: { targetDate: 'ASC' }, // Ordena pela data alvo
    });
  }

  /**
   * Encontra uma meta pelo ID e verifica a posse.
   * @param id ID da meta.
   * @param userId ID do usuário logado.
   * @returns A meta, se pertencer ao usuário.
   */
  async findOneGoal(id: string, userId: string): Promise<Goal> {
    const goal = await this.goalRepository.findOne({
      where: { id: id, userId: userId },
    });
    
    if (!goal) {
      throw new NotFoundException('Meta nao encontrada ou nao pertence a este usuario.');
    }
    return goal;
  }

  /**
   * Atualiza uma meta existente.
   */
  async updateGoal(goal: Goal, updateGoalDto: any): Promise<Goal> {
    const updatedGoal = this.goalRepository.merge(goal, updateGoalDto);
    
    // Logica: Se o currentValue >= targetValue, marcar como isCompleted=true
    if (updatedGoal.currentValue >= updatedGoal.targetValue) {
      updatedGoal.isCompleted = true;
    }

    return this.goalRepository.save(updatedGoal);
  }

  /**
   * Remove (desativa) uma meta.
   */
  async removeGoal(id: string, userId: string): Promise<void> {
    const goal = await this.findOneGoal(id, userId);
    
    // Marcar como inativo
    goal.isActive = false;
    await this.goalRepository.save(goal);
  }
}