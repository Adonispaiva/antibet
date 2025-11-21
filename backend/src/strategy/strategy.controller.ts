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

import { StrategiesService } from './strategies.service';
import { CreateStrategyDto } from './dto/create-strategy.dto';
import { UpdateStrategyDto } from './dto/update-strategy.dto';
import { Strategy } from './entities/strategy.entity';

// Interface para garantir o objeto user injetado pelo JwtStrategy
interface RequestWithUser extends Request {
  user: {
    userId: string;
    email: string;
    role: string;
  };
}

@UseGuards(AuthGuard('jwt')) // Protege todas as rotas deste controlador
@Controller('strategies') // O nome do endpoint e plural e o padrao RESTful
export class StrategiesController {
  constructor(private readonly strategiesService: StrategiesService) {}

  /**
   * Cria uma nova estrategia (POST /strategies).
   */
  @Post()
  async create(
    @Request() req: RequestWithUser,
    @Body() createStrategyDto: CreateStrategyDto,
  ): Promise<Strategy> {
    const user = { id: req.user.userId } as any; // Objeto user simplificado
    return this.strategiesService.createStrategy(user, createStrategyDto);
  }

  /**
   * Lista todas as estrategias ativas do usuario logado (GET /strategies).
   */
  @Get()
  async findAll(@Request() req: RequestWithUser): Promise<Strategy[]> {
    return this.strategiesService.findAllUserStrategies(req.user.userId);
  }

  /**
   * Busca uma estrategia especifica (GET /strategies/:id).
   */
  @Get(':id')
  async findOne(
    @Param('id') id: string,
    @Request() req: RequestWithUser,
  ): Promise<Strategy> {
    // O service ja lanca a NotFoundException se nao encontrar ou se nao pertencer ao usuario
    return this.strategiesService.findOneStrategy(id, req.user.userId);
  }

  /**
   * Atualiza uma estrategia (PATCH /strategies/:id).
   */
  @Patch(':id')
  async update(
    @Param('id') id: string,
    @Request() req: RequestWithUser,
    @Body() updateStrategyDto: UpdateStrategyDto,
  ): Promise<Strategy> {
    const strategy = await this.strategiesService.findOneStrategy(id, req.user.userId);
    // O service fará o merge e o save
    return this.strategiesService.updateStrategy(strategy, updateStrategyDto);
  }

  /**
   * Remove (desativa) uma estrategia (DELETE /strategies/:id).
   * O service marca como isActive=false.
   */
  @Delete(':id')
  async remove(@Param('id') id: string, @Request() req: RequestWithUser): Promise<void> {
    // O service lanca NotFoundException se nao encontrar
    return this.strategiesService.removeStrategy(id, req.user.userId);
  }
}