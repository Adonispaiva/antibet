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
exports.PaymentsService = void 0;
const common_1 = require("@nestjs/common");
const typeorm_1 = require("@nestjs/typeorm");
const typeorm_2 = require("typeorm");
const stripe_1 = require("stripe");
const app_config_service_1 = require("../config/app-config.service");
const plans_service_1 = require("../plans/plans.service");
const subscription_service_1 = require("../subscription/subscription.service");
const user_service_1 = require("../user/user.service");
const payment_log_entity_1 = require("./entities/payment-log.entity");
let PaymentsService = class PaymentsService {
    constructor(paymentLogRepository, configService, plansService, subscriptionService, userService) {
        this.paymentLogRepository = paymentLogRepository;
        this.configService = configService;
        this.plansService = plansService;
        this.subscriptionService = subscriptionService;
        this.userService = userService;
        this.stripe = new stripe_1.default(this.configService.STRIPE_SECRET_KEY, {
            apiVersion: '2024-04-10',
        });
    }
    async createCheckoutSession(userId, planId) {
        const plan = await this.plansService.findOne(planId);
        if (!plan || !plan.paymentGatewayId) {
            throw new common_1.BadRequestException('Plano nao encontrado ou nao configurado para pagamento.');
        }
        const user = await this.userService.findOne(userId);
        if (!user) {
            throw new common_1.BadRequestException('Usuario nao encontrado.');
        }
        const stripeCustomerId = null;
        const session = await this.stripe.checkout.sessions.create({
            payment_method_types: ['card'],
            mode: 'subscription',
            line_items: [
                {
                    price: plan.paymentGatewayId,
                    quantity: 1,
                },
            ],
            customer: stripeCustomerId,
            customer_email: !stripeCustomerId ? user.email : undefined,
            success_url: `${this.configService.CLIENT_URL}/payment-success?session_id={CHECKOUT_SESSION_ID}`,
            cancel_url: `${this.configService.CLIENT_URL}/payment-canceled`,
            metadata: {
                internalUserId: userId,
                internalPlanId: planId,
            },
        });
        if (!session.url) {
            throw new common_1.BadRequestException('Nao foi possivel criar a sessao de checkout.');
        }
        return { url: session.url };
    }
    async handleStripeWebhook(signature, rawBody) {
        const webhookSecret = this.configService.STRIPE_WEBHOOK_SECRET;
        let event;
        try {
            event = this.stripe.webhooks.constructEvent(rawBody, signature, webhookSecret);
        }
        catch (err) {
            throw new common_1.BadRequestException(`Webhook Error: ${err.message}`);
        }
        switch (event.type) {
            case 'checkout.session.completed':
                const session = event.data.object;
                await this.fulfillCheckoutSession(session);
                break;
            default:
                console.log(`Unhandled event type ${event.type}`);
        }
        return { received: true };
    }
    async fulfillCheckoutSession(session) {
        const userId = session.metadata.internalUserId;
        const planId = session.metadata.internalPlanId;
        const gatewaySubscriptionId = session.subscription;
        const user = await this.userService.findOne(userId);
        const plan = await this.plansService.findOne(planId);
        if (!user || !plan) {
            throw new common_1.BadRequestException('Usuario ou Plano nao encontrado durante o webhook.');
        }
        const periodEnd = new Date(Date.now() + 30 * 24 * 60 * 60 * 1000);
        await this.subscriptionService.createOrUpdateSubscription(user, plan.id, gatewaySubscriptionId, periodEnd, 'active', plan.grantedRole);
        await this.userService.updateUserRole(userId, plan.grantedRole);
    }
    async getSubscriptionStatus(userId) {
        return this.subscriptionService.findByUserId(userId);
    }
};
exports.PaymentsService = PaymentsService;
exports.PaymentsService = PaymentsService = __decorate([
    (0, common_1.Injectable)(),
    __param(0, (0, typeorm_1.InjectRepository)(payment_log_entity_1.PaymentLog)),
    __metadata("design:paramtypes", [typeorm_2.Repository,
        app_config_service_1.AppConfigService,
        plans_service_1.PlansService,
        subscription_service_1.SubscriptionService,
        user_service_1.UserService])
], PaymentsService);
//# sourceMappingURL=payments.service.js.map