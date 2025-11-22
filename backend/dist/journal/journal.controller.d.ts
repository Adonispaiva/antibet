import { JournalService } from './journal.service';
import { CreateJournalEntryDto } from './dto/create-journal-entry.dto';
import { UpdateJournalEntryDto } from './dto/update-journal-entry.dto';
import { JournalEntry } from './entities/journal-entry.entity';
interface RequestWithUser extends Request {
    user: {
        userId: string;
        email: string;
        role: string;
    };
}
export declare class JournalController {
    private readonly journalService;
    constructor(journalService: JournalService);
    create(req: RequestWithUser, createJournalEntryDto: CreateJournalEntryDto): Promise<JournalEntry>;
    findAll(req: RequestWithUser): Promise<JournalEntry[]>;
    findOne(id: string, req: RequestWithUser): Promise<JournalEntry>;
    update(id: string, req: RequestWithUser, updateJournalEntryDto: UpdateJournalEntryDto): Promise<JournalEntry>;
    remove(id: string, req: RequestWithUser): Promise<void>;
}
export {};
