"use strict";
var __decorate = (this && this.__decorate) || function (decorators, target, key, desc) {
    var c = arguments.length, r = c < 3 ? target : desc === null ? desc = Object.getOwnPropertyDescriptor(target, key) : desc, d;
    if (typeof Reflect === "object" && typeof Reflect.decorate === "function") r = Reflect.decorate(decorators, target, key, desc);
    else for (var i = decorators.length - 1; i >= 0; i--) if (d = decorators[i]) r = (c < 3 ? d(r) : c > 3 ? d(target, key, r) : d(target, key)) || r;
    return c > 3 && r && Object.defineProperty(target, key, r), r;
};
Object.defineProperty(exports, "__esModule", { value: true });
exports.AuthModule = void 0;
const common_1 = require("@nestjs/common");
const passport_1 = require("@nestjs/passport");
const jwt_1 = require("@nestjs/jwt");
const user_module_1 = require("../user/user.module");
const config_module_1 = require("../config/config.module");
const app_config_service_1 = require("../config/app-config.service");
const auth_service_1 = require("./auth.service");
const local_strategy_1 = require("./strategies/local.strategy");
const jwt_strategy_1 = require("./strategies/jwt.strategy");
let AuthModule = class AuthModule {
};
exports.AuthModule = AuthModule;
exports.AuthModule = AuthModule = __decorate([
    (0, common_1.Module)({
        imports: [
            user_module_1.UserModule,
            passport_1.PassportModule.register({ defaultStrategy: 'jwt' }),
            config_module_1.AppConfigurationModule,
            jwt_1.JwtModule.registerAsync({
                imports: [config_module_1.AppConfigurationModule],
                inject: [app_config_service_1.AppConfigService],
                useFactory: async (configService) => ({
                    secret: configService.JWT_SECRET,
                    signOptions: {
                        expiresIn: configService.JWT_EXPIRATION_TIME,
                    },
                }),
            }),
        ],
        controllers: [],
        providers: [
            auth_service_1.AuthService,
            local_strategy_1.LocalStrategy,
            jwt_strategy_1.JwtStrategy,
        ],
        exports: [
            jwt_1.JwtModule,
            passport_1.PassportModule,
            auth_service_1.AuthService,
        ],
    })
], AuthModule);
//# sourceMappingURL=auth.module.js.map