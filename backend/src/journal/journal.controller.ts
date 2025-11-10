import {
  Controller,
  Get,
  Post,
  Body,
  UseGuards,
  Req,
  Param,
  Delete,
  ParseUUIDPipe,
  HttpCode,
  HttpStatus,
} from '@nestjs/common';
import { JwtAuthGuard } from '../auth/guards/jwt-auth.guard';
import { AuthenticatedRequest } from '../auth/interfaces/authenticated-request.interface';
import { JournalService } from './journal.service';
import { CreateJournalEntryDto } from './dto/create-journal-entry.dto';

@UseGuards(JwtAuthGuard) // Protege todas as rotas neste controller
@Controller('journal')
export class JournalController {
  constructor(private readonly journalService: JournalService) {}

  /**
   * Rota para criar uma nova entrada de diário.
   */
  @Post()
  @HttpCode(HttpStatus.CREATED)
  create(
    @Req() req: AuthenticatedRequest,
    @Body() createDto: CreateJournalEntryDto,
  ) {
    const userId = req.user.userId;
    return this.journalService.createEntry(userId, createDto);
  }

  /**
   * Rota para buscar todas as entradas de diário do usuário logado.
   */
  @Get()
  findAll(@Req() req: AuthenticatedRequest) {
    const userId = req.user.userId;
    return this.journalService.findEntriesByUserId(userId);
  }

  /**
   * Rota para deletar uma entrada de diário específica.
   */
  @Delete(':id')
  @HttpCode(HttpStatus.NO_CONTENT)
  remove(
    @Req() req: AuthenticatedRequest,
    @Param('id', ParseUUIDPipe) entryId: string,
  ) {
    const userId = req.user.userId;
    return this.journalService.deleteEntry(userId, entryId);
  }
}