import { ConfigService } from '@nestjs/config';
export declare class GeminiApiService {
    private configService;
    private readonly apiKey;
    constructor(configService: ConfigService);
    generateResponse(systemPrompt: string, userMessage: string): Promise<string>;
}
