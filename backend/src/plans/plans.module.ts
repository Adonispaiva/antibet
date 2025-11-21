import { Module } from '@nestjs/common';
import { TypeOrmModule } from '@nestjs/typeorm';
import { PlansService } from './plans.service';
import { PlansController } from './plans.controller';
import { Plan } from './entities/plan.entity';

@Module({
  imports: [
    // Registra a entidade Plan no TypeORM
    TypeOrmModule.forFeature([Plan]),
  ],
  controllers: [PlansController],
  providers: [PlansService],
  // Exportamos o PlansService caso o PaymentsModule precise usa-lo
  exports: [PlansService], 
})
export class PlansModule {}