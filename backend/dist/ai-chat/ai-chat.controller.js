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
var __param = (this && this.__param) || function (paramIndex, decorator) {
    return function (target, key) { decorator(target, key, paramIndex); }
};
Object.defineProperty(exports, "__esModule", { value: true });
exports.AiChatController = void 0;
const common_1 = require("@nestjs/common");
const ai_chat_service_1 = require("./ai-chat.service");
const ai_chat_message_dto_1 = require("./dto/ai-chat-message.dto");
const jwt_auth_guard_1 = require("../auth/jwt-auth.guard");
let AiChatController = class AiChatController {
    constructor(aiChatService) {
        this.aiChatService = aiChatService;
    }
    async sendMessage(dto, req) {
        const userId = req.user.userId;
        return this.aiChatService.processMessage(userId, dto.message);
    }
};
exports.AiChatController = AiChatController;
__decorate([
    (0, common_1.Post)('message'),
    __param(0, (0, common_1.Body)()),
    __param(1, (0, common_1.Request)()),
    __metadata("design:type", Function),
    __metadata("design:paramtypes", [ai_chat_message_dto_1.AiChatMessageDto, Object]),
    __metadata("design:returntype", Promise)
], AiChatController.prototype, "sendMessage", null);
exports.AiChatController = AiChatController = __decorate([
    (0, common_1.Controller)('ai-chat'),
    (0, common_1.UseGuards)(jwt_auth_guard_1.JwtAuthGuard),
    (0, common_1.UsePipes)(new common_1.ValidationPipe()),
    __metadata("design:paramtypes", [ai_chat_service_1.AiChatService])
], AiChatController);
//# sourceMappingURL=ai-chat.controller.js.map