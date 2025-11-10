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
exports.UserService = void 0;
const common_1 = require("@nestjs/common");
const typeorm_1 = require("@nestjs/typeorm");
const typeorm_2 = require("typeorm");
const user_entity_1 = require("./entities/user.entity");
const plans_entity_1 = require("../plans/plans.entity");
let UserService = class UserService {
    constructor(userRepository, planRepository) {
        this.userRepository = userRepository;
        this.planRepository = planRepository;
    }
    async findByEmail(email) {
        return this.userRepository.findOne({ where: { email } });
    }
    async findById(id) {
        const user = await this.userRepository.findOne({
            where: { id },
            relations: ['currentPlan'],
        });
        if (!user) {
            throw new common_1.NotFoundException(`Usuário com ID ${id} não encontrado.`);
        }
        return user;
    }
    async create(registerDto) {
        const defaultPlan = await this.planRepository.findOneBy({ id: 'basic_monthly' });
        if (!defaultPlan) {
            throw new common_1.NotFoundException('Plano padrão não encontrado.');
        }
        const newUser = this.userRepository.create({
            email: registerDto.email,
            password: registerDto.password,
            name: registerDto.name,
            birthDate: registerDto.birthDate,
            gender: registerDto.gender,
            avatarName: 'Orion',
            mainConcern: null,
            currentPlan: defaultPlan,
        });
        return this.userRepository.save(newUser);
    }
    async updateUserPlan(userId, stripePriceId, subscriptionId) {
        const user = await this.findById(userId);
        if (!user) {
            throw new common_1.NotFoundException(`Usuário ID ${userId} não encontrado para atualização.`);
        }
        const newPlan = await this.planRepository.findOneBy({ stripePriceId });
        if (!newPlan) {
            throw new common_1.NotFoundException(`Plano com Stripe Price ID ${stripePriceId} não encontrado.`);
        }
        user.currentPlan = newPlan;
        user.stripeSubscriptionId = subscriptionId;
        return this.userRepository.save(user);
    }
};
exports.UserService = UserService;
exports.UserService = UserService = __decorate([
    (0, common_1.Injectable)(),
    __param(0, (0, typeorm_1.InjectRepository)(user_entity_1.User)),
    __param(1, (0, typeorm_1.InjectRepository)(plans_entity_1.Plan)),
    __metadata("design:paramtypes", [typeorm_2.Repository,
        typeorm_2.Repository])
], UserService);
//# sourceMappingURL=user.service.js.map