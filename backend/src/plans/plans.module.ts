import { Module, OnModuleInit, forwardRef } from '@nestjs/common'; 
import { PlansService } from './plans.service';
import { PlansController } from './plans.controller';
import { TypeOrmModule } from '@nestjs/typeorm';
import { Plan } from './entities/plan.entity'; // Importação da Entidade Plan
import { PaymentsModule } from '../payments/payments.module';

@Module({
  imports: [
    TypeOrmModule.forFeature([Plan]), 
    // CRÍTICO: Usa forwardRef() para resolver o ciclo de importação
    forwardRef(() => PaymentsModule), 
  ],
  controllers: [PlansController],
  providers: [PlansService],
  exports: [PlansService, TypeOrmModule.forFeature([Plan])], 
})
export class PlansModule implements OnModuleInit { 
  constructor(private readonly plansService: PlansService) {}

  async onModuleInit() {
    // Chamada do seed que o compilador está vendo
    await this.plansService.seedPlans(); 
  }
}