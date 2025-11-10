import { Plan } from '../plans/entities/plan.entity';
import { AiInteractionLog } from '../ai-chat/entities/ai-log.entity';
import { JournalEntry } from '../journal/entities/journal-entry.entity';
import { Goal } from '../goals/entities/goal.entity';
export declare class User {
    id: string;
    email: string;
    passwordHash: string;
    avatarName: string;
    birthYear: number;
    gender: string;
    mainConcern?: string;
    createdAt: Date;
    updatedAt: Date;
    planId: string;
    plan: Plan;
    aiLogs: AiInteractionLog[];
    journalEntries: JournalEntry[];
    goals: Goal[];
}
