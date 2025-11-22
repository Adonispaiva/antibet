import { User } from '../../user/entities/user.entity';
export declare enum StrategyFocus {
    SWING = "swing",
    SCALPING = "scalping",
    POSITION = "position"
}
export declare class Strategy {
    id: string;
    user: User;
    userId: string;
    name: string;
    description: string;
    focus: StrategyFocus;
    riskPerTrade: number;
    targetWinRate: number;
    isActive: boolean;
    createdAt: Date;
    updatedAt: Date;
}
