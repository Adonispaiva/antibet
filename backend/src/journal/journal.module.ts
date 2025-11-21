import { Module } from '@nestjs/common';
import { TypeOrmModule } from '@nestjs/typeorm';
import { JournalEntry } from './entities/journal-entry.entity';
import { JournalService } from './journal.service';
import { JournalController } from './journal.controller';

@Module({
  imports: [
    // Registra a entidade JournalEntry no TypeORM
    TypeOrmModule.forFeature([JournalEntry]),
  ],
  controllers: [JournalController],
  providers: [JournalService],
  // O JournalService nao e exportado, pois presume-se que apenas o JournalController
  // precisa interagir com a lógica do diário. Se outros módulos (como Metrics ou AI Chat)
  // precisarem dele, esta seção deve ser atualizada.
  exports: [JournalService], 
})
export class JournalModule {}