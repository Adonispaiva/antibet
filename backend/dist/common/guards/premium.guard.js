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
exports.PremiumGuard = void 0;
const common_1 = require("@nestjs/common");
const core_1 = require("@nestjs/core");
const is_premium_decorator_1 = require("../decorators/is-premium.decorator");
let PremiumGuard = class PremiumGuard {
    constructor(reflector) {
        this.reflector = reflector;
    }
    canActivate(context) {
        const isPremiumRequired = this.reflector.getAllAndOverride(is_premium_decorator_1.IS_PREMIUM_KEY, [
            context.getHandler(),
            context.getClass(),
        ]);
        if (!isPremiumRequired) {
            return true;
        }
        const request = context.switchToHttp().getRequest();
        const user = request.user;
        const isPremium = user.isPremiumActive;
        if (isPremium) {
            return true;
        }
        else {
            throw new common_1.ForbiddenException('Acesso negado. Esta funcionalidade é exclusiva para assinantes Premium.');
        }
    }
};
exports.PremiumGuard = PremiumGuard;
exports.PremiumGuard = PremiumGuard = __decorate([
    (0, common_1.Injectable)(),
    __metadata("design:paramtypes", [core_1.Reflector])
], PremiumGuard);
//# sourceMappingURL=premium.guard.js.map