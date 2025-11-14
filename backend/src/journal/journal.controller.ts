// backend/src/journal/journal.controller.ts

import { 
  Controller, 
  Get, 
  Post, 
  Body, 
  Patch, 
  Param, 
  Delete, 
  UseGuards, 
  Req, 
  Query, 
  ParseIntPipe 
} from '@nestjs/common';
import { AuthGuard } from '@nestjs/passport';
import { Request } from 'express';

import { JournalService } from './journal.service';
import { CreateJournalEntryDto } from './dto/create-journal-entry.dto';
import { UpdateJournalEntryDto } from './dto/update-journal-entry.dto';
import { GetJournalEntriesFilterDto } from './dto/get-journal-entries-filter.dto';
import { User } from '../user/entities/user.entity'; // A Entidade de Usuário

/**
 * Interface customizada para a requisição com o objeto User injetado pelo JwtStrategy.
 */
interface RequestWithUser extends Request {
  user: User;
}

@Controller('journal')
@UseGuards(AuthGuard('jwt')) // Protege todas as rotas deste controller
export class JournalController {
  constructor(private readonly journalService: JournalService) {}

  /**
   * Cria uma nova entrada no diário.
   */
  @Post()
  create(
    @Body() createJournalEntryDto: CreateJournalEntryDto,
    @Req() req: RequestWithUser,
  ) {
    const userId = req.user.id;
    return this.journalService.create(createJournalEntryDto, userId);
  }

  /**
   * Lista todas as entradas do diário para o usuário logado, com filtros opcionais.
   */
  @Get()
  findAll(
    @Query() filterDto: GetJournalEntriesFilterDto,
    @Req() req: RequestWithUser,
  ) {
    const userId = req.user.id;
    return this.journalService.findAll(filterDto, userId);
  }

  /**
   * Obtém uma entrada específica do diário.
   */
  @Get(':id')
  findOne(
    @Param('id', ParseIntPipe) id: number,
    @Req() req: RequestWithUser,
  ) {
    const userId = req.user.id;
    return this.journalService.findOne(id, userId);
  }

  /**
   * Atualiza uma entrada específica do diário.
   */
  @Patch(':id')
  update(
    @Param('id', ParseIntPipe) id: number,
    @Body() updateJournalEntryDto: UpdateJournalEntryDto,
    @Req() req: RequestWithUser,
  ) {
    const userId = req.user.id;
    return this.journalService.update(id, updateJournalEntryDto, userId);
  }

  /**
   * Remove uma entrada específica do diário.
   */
  @Delete(':id')
  remove(
    @Param('id', ParseIntPipe) id: number,
    @Req() req: RequestWithUser,
  ) {
    const userId = req.user.id;
    return this.journalService.remove(id, userId);
  }
}