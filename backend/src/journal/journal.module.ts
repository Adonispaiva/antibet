import { Module } from '@nestjs/common';
import { TypeOrmModule } from '@nestjs/typeorm';
import { JournalEntry } from './entities/journal-entry.entity';
import { JournalService } from './journal.service';
import { JournalController } from './journal.controller';
import { AuthModule } from '../auth/auth.module'; // Para o JwtAuthGuard

@Module({
  imports: [
    TypeOrmModule.forFeature([JournalEntry]),
    AuthModule, // Para acesso ao JwtAuthGuard
  ],
  providers: [JournalService],
  controllers: [JournalController],
})
export class JournalModule {}