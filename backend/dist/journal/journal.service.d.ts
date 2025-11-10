import { Repository } from 'typeorm';
import { JournalEntry } from './entities/journal-entry.entity';
import { CreateJournalEntryDto } from './dto/create-journal-entry.dto';
export declare class JournalService {
    private readonly journalRepository;
    constructor(journalRepository: Repository<JournalEntry>);
    createEntry(userId: string, createDto: CreateJournalEntryDto): Promise<JournalEntry>;
    findEntriesByUserId(userId: string): Promise<JournalEntry[]>;
    deleteEntry(userId: string, entryId: string): Promise<void>;
}
