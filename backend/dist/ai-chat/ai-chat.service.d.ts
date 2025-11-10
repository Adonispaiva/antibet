import { AiGatewayService } from './ai-gateway.service';
import { AiLogService } from '../ai-log/ai-log.service';
import { PlansService } from '../plans/plans.service';
import { UserService } from '../user/user.service';
import { AiModelName } from './ia-models.config';
export declare class AiChatService {
    private readonly aiGatewayService;
    private readonly aiLogService;
    private readonly plansService;
    private readonly userService;
    constructor(aiGatewayService: AiGatewayService, aiLogService: AiLogService, plansService: PlansService, userService: UserService);
    handleInteraction(userId: string, userPrompt: string): Promise<{
        response: string;
        model: AiModelName;
    }>;
    private _buildSystemPrompt;
}
