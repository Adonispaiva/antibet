import { Module } from '@nestjs/common';
import { TypeOrmModule } from '@nestjs/typeorm';
import { Strategy } from './entities/strategy.entity';
import { StrategiesService } from './strategies.service';
import { StrategiesController } from './strategy.controller';

@Module({
  imports: [
    // Registra a entidade Strategy no TypeORM
    TypeOrmModule.forFeature([Strategy]),
  ],
  controllers: [StrategiesController],
  providers: [StrategiesService],
  // O StrategiesService deve ser exportado caso o módulo Journal ou Goals
  // precise listar ou referenciar as estratégias de um usuário.
  exports: [StrategiesService], 
})
export class StrategyModule {}