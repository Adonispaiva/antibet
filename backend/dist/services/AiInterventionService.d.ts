export declare class AiInterventionService {
    private genAI;
    private model;
    private userService;
    private blockService;
    private readonly API_KEY;
    constructor();
    processInteraction(userId: string, userMessage: string): Promise<string>;
}
