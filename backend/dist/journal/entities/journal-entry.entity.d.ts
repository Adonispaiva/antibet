import { User } from '../../user/user.entity';
export declare enum JournalMood {
    POSITIVE = "positive",
    NEUTRAL = "neutral",
    NEGATIVE = "negative",
    VERY_NEGATIVE = "very_negative"
}
export declare class JournalEntry {
    id: string;
    content: string;
    mood: JournalMood;
    createdAt: Date;
    user: User;
    userId: string;
}
