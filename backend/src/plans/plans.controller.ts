import { Controller, Get, UseGuards, NotFoundException, Param } from '@nestjs/common';
import { PlansService } from './plans.service';
import { Plan } from './entities/plan.entity';
import { AuthGuard } from '@nestjs/passport';

@Controller('plans')
export class PlansController {
  constructor(private readonly plansService: PlansService) {}

  /**
   * Endpoint publico para listar todos os planos ativos.
   * Usado na tela de precos/assinatura do Frontend.
   * (Nao requer @UseGuards('jwt') pois deve ser visivel para usuarios nao logados)
   */
  @Get()
  async findAllActivePlans(): Promise<Plan[]> {
    return this.plansService.findAllActivePlans();
  }

  /**
   * Endpoint para buscar um plano especifico (ex: tela de checkout)
   * Protegido por JWT, assumindo que o usuario deve estar logado
   * para ver detalhes de um plano ou iniciar um checkout.
   */
  @UseGuards(AuthGuard('jwt'))
  @Get(':id')
  async findOne(@Param('id') id: string): Promise<Plan> {
    const plan = await this.plansService.findOne(id);
    if (!plan) {
      throw new NotFoundException('Plano nao encontrado');
    }
    return plan;
  }
}