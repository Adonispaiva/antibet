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
exports.SubscriptionService = void 0;
const common_1 = require("@nestjs/common");
const typeorm_1 = require("@nestjs/typeorm");
const typeorm_2 = require("typeorm");
const subscription_entity_1 = require("./entities/subscription.entity");
const user_entity_1 = require("../user/entities/user.entity");
let SubscriptionService = class SubscriptionService {
    constructor(subscriptionRepository) {
        this.subscriptionRepository = subscriptionRepository;
    }
    async findByUserId(userId) {
        const subscription = await this.subscriptionRepository.findOne({
            where: { userId: userId },
        });
        if (!subscription) {
            throw new common_1.NotFoundException('Assinatura nao encontrada para este usuario.');
        }
        return subscription;
    }
    async createOrUpdateSubscription(user, planId, gatewaySubscriptionId, periodEnd, status, grantedRole) {
        let subscription = await this.subscriptionRepository.findOne({
            where: { userId: user.id },
        });
        if (!subscription) {
            subscription = this.subscriptionRepository.create({
                user: user,
                userId: user.id,
            });
        }
        subscription.paymentGatewaySubscriptionId = gatewaySubscriptionId;
        subscription.planId = planId;
        subscription.currentPeriodEnd = periodEnd;
        subscription.status = status;
        subscription.currentRole = grantedRole;
        return this.subscriptionRepository.save(subscription);
    }
    async updateSubscriptionStatus(gatewaySubscriptionId, newStatus, canceledAt = null) {
        const subscription = await this.subscriptionRepository.findOne({
            where: { paymentGatewaySubscriptionId: gatewaySubscriptionId },
        });
        if (!subscription) {
            throw new common_1.NotFoundException('Assinatura nao encontrada com este ID de gateway.');
        }
        subscription.status = newStatus;
        if (canceledAt) {
            subscription.canceledAt = canceledAt;
        }
        if (newStatus === subscription_entity_1.SubscriptionStatus.INACTIVE || newStatus === subscription_entity_1.SubscriptionStatus.CANCELED) {
            subscription.currentRole = user_entity_1.UserRole.BASIC;
        }
        return this.subscriptionRepository.save(subscription);
    }
};
exports.SubscriptionService = SubscriptionService;
exports.SubscriptionService = SubscriptionService = __decorate([
    (0, common_1.Injectable)(),
    __param(0, (0, typeorm_1.InjectRepository)(subscription_entity_1.Subscription)),
    __metadata("design:paramtypes", [typeorm_2.Repository])
], SubscriptionService);
//# sourceMappingURL=subscription.service.js.map