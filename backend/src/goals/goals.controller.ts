import {
  Controller,
  Get,
  Post,
  Body,
  Patch,
  Param,
  Delete,
  UseGuards,
  Req,
  ParseUUIDPipe,
  HttpCode,
  HttpStatus,
} from '@nestjs/common';
import { GoalsService } from './goals.service';
import { CreateGoalDto } from './dto/create-goal.dto';
import { UpdateGoalDto } from './dto/update-goal.dto';
import { JwtAuthGuard } from '../auth/guards/jwt-auth.guard';
import { AuthenticatedRequest } from '../auth/interfaces/authenticated-request.interface';

@UseGuards(JwtAuthGuard) // Protege todas as rotas de Metas
@Controller('goals')
export class GoalsController {
  constructor(private readonly goalsService: GoalsService) {}

  /**
   * Rota para criar uma nova meta.
   */
  @Post()
  @HttpCode(HttpStatus.CREATED)
  create(
    @Req() req: AuthenticatedRequest,
    @Body() createGoalDto: CreateGoalDto,
  ) {
    const userId = req.user.userId;
    return this.goalsService.createGoal(userId, createGoalDto);
  }

  /**
   * Rota para buscar todas as metas do usuário logado.
   */
  @Get()
  findAll(@Req() req: AuthenticatedRequest) {
    const userId = req.user.userId;
    return this.goalsService.findGoalsByUserId(userId);
  }

  /**
   * Rota para atualizar uma meta (ex: marcar como concluída).
   */
  @Patch(':id')
  update(
    @Req() req: AuthenticatedRequest,
    @Param('id', ParseUUIDPipe) goalId: string,
    @Body() updateGoalDto: UpdateGoalDto,
  ) {
    const userId = req.user.userId;
    return this.goalsService.updateGoal(userId, goalId, updateGoalDto);
  }

  /**
   * Rota para deletar uma meta.
   */
  @Delete(':id')
  @HttpCode(HttpStatus.NO_CONTENT)
  remove(
    @Req() req: AuthenticatedRequest,
    @Param('id', ParseUUIDPipe) goalId: string,
  ) {
    const userId = req.user.userId;
    return this.goalsService.deleteGoal(userId, goalId);
  }
}