// backend/src/strategy/strategy.controller.ts

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

import { StrategyService } from './strategy.service';
import { CreateStrategyDto } from './dto/create-strategy.dto';
import { UpdateStrategyDto } from './dto/update-strategy.dto';
import { User } from '../user/entities/user.entity'; // A Entidade de Usuário

/**
 * Interface customizada para a requisição com o objeto User injetado pelo JwtStrategy.
 */
interface RequestWithUser extends Request {
  user: User;
}

@Controller('strategies')
@UseGuards(AuthGuard('jwt')) // Protege todas as rotas deste controller
export class StrategyController {
  constructor(private readonly strategyService: StrategyService) {}

  /**
   * Cria uma nova estratégia para o usuário logado.
   */
  @Post()
  create(
    @Body() createStrategyDto: CreateStrategyDto,
    @Req() req: RequestWithUser,
  ) {
    const userId = req.user.id;
    return this.strategyService.create(createStrategyDto, userId);
  }

  /**
   * Lista todas as estratégias do usuário logado.
   */
  @Get()
  findAll(@Req() req: RequestWithUser) {
    const userId = req.user.id;
    return this.strategyService.findAll(userId);
  }

  /**
   * Obtém uma estratégia específica pelo ID.
   */
  @Get(':id')
  findOne(
    @Param('id', ParseIntPipe) id: number,
    @Req() req: RequestWithUser,
  ) {
    const userId = req.user.id;
    return this.strategyService.findOne(id, userId);
  }

  /**
   * Atualiza uma estratégia específica.
   */
  @Patch(':id')
  update(
    @Param('id', ParseIntPipe) id: number,
    @Body() updateStrategyDto: UpdateStrategyDto,
    @Req() req: RequestWithUser,
  ) {
    const userId = req.user.id;
    return this.strategyService.update(id, updateStrategyDto, userId);
  }

  /**
   * Remove uma estratégia específica.
   */
  @Delete(':id')
  remove(
    @Param('id', ParseIntPipe) id: number,
    @Req() req: RequestWithUser,
  ) {
    const userId = req.user.id;
    return this.strategyService.remove(id, userId);
  }
}