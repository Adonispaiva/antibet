import { Injectable, InternalServerErrorException, NotFoundException } from '@nestjs/common';
import { InjectRepository } from '@nestjs/typeorm';
import { Repository } from 'typeorm';
import { Plan } from './entities/plan.entity'; // CRÍTICO: Importação correta da Entidade Plan
import { PLANS_SEED_DATA } from './plans.seed'; // CRÍTICO: Importação do arquivo de Seed

@Injectable()
export class PlansService {
  constructor(
    @InjectRepository(Plan)
    private readonly planRepository: Repository<Plan>,
  ) {
  }
  
  // (Métodos findAllPlans, findPlanByStripeId, initiateCheckout - Mantidos e Corretos)
  
  /**
   * CRÍTICO: Popula a tabela de planos se ela estiver vazia.
   */
  async seedPlans(): Promise<void> {
    const existingPlansCount = await this.planRepository.count();

    if (existingPlansCount > 0) {
      console.log('[PLANS SEED] Catálogo de planos já existe. Pulando o Seed.');
      return;
    }

    console.log('[PLANS SEED] Iniciando o Seed de Catálogo...');

    try {
      for (const planData of PLANS_SEED_DATA) {
        // Agora, o compilador deve reconhecer 'name' e outras propriedades
        if (!planData.name || !planData.price || !planData.stripePriceId) {
             console.warn(`[PLANS SEED] Pulando plano inválido: ${planData.name || 'Nome Desconhecido'}`);
             continue;
        }
        // Cria a entidade, usando o tipagem correta de Plan
        const plan = this.planRepository.create(planData as Plan); 
        await this.planRepository.save(plan);
        console.log(`[PLANS SEED] Plano ${plan.name} criado.`);
      }
      console.log('[PLANS SEED] Seed de Catálogo concluído com sucesso.');
    } catch (error) {
      console.error('[PLANS SEED] Erro Crítico durante o Seed:', error);
      throw new InternalServerErrorException('Falha fatal ao popular o catálogo de planos.');
    }
  }

  // Métodos de catálogo e checkout (Removidos para brevidade, mas devem estar no arquivo final)
  // ...
  async findAllPlans(): Promise<Plan[]> {
    return this.planRepository.find({ order: { price: 'ASC' } });
  }

  async findPlanByStripeId(stripePriceId: string): Promise<Plan | null> {
    return this.planRepository.findOne({ where: { stripePriceId } });
  }

  async initiateCheckout(userId: string, planId: string): Promise<{ checkoutUrl: string }> {
      const plan = await this.planRepository.findOne({ where: { id: planId } });
      if (!plan) throw new NotFoundException('Plano não encontrado.');
      return { checkoutUrl: `https://checkout.stripe.com/pay/${plan.stripePriceId}?user=${userId}` };
  }
}