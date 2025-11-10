import { Module } from '@nestjs/common';
import { TypeOrmModule } from '@nestjs/typeorm';
import { Goal } from './entities/goal.entity';
import { GoalsService } from './goals.service';
import { GoalsController } from './goals.controller';
import { AuthModule } from '../auth/auth.module'; // Para o JwtAuthGuard

@Module({
  imports: [
    TypeOrmModule.forFeature([Goal]),
    AuthModule, // Para acesso ao JwtAuthGuard
  ],
  providers: [GoalsService],
  controllers: [GoalsController],
})
export class GoalsModule {}