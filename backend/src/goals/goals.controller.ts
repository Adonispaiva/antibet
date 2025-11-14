// backend/src/goals/goals.controller.ts

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
  ParseIntPipe 
} from '@nestjs/common';
import { AuthGuard } from '@nestjs/passport';
import { Request } from 'express';

import { GoalsService } from './goals.service';
import { CreateGoalDto } from './dto/create-goal.dto';
import { UpdateGoalDto } from './dto/update-goal.dto';
import { User } from '../user/entities/user.entity'; // A Entidade de Usuário

/**
 * Interface customizada para a requisição com o objeto User injetado pelo JwtStrategy.
 */
interface RequestWithUser extends Request {
  user: User;
}

@Controller('goals')
@UseGuards(AuthGuard('jwt')) // Protege todas as rotas deste controller
export class GoalsController {
  constructor(private readonly goalsService: GoalsService) {}

  /**
   * Cria uma nova meta para o usuário logado.
   */
  @Post()
  create(
    @Body() createGoalDto: CreateGoalDto,
    @Req() req: RequestWithUser,
  ) {
    const userId = req.user.id;
    return this.goalsService.create(createGoalDto, userId);
  }

  /**
   * Lista todas as metas do usuário logado.
   */
  @Get()
  findAll(@Req() req: RequestWithUser) {
    const userId = req.user.id;
    return this.goalsService.findAll(userId);
  }

  /**
   * Obtém uma meta específica pelo ID.
   */
  @Get(':id')
  findOne(
    @Param('id', ParseIntPipe) id: number,
    @Req() req: RequestWithUser,
  ) {
    const userId = req.user.id;
    return this.goalsService.findOne(id, userId);
  }

  /**
   * Atualiza uma meta específica.
   */
  @Patch(':id')
  update(
    @Param('id', ParseIntPipe) id: number,
    @Body() updateGoalDto: UpdateGoalDto,
    @Req() req: RequestWithUser,
  ) {
    const userId = req.user.id;
    return this.goalsService.update(id, updateGoalDto, userId);
  }

  /**
   * Remove uma meta específica.
   */
  @Delete(':id')
  remove(
    @Param('id', ParseIntPipe) id: number,
    @Req() req: RequestWithUser,
  ) {
    const userId = req.user.id;
    return this.goalsService.remove(id, userId);
  }
}