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
var _a;
Object.defineProperty(exports, "__esModule", { value: true });
exports.StrategiesController = void 0;
const common_1 = require("@nestjs/common");
const passport_1 = require("@nestjs/passport");
const strategies_service_1 = require("./strategies.service");
const create_strategy_dto_1 = require("./dto/create-strategy.dto");
const update_strategy_dto_1 = require("./dto/update-strategy.dto");
let StrategiesController = class StrategiesController {
    constructor(strategiesService) {
        this.strategiesService = strategiesService;
    }
    async create(req, createStrategyDto) {
        const user = { id: req.user.userId };
        return this.strategiesService.createStrategy(user, createStrategyDto);
    }
    async findAll(req) {
        return this.strategiesService.findAllUserStrategies(req.user.userId);
    }
    async findOne(id, req) {
        return this.strategiesService.findOneStrategy(id, req.user.userId);
    }
    async update(id, req, updateStrategyDto) {
        const strategy = await this.strategiesService.findOneStrategy(id, req.user.userId);
        return this.strategiesService.updateStrategy(strategy, updateStrategyDto);
    }
    async remove(id, req) {
        return this.strategiesService.removeStrategy(id, req.user.userId);
    }
};
exports.StrategiesController = StrategiesController;
__decorate([
    (0, common_1.Post)(),
    __param(0, (0, common_1.Request)()),
    __param(1, (0, common_1.Body)()),
    __metadata("design:type", Function),
    __metadata("design:paramtypes", [Object, create_strategy_dto_1.CreateStrategyDto]),
    __metadata("design:returntype", Promise)
], StrategiesController.prototype, "create", null);
__decorate([
    (0, common_1.Get)(),
    __param(0, (0, common_1.Request)()),
    __metadata("design:type", Function),
    __metadata("design:paramtypes", [Object]),
    __metadata("design:returntype", Promise)
], StrategiesController.prototype, "findAll", null);
__decorate([
    (0, common_1.Get)(':id'),
    __param(0, (0, common_1.Param)('id')),
    __param(1, (0, common_1.Request)()),
    __metadata("design:type", Function),
    __metadata("design:paramtypes", [String, Object]),
    __metadata("design:returntype", Promise)
], StrategiesController.prototype, "findOne", null);
__decorate([
    (0, common_1.Patch)(':id'),
    __param(0, (0, common_1.Param)('id')),
    __param(1, (0, common_1.Request)()),
    __param(2, (0, common_1.Body)()),
    __metadata("design:type", Function),
    __metadata("design:paramtypes", [String, Object, update_strategy_dto_1.UpdateStrategyDto]),
    __metadata("design:returntype", Promise)
], StrategiesController.prototype, "update", null);
__decorate([
    (0, common_1.Delete)(':id'),
    __param(0, (0, common_1.Param)('id')),
    __param(1, (0, common_1.Request)()),
    __metadata("design:type", Function),
    __metadata("design:paramtypes", [String, Object]),
    __metadata("design:returntype", Promise)
], StrategiesController.prototype, "remove", null);
exports.StrategiesController = StrategiesController = __decorate([
    (0, common_1.UseGuards)((0, passport_1.AuthGuard)('jwt')),
    (0, common_1.Controller)('strategies'),
    __metadata("design:paramtypes", [typeof (_a = typeof strategies_service_1.StrategiesService !== "undefined" && strategies_service_1.StrategiesService) === "function" ? _a : Object])
], StrategiesController);
//# sourceMappingURL=strategy.controller.js.map