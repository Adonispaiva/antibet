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
var _a, _b, _c;
Object.defineProperty(exports, "__esModule", { value: true });
exports.PaymentsController = void 0;
const common_1 = require("@nestjs/common");
const payments_service_1 = require("./payments.service");
const create_checkout_session_dto_1 = require("./dto/create-checkout-session.dto");
const jwt_auth_guard_1 = require("@/auth/guards/jwt-auth.guard");
const authenticated_request_interface_1 = require("@/auth/interfaces/authenticated-request.interface");
let PaymentsController = class PaymentsController {
    constructor(paymentsService) {
        this.paymentsService = paymentsService;
    }
    async createCheckoutSession(req, createCheckoutSessionDto) {
        return this.paymentsService.createCheckoutSession(req.user, createCheckoutSessionDto.planId);
    }
    async handleWebhook(req) {
        if (!req.rawBody) {
            throw new common_1.BadRequestException('Corpo (raw body) ausente na requisição.');
        }
        return this.paymentsService.handleWebhook(req.rawBody);
    }
};
exports.PaymentsController = PaymentsController;
__decorate([
    (0, common_1.Post)('create-checkout-session'),
    (0, common_1.UseGuards)(jwt_auth_guard_1.JwtAuthGuard),
    __param(0, (0, common_1.Req)()),
    __param(1, (0, common_1.Body)()),
    __metadata("design:type", Function),
    __metadata("design:paramtypes", [typeof (_a = typeof authenticated_request_interface_1.AuthenticatedRequest !== "undefined" && authenticated_request_interface_1.AuthenticatedRequest) === "function" ? _a : Object, typeof (_b = typeof create_checkout_session_dto_1.CreateCheckoutSessionDto !== "undefined" && create_checkout_session_dto_1.CreateCheckoutSessionDto) === "function" ? _b : Object]),
    __metadata("design:returntype", Promise)
], PaymentsController.prototype, "createCheckoutSession", null);
__decorate([
    (0, common_1.Post)('webhook'),
    __param(0, (0, common_1.Req)()),
    __metadata("design:type", Function),
    __metadata("design:paramtypes", [typeof (_c = typeof authenticated_request_interface_1.AuthenticatedRequest !== "undefined" && authenticated_request_interface_1.AuthenticatedRequest) === "function" ? _c : Object]),
    __metadata("design:returntype", Promise)
], PaymentsController.prototype, "handleWebhook", null);
exports.PaymentsController = PaymentsController = __decorate([
    (0, common_1.Controller)('payments'),
    __metadata("design:paramtypes", [payments_service_1.PaymentsService])
], PaymentsController);
//# sourceMappingURL=payments.controller.js.map