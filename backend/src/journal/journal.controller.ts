import {
  Controller,
  Get,
  Post,
  Body,
  Patch,
  Param,
  Delete,
  UseGuards,
  Request,
  NotFoundException,
} from '@nestjs/common';
import { AuthGuard } from '@nestjs/passport';

import { JournalService } from './journal.service';
import { CreateJournalEntryDto } from './dto/create-journal-entry.dto';
import { UpdateJournalEntryDto } from './dto/update-journal-entry.dto';
import { JournalEntry } from './entities/journal-entry.entity';

// Interface para garantir o objeto user injetado pelo JwtStrategy
interface RequestWithUser extends Request {
  user: {
    userId: string;
    email: string;
    role: string;
  };
}

@UseGuards(AuthGuard('jwt')) // Protege todas as rotas deste controlador
@Controller('journal')
export class JournalController {
  constructor(private readonly journalService: JournalService) {}

  /**
   * Cria uma nova entrada no diário (POST /journal).
   */
  @Post()
  async create(
    @Request() req: RequestWithUser,
    @Body() createJournalEntryDto: CreateJournalEntryDto,
  ): Promise<JournalEntry> {
    const user = { id: req.user.userId } as any; // Objeto user simplificado
    return this.journalService.createEntry(user, createJournalEntryDto);
  }

  /**
   * Lista todas as entradas do diário do usuário logado (GET /journal).
   */
  @Get()
  async findAll(@Request() req: RequestWithUser): Promise<JournalEntry[]> {
    return this.journalService.findAllEntries(req.user.userId);
  }

  /**
   * Busca uma entrada especifica (GET /journal/:id).
   */
  @Get(':id')
  async findOne(
    @Param('id') id: string,
    @Request() req: RequestWithUser,
  ): Promise<JournalEntry> {
    const entry = await this.journalService.findOneEntry(id, req.user.userId);
    if (!entry) {
      throw new NotFoundException('Entrada do diario nao encontrada ou nao pertence a este usuario.');
    }
    return entry;
  }

  /**
   * Atualiza uma entrada (PATCH /journal/:id).
   */
  @Patch(':id')
  async update(
    @Param('id') id: string,
    @Request() req: RequestWithUser,
    @Body() updateJournalEntryDto: UpdateJournalEntryDto,
  ): Promise<JournalEntry> {
    const entry = await this.journalService.findOneEntry(id, req.user.userId);
    if (!entry) {
      throw new NotFoundException('Entrada do diario nao encontrada.');
    }
    return this.journalService.updateEntry(entry, updateJournalEntryDto);
  }

  /**
   * Remove uma entrada (DELETE /journal/:id).
   */
  @Delete(':id')
  async remove(@Param('id') id: string, @Request() req: RequestWithUser): Promise<void> {
    const entry = await this.journalService.findOneEntry(id, req.user.userId);
    if (!entry) {
      throw new NotFoundException('Entrada do diario nao encontrada.');
    }
    return this.journalService.removeEntry(id, req.user.userId);
  }
}