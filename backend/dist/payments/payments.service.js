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
exports.PaymentsService = void 0;
const common_1 = require("@nestjs/common");
const config_1 = require("@nestjs/config");
const user_service_1 = require("../user/user.service");
const stripe_1 = require("stripe");
let PaymentsService = class PaymentsService {
    constructor(configService, userService) {
        this.configService = configService;
        this.userService = userService;
        this.stripe = new stripe_1.default(this.configService.get('STRIPE_SECRET_KEY'), {
            apiVersion: '2023-08-16',
        });
    }
    async createCheckoutSession(user, planId) {
        const plan = await this.userService['planRepository'].findOneBy({ id: planId });
        if (!plan) {
            throw new common_1.NotFoundException(`Plano com ID ${planId} não encontrado.`);
        }
        const session = await this.stripe.checkout.sessions.create({
            payment_method_types: ['card'],
            mode: 'subscription',
            line_items: [
                {
                    price: plan.stripePriceId,
                    quantity: 1,
                },
            ],
            customer_email: user.email,
            client_reference_id: user.id,
            success_url: `${this.configService.get('CLIENT_URL')}/payment-success?session_id={CHECKOUT_SESSION_ID}`,
            cancel_url: `${this.configService.get('CLIENT_URL')}/plans`,
        });
        return { sessionId: session.id, url: session.url };
    }
    async handleWebhook(req) {
        const sig = req.headers['stripe-signature'];
        const endpointSecret = this.configService.get('STRIPE_WEBHOOK_SECRET');
        const rawBody = req.rawBody;
        if (!sig) {
            throw new common_1.BadRequestException('Cabeçalho "stripe-signature" ausente.');
        }
        if (!rawBody) {
            throw new common_1.BadRequestException('Corpo (raw body) ausente.');
        }
        let event;
        try {
            event = this.stripe.webhooks.constructEvent(rawBody, sig, endpointSecret);
        }
        catch (err) {
            throw new common_1.BadRequestException(`Webhook error: ${err.message}`);
        }
        switch (event.type) {
            case 'checkout.session.completed':
                const session = event.data.object;
                const userId = session.client_reference_id;
                const subscriptionId = session.subscription.toString();
                const priceItem = session.line_items.data[0].price;
                const stripePriceId = priceItem.id;
                await this.userService.updateUserPlan(userId, stripePriceId, subscriptionId);
                break;
            default:
                console.log(`Evento Stripe não tratado: ${event.type}`);
        }
        return { received: true };
    }
};
exports.PaymentsService = PaymentsService;
exports.PaymentsService = PaymentsService = __decorate([
    (0, common_1.Injectable)(),
    __metadata("design:paramtypes", [config_1.ConfigService,
        user_service_1.UserService])
], PaymentsService);
//# sourceMappingURL=payments.service.js.map