export declare class AiLogService {
    canUseChat(userId: string): Promise<boolean>;
    logAndDebitUsage(userId: string, tokenCount: number): Promise<boolean>;
}
