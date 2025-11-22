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
exports.CreateGoalDto = void 0;
const class_validator_1 = require("class-validator");
const goal_entity_1 = require("../entities/goal.entity");
class CreateGoalDto {
}
exports.CreateGoalDto = CreateGoalDto;
__decorate([
    (0, class_validator_1.IsString)({ message: 'O titulo da meta deve ser um texto.' }),
    (0, class_validator_1.IsNotEmpty)({ message: 'O titulo e obrigatorio.' }),
    __metadata("design:type", String)
], CreateGoalDto.prototype, "title", void 0);
__decorate([
    (0, class_validator_1.IsString)({ message: 'A descricao deve ser um texto.' }),
    (0, class_validator_1.IsOptional)(),
    __metadata("design:type", String)
], CreateGoalDto.prototype, "description", void 0);
__decorate([
    (0, class_validator_1.IsEnum)(goal_entity_1.GoalType, { message: 'Tipo de meta invalido. Use FINANCIAL, EMOTIONAL, TECHNICAL ou OTHER.' }),
    (0, class_validator_1.IsOptional)(),
    __metadata("design:type", String)
], CreateGoalDto.prototype, "type", void 0);
__decorate([
    (0, class_validator_1.IsNumber)({}, { message: 'O valor alvo deve ser um numero.' }),
    (0, class_validator_1.Min)(0, { message: 'O valor alvo nao pode ser negativo.' }),
    (0, class_validator_1.IsNotEmpty)({ message: 'O valor alvo (targetValue) e obrigatorio.' }),
    __metadata("design:type", Number)
], CreateGoalDto.prototype, "targetValue", void 0);
__decorate([
    (0, class_validator_1.IsDateString)({}, { message: 'A data alvo (targetDate) deve ser uma string de data valida.' }),
    (0, class_validator_1.IsOptional)(),
    __metadata("design:type", String)
], CreateGoalDto.prototype, "targetDate", void 0);
//# sourceMappingURL=create-goal.dto.js.map