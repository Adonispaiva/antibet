"use strict";
var __decorate = (this && this.__decorate) || function (decorators, target, key, desc) {
    var c = arguments.length, r = c < 3 ? target : desc === null ? desc = Object.getOwnPropertyDescriptor(target, key) : desc, d;
    if (typeof Reflect === "object" && typeof Reflect.decorate === "function") r = Reflect.decorate(decorators, target, key, desc);
    else for (var i = decorators.length - 1; i >= 0; i--) if (d = decorators[i]) r = (c < 3 ? d(r) : c > 3 ? d(target, key, r) : d(target, key)) || r;
    return c > 3 && r && Object.defineProperty(target, key, r), r;
};
Object.defineProperty(exports, "__esModule", { value: true });
exports.AiChatModule = void 0;
const common_1 = require("@nestjs/common");
const ai_chat_controller_1 = require("./ai-chat.controller");
const ai_chat_service_1 = require("./ai-chat.service");
const ai_gateway_service_1 = require("./ai-gateway.service");
const ai_log_module_1 = require("../ai-log/ai-log.module");
const plans_module_1 = require("../plans/plans.module");
const auth_module_1 = require("../auth/auth.module");
const user_module_1 = require("../user/user.module");
let AiChatModule = class AiChatModule {
};
exports.AiChatModule = AiChatModule;
exports.AiChatModule = AiChatModule = __decorate([
    (0, common_1.Module)({
        imports: [
            auth_module_1.AuthModule,
            plans_module_1.PlansModule,
            ai_log_module_1.AiLogModule,
            user_module_1.UserModule,
        ],
        controllers: [ai_chat_controller_1.AiChatController],
        providers: [ai_chat_service_1.AiChatService, ai_gateway_service_1.AiGatewayService],
    })
], AiChatModule);
//# sourceMappingURL=ai-chat.module.js.map