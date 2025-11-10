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
Object.defineProperty(exports, "__esModule", { value: true });
exports.AiGatewayService = void 0;
const common_1 = require("@nestjs/common");
const config_1 = require("@nestjs/config");
const openai_1 = require("openai");
const ia_models_config_1 = require("./ia-models.config");
let AiGatewayService = class AiGatewayService {
    constructor(configService) {
        this.configService = configService;
        const apiKey = this.configService.get('GPT_API_KEY');
        if (!apiKey) {
            throw new common_1.InternalServerErrorException('Chave da API GPT não configurada.');
        }
        this.openai = new openai_1.default({ apiKey });
    }
    getModel(modelName) {
        const model = ia_models_config_1.IA_MODELS[modelName];
        if (!model) {
            throw new common_1.InternalServerErrorException(`Modelo de IA '${modelName}' não encontrado.`);
        }
        return model;
    }
    async generateResponse(modelName, systemPrompt, userPrompt) {
        const modelConfig = this.getModel(modelName);
        try {
            const completion = await this.openai.chat.completions.create({
                model: modelConfig.apiName,
                temperature: 0.7,
                messages: [
                    {
                        role: 'system',
                        content: systemPrompt,
                    },
                    {
                        role: 'user',
                        content: userPrompt,
                    },
                ],
            });
            const response = completion.choices[0]?.message?.content;
            if (!response) {
                throw new common_1.InternalServerErrorException('Resposta da IA veio vazia.');
            }
            return response;
        }
        catch (error) {
            throw new common_1.InternalServerErrorException(`Falha ao comunicar com o Gateway de IA: ${error.message}`);
        }
    }
};
exports.AiGatewayService = AiGatewayService;
exports.AiGatewayService = AiGatewayService = __decorate([
    (0, common_1.Injectable)(),
    __metadata("design:paramtypes", [config_1.ConfigService])
], AiGatewayService);
//# sourceMappingURL=ai-gateway.service.js.map