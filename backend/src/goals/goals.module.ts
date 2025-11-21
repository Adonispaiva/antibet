import { Module } from '@nestjs/common';
import { TypeOrmModule } from '@nestjs/typeorm';
import { Goal } from './entities/goal.entity';
import { GoalsService } from './goals.service';
import { GoalsController } from './goals.controller';

@Module({
  imports: [
    // Registra a entidade Goal no TypeORM
    TypeOrmModule.forFeature([Goal]),
  ],
  controllers: [GoalsController],
  providers: [GoalsService],
  // O GoalsService deve ser exportado caso o módulo Metrics precise calcular o progresso das metas.
  exports: [GoalsService], 
})
export class GoalsModule {}