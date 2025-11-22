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
exports.UpdateGoalDto = void 0;
const class_validator_1 = require("class-validator");
const mapped_types_1 = require("@nestjs/mapped-types");
const create_goal_dto_1 = require("./create-goal.dto");
const goal_entity_1 = require("../entities/goal.entity");
class UpdateGoalDto extends (0, mapped_types_1.PartialType)(create_goal_dto_1.CreateGoalDto) {
}
exports.UpdateGoalDto = UpdateGoalDto;
__decorate([
    (0, class_validator_1.IsString)({ message: 'O titulo da meta deve ser um texto.' }),
    (0, class_validator_1.IsOptional)(),
    __metadata("design:type", String)
], UpdateGoalDto.prototype, "title", void 0);
__decorate([
    (0, class_validator_1.IsString)({ message: 'A descricao deve ser um texto.' }),
    (0, class_validator_1.IsOptional)(),
    __metadata("design:type", String)
], UpdateGoalDto.prototype, "description", void 0);
__decorate([
    (0, class_validator_1.IsEnum)(goal_entity_1.GoalType, { message: 'Tipo de meta invalido.' }),
    (0, class_validator_1.IsOptional)(),
    __metadata("design:type", String)
], UpdateGoalDto.prototype, "type", void 0);
__decorate([
    (0, class_validator_1.IsNumber)({}, { message: 'O valor alvo deve ser um numero.' }),
    (0, class_validator_1.Min)(0, { message: 'O valor alvo nao pode ser negativo.' }),
    (0, class_validator_1.IsOptional)(),
    __metadata("design:type", Number)
], UpdateGoalDto.prototype, "targetValue", void 0);
__decorate([
    (0, class_validator_1.IsNumber)({}, { message: 'O valor atual deve ser um numero.' }),
    (0, class_validator_1.Min)(0, { message: 'O valor atual nao pode ser negativo.' }),
    (0, class_validator_1.IsOptional)(),
    __metadata("design:type", Number)
], UpdateGoalDto.prototype, "currentValue", void 0);
__decorate([
    (0, class_validator_1.IsDateString)({}, { message: 'A data alvo (targetDate) deve ser uma string de data valida.' }),
    (0, class_validator_1.IsOptional)(),
    __metadata("design:type", String)
], UpdateGoalDto.prototype, "targetDate", void 0);
__decorate([
    (0, class_validator_1.IsBoolean)({ message: 'isCompleted deve ser um booleano.' }),
    (0, class_validator_1.IsOptional)(),
    __metadata("design:type", Boolean)
], UpdateGoalDto.prototype, "isCompleted", void 0);
//# sourceMappingURL=update-goal.dto.js.map