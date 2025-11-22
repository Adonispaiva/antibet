import { JournalEntry } from '../../journal/entities/journal-entry.entity';
import { Subscription } from '../../subscription/entities/subscription.entity';
export declare enum UserRole {
    ADMIN = "admin",
    PREMIUM = "premium",
    BASIC = "basic"
}
export declare class User {
    id: string;
    email: string;
    password: string;
    firstName: string;
    lastName: string;
    role: UserRole;
    isActive: boolean;
    stripeCustomerId: string;
    journalEntries: JournalEntry[];
    subscription: Subscription;
    createdAt: Date;
    updatedAt: Date;
}
