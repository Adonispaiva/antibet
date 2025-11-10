import { ConfigService } from '@nestjs/config';
import { AiModel, AiModelName } from './ia-models.config';
export declare class AiGatewayService {
    private readonly configService;
    private openai;
    constructor(configService: ConfigService);
    getModel(modelName: AiModelName): AiModel;
    generateResponse(modelName: AiModelName, systemPrompt: string, userPrompt: string): Promise<string>;
}
