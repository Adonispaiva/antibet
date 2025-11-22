import { CreateJournalEntryDto } from './create-journal-entry.dto';
declare const UpdateJournalEntryDto_base: import("@nestjs/mapped-types").MappedType<Partial<CreateJournalEntryDto>>;
export declare class UpdateJournalEntryDto extends UpdateJournalEntryDto_base {
    content?: string;
    pnlValue?: number;
    tags?: string[];
    tradeDate?: string;
}
export {};
