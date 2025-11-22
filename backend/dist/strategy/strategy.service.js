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
exports.StrategiesService = void 0;
const common_1 = require("@nestjs/common");
const typeorm_1 = require("@nestjs/typeorm");
const typeorm_2 = require("typeorm");
const strategy_entity_1 = require("./entities/strategy.entity");
let StrategiesService = class StrategiesService {
    constructor(strategyRepository) {
        this.strategyRepository = strategyRepository;
    }
    async createStrategy(user, createStrategyDto) {
        const newStrategy = this.strategyRepository.create({
            ...createStrategyDto,
            user: user,
            userId: user.id,
        });
        return this.strategyRepository.save(newStrategy);
    }
    async findAllUserStrategies(userId) {
        return this.strategyRepository.find({
            where: { userId: userId, isActive: true },
            order: { createdAt: 'DESC' },
        });
    }
    async findOneStrategy(id, userId) {
        const strategy = await this.strategyRepository.findOne({
            where: { id: id, userId: userId },
        });
        if (!strategy) {
            throw new common_1.NotFoundException('Estrategia nao encontrada ou nao pertence a este usuario.');
        }
        return strategy;
    }
    async updateStrategy(strategy, updateStrategyDto) {
        const updatedStrategy = this.strategyRepository.merge(strategy, updateStrategyDto);
        return this.strategyRepository.save(updatedStrategy);
    }
    async removeStrategy(id, userId) {
        const strategy = await this.findOneStrategy(id, userId);
        strategy.isActive = false;
        await this.strategyRepository.save(strategy);
    }
};
exports.StrategiesService = StrategiesService;
exports.StrategiesService = StrategiesService = __decorate([
    (0, common_1.Injectable)(),
    __param(0, (0, typeorm_1.InjectRepository)(strategy_entity_1.Strategy)),
    __metadata("design:paramtypes", [typeorm_2.Repository])
], StrategiesService);
//# sourceMappingURL=strategy.service.js.map