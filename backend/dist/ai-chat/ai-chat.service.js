"use strict";
var __decorate = (this && this.__decorate) || function (decorators, target, key, desc) {
    var c = arguments.length, r = c < 3 ? target : desc === null ? desc = Object.getOwnPropertyDescriptor(target, key) : desc, d;
    if (typeof Reflect === "object" && typeof Reflect.decorate === "function") r = Reflect.decorate(decorators, target, key, desc);
    else for (var i = decorators.length - 1; i >= 0; i--) if (d = decorators[i]) r = (c < 3 ? d(r) : c > 3 ? d(target, key, r) : d(target, key)) || r;
    return c > 3 && r && Object.defineProperty(target, key, r), r;
};
var __metadata = (this && this.__metadata) || function (k, v) {
    if (typeof Reflect === "object" && typeof Reflect.metadata === "function") return Reflect.metadata(k, v);
};
var _a;
Object.defineProperty(exports, "__esModule", { value: true });
exports.AiChatService = void 0;
const common_1 = require("@nestjs/common");
const ai_gateway_service_1 = require("./ai-gateway.service");
const ai_log_service_1 = require("../ai-log/ai-log.service");
const plans_service_1 = require("../plans/plans.service");
const user_service_1 = require("../user/user.service");
const ia_models_config_1 = require("./ia-models.config");
let AiChatService = class AiChatService {
    constructor(aiGatewayService, aiLogService, plansService, userService) {
        this.aiGatewayService = aiGatewayService;
        this.aiLogService = aiLogService;
        this.plansService = plansService;
        this.userService = userService;
    }
    async handleInteraction(userId, userPrompt) {
        const plan = await this.plansService.findPlanByUserId(userId);
        const dailyUsage = await this.aiLogService.getDailyUsage(userId);
        if (dailyUsage >= plan.aiDailyLimit) {
            throw new common_1.ForbiddenException(`Limite diário de ${plan.aiDailyLimit} interações atingido para o plano ${plan.name}.`);
        }
        const user = await this.userService.findById(userId);
        if (!user) {
            throw new common_1.NotFoundException('Usuário da interação não encontrado.');
        }
        const systemPrompt = this._buildSystemPrompt(user);
        const modelName = ia_models_config_1.AiModelName.GPT_4_TURBO;
        const modelConfig = this.aiGatewayService.getModel(modelName);
        const aiResponse = await this.aiGatewayService.generateResponse(modelName, systemPrompt, userPrompt);
        try {
            await this.aiLogService.createLog({
                userId,
                model: modelName,
                cost: modelConfig.costPerInteraction,
                prompt,
            });
        }
        catch (logError) {
            console.error(`Falha ao registrar log de IA para userId ${userId}:`, logError);
        }
        return { response: aiResponse, model: modelName };
    }
    _buildSystemPrompt(user) {
        const birthYear = user.birthYear;
        const age = new Date().getFullYear() - birthYear;
        const gender = user.gender === 'male' ? 'homem' : (user.gender === 'female' ? 'mulher' : 'pessoa');
        const userName = user.avatarName;
        return `
      **Instrução de Contexto (System Prompt):**
      Você é o "Assistente AntiBet", um terapeuta compassivo e especializado em vício em jogos de azar (Gambling Addiction).
      
      **Contexto do Usuário:**
      - Nome (Avatar): ${userName}
      - Idade Aproximada: ${age} anos (nascido em ${birthYear})
      - Gênero: ${gender}
      - Preocupação Principal (se houver): ${user.mainConcern || 'Não informada'}

      **Diretrizes de Interação:**
      1.  Seja sempre empático, solidário e não julgador.
      2.  Use o nome "${userName}" ocasionalmente para criar uma conexão.
      3.  Foque em técnicas de Terapia Cognitivo-Comportamental (TCC) para identificar gatilhos e reestruturar pensamentos.
      4.  NUNCA dê conselhos financeiros. O foco é estritamente terapêutico e comportamental.
      5.  Mantenha as respostas concisas e fáceis de entender.
    `;
    }
};
exports.AiChatService = AiChatService;
exports.AiChatService = AiChatService = __decorate([
    (0, common_1.Injectable)(),
    __metadata("design:paramtypes", [ai_gateway_service_1.AiGatewayService, typeof (_a = typeof ai_log_service_1.AiLogService !== "undefined" && ai_log_service_1.AiLogService) === "function" ? _a : Object, plans_service_1.PlansService,
        user_service_1.UserService])
], AiChatService);
//# sourceMappingURL=ai-chat.service.js.map