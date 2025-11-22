import { Request, Response } from 'express';
export declare class AiInterventionController {
    private aiService;
    constructor();
    handleChat: (req: Request, res: Response) => Promise<void>;
}
