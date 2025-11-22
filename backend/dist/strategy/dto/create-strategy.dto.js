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
exports.CreateStrategyDto = void 0;
const class_validator_1 = require("class-validator");
const strategy_entity_1 = require("../entities/strategy.entity");
class CreateStrategyDto {
}
exports.CreateStrategyDto = CreateStrategyDto;
__decorate([
    (0, class_validator_1.IsString)({ message: 'O nome da estrategia deve ser um texto.' }),
    (0, class_validator_1.IsNotEmpty)({ message: 'O nome e obrigatorio.' }),
    __metadata("design:type", String)
], CreateStrategyDto.prototype, "name", void 0);
__decorate([
    (0, class_validator_1.IsString)({ message: 'A descricao deve ser um texto.' }),
    (0, class_validator_1.IsOptional)(),
    __metadata("design:type", String)
], CreateStrategyDto.prototype, "description", void 0);
__decorate([
    (0, class_validator_1.IsEnum)(strategy_entity_1.StrategyFocus, { message: 'Foco da estrategia invalido. Use SCALPING, SWING ou POSITION.' }),
    (0, class_validator_1.IsOptional)(),
    __metadata("design:type", String)
], CreateStrategyDto.prototype, "focus", void 0);
__decorate([
    (0, class_validator_1.IsNumber)({}, { message: 'O risco por trade deve ser um numero.' }),
    (0, class_validator_1.Min)(0, { message: 'O risco por trade nao pode ser negativo.' }),
    (0, class_validator_1.IsOptional)(),
    __metadata("design:type", Number)
], CreateStrategyDto.prototype, "riskPerTrade", void 0);
__decorate([
    (0, class_validator_1.IsNumber)({}, { message: 'O targetWinRate deve ser um numero.' }),
    (0, class_validator_1.Min)(0, { message: 'O targetWinRate nao pode ser negativo.' }),
    (0, class_validator_1.IsOptional)(),
    __metadata("design:type", Number)
], CreateStrategyDto.prototype, "targetWinRate", void 0);
//# sourceMappingURL=create-strategy.dto.js.map