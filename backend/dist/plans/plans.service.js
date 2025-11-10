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
exports.PlansService = void 0;
const common_1 = require("@nestjs/common");
const typeorm_1 = require("@nestjs/typeorm");
const plan_entity_1 = require("./entities/plan.entity");
const typeorm_2 = require("typeorm");
const FREE_PLAN_ID = 'f1e1a1a1-1a1a-1a1a-1a1a-1a1a1a1a1a1a';
let PlansService = class PlansService {
    constructor(planRepository) {
        this.planRepository = planRepository;
    }
    async findAll() {
        return this.planRepository.find({
            order: {
                price: 'ASC',
            },
        });
    }
    async findPlanByUserId(userId) {
        const freePlan = await this.planRepository.findOne({
            where: { id: FREE_PLAN_ID },
        });
        if (!freePlan) {
            throw new common_1.InternalServerErrorException('Plano gratuito padrão não encontrado no banco de dados.');
        }
        return freePlan;
    }
};
exports.PlansService = PlansService;
exports.PlansService = PlansService = __decorate([
    (0, common_1.Injectable)(),
    __param(0, (0, typeorm_1.InjectRepository)(plan_entity_1.Plan)),
    __metadata("design:paramtypes", [typeorm_2.Repository])
], PlansService);
//# sourceMappingURL=plans.service.js.map