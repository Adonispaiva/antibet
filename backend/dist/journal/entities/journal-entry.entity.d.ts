import { User } from '../../user/entities/user.entity';
export declare enum JournalSentiment {
    POSITIVE = "positive",
    NEUTRAL = "neutral",
    NEGATIVE = "negative"
}
export declare class JournalEntry {
    id: string;
    user: User;
    userId: string;
    content: string;
    sentiment: JournalSentiment;
    pnlValue: number;
    tags: string[];
    tradeDate: Date;
    createdAt: Date;
    updatedAt: Date;
}
