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
exports.GetJournalEntriesFilterDto = void 0;
const class_validator_1 = require("class-validator");
class GetJournalEntriesFilterDto {
}
exports.GetJournalEntriesFilterDto = GetJournalEntriesFilterDto;
__decorate([
    (0, class_validator_1.IsOptional)(),
    (0, class_validator_1.IsString)({ message: 'O filtro de estratégia deve ser uma string.' }),
    __metadata("design:type", String)
], GetJournalEntriesFilterDto.prototype, "strategyName", void 0);
__decorate([
    (0, class_validator_1.IsOptional)(),
    (0, class_validator_1.IsDateString)({}, { message: 'A data de início deve ser uma string de data válida (ISO 8601).' }),
    __metadata("design:type", String)
], GetJournalEntriesFilterDto.prototype, "startDate", void 0);
__decorate([
    (0, class_validator_1.IsOptional)(),
    (0, class_validator_1.IsDateString)({}, { message: 'A data de fim deve ser uma string de data válida (ISO 8601).' }),
    __metadata("design:type", String)
], GetJournalEntriesFilterDto.prototype, "endDate", void 0);
__decorate([
    (0, class_validator_1.IsOptional)(),
    (0, class_validator_1.IsIn)(['Win', 'Loss', 'Even'], { message: "O resultado deve ser 'Win', 'Loss' ou 'Even'." }),
    __metadata("design:type", String)
], GetJournalEntriesFilterDto.prototype, "resultType", void 0);
//# sourceMappingURL=get-journal-entries-filter.dto.js.map