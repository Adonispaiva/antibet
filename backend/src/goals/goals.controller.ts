import {
  Controller,
  Get,
  Post,
  Body,
  Patch,
  Param,
  Delete,
  UseGuards,
  Request,
  NotFoundException,
} from '@nestjs/common';
import { AuthGuard } from '@nestjs/passport';

import { GoalsService } from './goals.service';
import { CreateGoalDto } from './dto/create-goal.dto';
import { UpdateGoalDto } from './dto/update-goal.dto';
import { Goal } from './entities/goal.entity';

// Interface para garantir o objeto user injetado pelo JwtStrategy
interface RequestWithUser extends Request {
  user: {
    userId: string;
    email: string;
    role: string;
  };
}

@UseGuards(AuthGuard('jwt')) // Protege todas as rotas deste controlador
@Controller('goals') // O nome do endpoint e plural e o padrao RESTful
export class GoalsController {
  constructor(private readonly goalsService: GoalsService) {}

  /**
   * Cria uma nova meta (POST /goals).
   */
  @Post()
  async create(
    @Request() req: RequestWithUser,
    @Body() createGoalDto: CreateGoalDto,
  ): Promise<Goal> {
    const user = { id: req.user.userId } as any; // Objeto user simplificado
    return this.goalsService.createGoal(user, createGoalDto);
  }

  /**
   * Lista todas as metas ativas do usuário logado (GET /goals).
   */
  @Get()
  async findAll(@Request() req: RequestWithUser): Promise<Goal[]> {
    return this.goalsService.findAllUserGoals(req.user.userId);
  }

  /**
   * Busca uma meta especifica (GET /goals/:id).
   */
  @Get(':id')
  async findOne(
    @Param('id') id: string,
    @Request() req: RequestWithUser,
  ): Promise<Goal> {
    // O service ja lanca a NotFoundException se nao encontrar ou se nao pertencer ao usuario
    return this.goalsService.findOneGoal(id, req.user.userId);
  }

  /**
   * Atualiza uma meta (PATCH /goals/:id).
   */
  @Patch(':id')
  async update(
    @Param('id') id: string,
    @Request() req: RequestWithUser,
    @Body() updateGoalDto: UpdateGoalDto,
  ): Promise<Goal> {
    const goal = await this.goalsService.findOneGoal(id, req.user.userId);
    // O service fará o merge e o save
    return this.goalsService.updateGoal(goal, updateGoalDto);
  }

  /**
   * Remove (desativa) uma meta (DELETE /goals/:id).
   * O service marca como isActive=false.
   */
  @Delete(':id')
  async remove(@Param('id') id: string, @Request() req: RequestWithUser): Promise<void> {
    // O service lanca NotFoundException se nao encontrar
    return this.goalsService.removeGoal(id, req.user.userId);
  }
}