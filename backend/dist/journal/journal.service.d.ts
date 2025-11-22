import { Repository } from 'typeorm';
import { JournalEntry } from './entities/journal-entry.entity';
import { User } from '../../user/entities/user.entity';
export declare class JournalService {
    private readonly journalEntryRepository;
    constructor(journalEntryRepository: Repository<JournalEntry>);
    createEntry(user: User, createJournalEntryDto: any): Promise<JournalEntry>;
    findAllEntries(userId: string): Promise<JournalEntry[]>;
    findOneEntry(id: string, userId: string): Promise<JournalEntry | undefined>;
    updateEntry(entry: JournalEntry, updateJournalEntryDto: any): Promise<JournalEntry>;
    removeEntry(id: string, userId: string): Promise<void>;
}
