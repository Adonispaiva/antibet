import { AuthenticatedRequest } from '../auth/interfaces/authenticated-request.interface';
import { JournalService } from './journal.service';
import { CreateJournalEntryDto } from './dto/create-journal-entry.dto';
export declare class JournalController {
    private readonly journalService;
    constructor(journalService: JournalService);
    create(req: AuthenticatedRequest, createDto: CreateJournalEntryDto): Promise<import("./entities/journal-entry.entity").JournalEntry>;
    findAll(req: AuthenticatedRequest): Promise<import("./entities/journal-entry.entity").JournalEntry[]>;
    remove(req: AuthenticatedRequest, entryId: string): Promise<void>;
}
