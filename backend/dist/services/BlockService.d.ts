export declare class BlockService {
    enforceBlock(userId: string, durationMinutes: number): Promise<boolean>;
    unlock(userId: string): Promise<boolean>;
}
