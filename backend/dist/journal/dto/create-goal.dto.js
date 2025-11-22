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
class CreateGoalDto {
}
exports.CreateGoalDto = CreateGoalDto;
__decorate([
    (0, class_validator_1.IsNotEmpty)({ message: 'O título da meta é obrigatório.' }),
    (0, class_validator_1.IsString)({ message: 'O título da meta deve ser uma string.' }),
    (0, class_validator_1.MaxLength)(100),
    __metadata("design:type", String)
], CreateGoalDto.prototype, "title", void 0);
__decorate([
    (0, class_validator_1.IsOptional)(),
    (0, class_validator_1.IsString)({ message: 'A descrição deve ser uma string.' }),
    (0, class_validator_1.MaxLength)(500),
    __metadata("design:type", String)
], CreateGoalDto.prototype, "description", void 0);
__decorate([
    (0, class_validator_1.IsNotEmpty)({ message: 'O valor alvo (targetAmount) é obrigatório.' }),
    (0, class_validator_1.IsNumber)({}, { message: 'O valor alvo deve ser um número.' }),
    (0, class_validator_1.Min)(0, { message: 'O valor alvo não pode ser negativo.' }),
    __metadata("design:type", Number)
], CreateGoalDto.prototype, "targetAmount", void 0);
__decorate([
    (0, class_validator_1.IsNotEmpty)({ message: 'A data alvo (targetDate) é obrigatória.' }),
    (0, class_validator_1.IsDateString)({}, { message: 'A data alvo deve ser uma string de data válida (ISO 8601).' }),
    __metadata("design:type", String)
], CreateGoalDto.prototype, "targetDate", void 0);
__decorate([
    (0, class_validator_1.IsOptional)(),
    (0, class_validator_1.IsNumber)({}, { message: 'O progresso atual deve ser um número.' }),
    (0, class_validator_1.Min)(0, { message: 'O progresso atual não pode ser negativo.' }),
    __metadata("design:type", Number)
], CreateGoalDto.prototype, "currentAmount", void 0);
//# sourceMappingURL=create-goal.dto.js.map