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
exports.AppConfigService = void 0;
const common_1 = require("@nestjs/common");
const config_1 = require("@nestjs/config");
let AppConfigService = class AppConfigService {
    constructor(configService) {
        this.configService = configService;
    }
    get NODE_ENV() {
        return this.configService.get('NODE_ENV', 'development');
    }
    get PORT() {
        return this.configService.get('PORT', 3000);
    }
    get CLIENT_URL() {
        return this.configService.get('CLIENT_URL', 'http://localhost:3001');
    }
    get DB_HOST() {
        return this.configService.get('DB_HOST', 'localhost');
    }
    get DB_PORT() {
        return this.configService.get('DB_PORT', 5432);
    }
    get DB_USERNAME() {
        return this.configService.get('DB_USERNAME', 'adonisp');
    }
    get DB_PASSWORD() {
        return this.configService.get('DB_PASSWORD', '');
    }
    get DB_DATABASE() {
        return this.configService.get('DB_DATABASE', 'antibet_db');
    }
    get JWT_SECRET() {
        const secret = this.configService.get('JWT_SECRET');
        if (!secret) {
            throw new Error('JWT_SECRET nao esta configurado no .env!');
        }
        return secret;
    }
    get JWT_EXPIRATION_TIME() {
        return this.configService.get('JWT_EXPIRATION_TIME', '3600s');
    }
    get STRIPE_SECRET_KEY() {
        const secret = this.configService.get('STRIPE_SECRET_KEY');
        if (!secret) {
            throw new Error('STRIPE_SECRET_KEY nao esta configurado no .env!');
        }
        return secret;
    }
    get STRIPE_WEBHOOK_SECRET() {
        const secret = this.configService.get('STRIPE_WEBHOOK_SECRET');
        if (!secret) {
            throw new Error('STRIPE_WEBHOOK_SECRET nao esta configurado no .env!');
        }
        return secret;
    }
};
exports.AppConfigService = AppConfigService;
exports.AppConfigService = AppConfigService = __decorate([
    (0, common_1.Injectable)(),
    __metadata("design:paramtypes", [config_1.ConfigService])
], AppConfigService);
//# sourceMappingURL=app-config.service.js.map