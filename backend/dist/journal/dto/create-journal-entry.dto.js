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
exports.CreateJournalEntryDto = void 0;
const class_validator_1 = require("class-validator");
class CreateJournalEntryDto {
}
exports.CreateJournalEntryDto = CreateJournalEntryDto;
__decorate([
    (0, class_validator_1.IsString)({ message: 'O conteúdo do diário deve ser um texto.' }),
    (0, class_validator_1.IsNotEmpty)({ message: 'O conteúdo do diário (content) e obrigatorio.' }),
    __metadata("design:type", String)
], CreateJournalEntryDto.prototype, "content", void 0);
__decorate([
    (0, class_validator_1.IsInt)({ message: 'O valor de P&L deve ser um numero inteiro em centavos.' }),
    (0, class_validator_1.IsOptional)(),
    __metadata("design:type", Number)
], CreateJournalEntryDto.prototype, "pnlValue", void 0);
__decorate([
    (0, class_validator_1.IsArray)({ message: 'As tags devem ser fornecidas como um array de strings.' }),
    (0, class_validator_1.IsString)({ each: true, message: 'Cada tag deve ser uma string.' }),
    (0, class_validator_1.IsOptional)(),
    __metadata("design:type", Array)
], CreateJournalEntryDto.prototype, "tags", void 0);
__decorate([
    (0, class_validator_1.IsDateString)({}, { message: 'A data da operacao (tradeDate) deve ser uma string de data valida.' }),
    (0, class_validator_1.IsOptional)(),
    __metadata("design:type", String)
], CreateJournalEntryDto.prototype, "tradeDate", void 0);
//# sourceMappingURL=create-journal-entry.dto.js.map