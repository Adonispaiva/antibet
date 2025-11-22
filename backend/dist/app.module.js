"use strict";
var __decorate = (this && this.__decorate) || function (decorators, target, key, desc) {
    var c = arguments.length, r = c < 3 ? target : desc === null ? desc = Object.getOwnPropertyDescriptor(target, key) : desc, d;
    if (typeof Reflect === "object" && typeof Reflect.decorate === "function") r = Reflect.decorate(decorators, target, key, desc);
    else for (var i = decorators.length - 1; i >= 0; i--) if (d = decorators[i]) r = (c < 3 ? d(r) : c > 3 ? d(target, key, r) : d(target, key)) || r;
    return c > 3 && r && Object.defineProperty(target, key, r), r;
};
Object.defineProperty(exports, "__esModule", { value: true });
exports.AppModule = void 0;
const common_1 = require("@nestjs/common");
const typeorm_1 = require("@nestjs/typeorm");
const app_controller_1 = require("./app.controller");
const app_service_1 = require("./app.service");
const config_module_1 = require("./config/config.module");
const app_config_service_1 = require("./config/app-config.service");
const auth_module_1 = require("./auth/auth.module");
const user_module_1 = require("./user/user.module");
const plans_module_1 = require("./plans/plans.module");
const payments_module_1 = require("./payments/payments.module");
const journal_module_1 = require("./journal/journal.module");
const strategy_module_1 = require("./strategy/strategy.module");
const goals_module_1 = require("./goals/goals.module");
const notification_module_1 = require("./notification/notification.module");
const ai_chat_module_1 = require("./ai-chat/ai-chat.module");
const subscription_module_1 = require("./subscription/subscription.module");
let AppModule = class AppModule {
};
exports.AppModule = AppModule;
exports.AppModule = AppModule = __decorate([
    (0, common_1.Module)({
        imports: [
            config_module_1.AppConfigurationModule,
            typeorm_1.TypeOrmModule.forRootAsync({
                imports: [config_module_1.AppConfigurationModule],
                inject: [app_config_service_1.AppConfigService],
                useFactory: (appConfigService) => ({
                    type: 'postgres',
                    host: appConfigService.DB_HOST,
                    port: appConfigService.DB_PORT,
                    username: appConfigService.DB_USERNAME,
                    password: appConfigService.DB_PASSWORD,
                    database: appConfigService.DB_DATABASE,
                    entities: [__dirname + '/**/*.entity{.ts,.js}'],
                    synchronize: true,
                }),
            }),
            user_module_1.UserModule,
            auth_module_1.AuthModule,
            subscription_module_1.SubscriptionModule,
            plans_module_1.PlansModule,
            payments_module_1.PaymentsModule,
            journal_module_1.JournalModule,
            strategy_module_1.StrategyModule,
            goals_module_1.GoalsModule,
            notification_module_1.NotificationModule,
            ai_chat_module_1.AiChatModule,
        ],
        controllers: [app_controller_1.AppController],
        providers: [app_service_1.AppService],
    })
], AppModule);
//# sourceMappingURL=app.module.js.map