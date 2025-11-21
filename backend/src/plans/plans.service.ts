import { Injectable } from '@nestjs/common';
import { InjectRepository } from '@nestjs/typeorm';
import { Repository } from 'typeorm';
import { Plan } from './entities/plan.entity';

@Injectable()
export class PlansService {
  constructor(
    @InjectRepository(Plan)
    private readonly planRepository: Repository<Plan>,
  ) {}

  /**
   * Retorna todos os planos ativos disponiveis no sistema.
   * @returns Lista de planos.
   */
  async findAllActivePlans(): Promise<Plan[]> {
    return this.planRepository.find({
      where: { isActive: true },
      order: { price: 'ASC' }, // Ordena do mais barato para o mais caro
    });
  }

  /**
   * Encontra um plano pelo seu ID unico.
   * @param id UUID do plano.
   */
  async findOne(id: string): Promise<Plan | undefined> {
    return this.planRepository.findOne({ where: { id } });
  }

  /**
   * Encontra um plano pelo seu ID no gateway de pagamento (ex: Stripe).
   * @param gatewayId O ID do plano no Stripe, PagSeguro, etc.
   */
  async findByGatewayId(gatewayId: string): Promise<Plan | undefined> {
    return this.planRepository.findOne({ where: { paymentGatewayId: gatewayId } });
  }
}