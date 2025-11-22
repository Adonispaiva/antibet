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
exports.JournalController = void 0;
const common_1 = require("@nestjs/common");
const passport_1 = require("@nestjs/passport");
const journal_service_1 = require("./journal.service");
const create_journal_entry_dto_1 = require("./dto/create-journal-entry.dto");
const update_journal_entry_dto_1 = require("./dto/update-journal-entry.dto");
let JournalController = class JournalController {
    constructor(journalService) {
        this.journalService = journalService;
    }
    async create(req, createJournalEntryDto) {
        const user = { id: req.user.userId };
        return this.journalService.createEntry(user, createJournalEntryDto);
    }
    async findAll(req) {
        return this.journalService.findAllEntries(req.user.userId);
    }
    async findOne(id, req) {
        const entry = await this.journalService.findOneEntry(id, req.user.userId);
        if (!entry) {
            throw new common_1.NotFoundException('Entrada do diario nao encontrada ou nao pertence a este usuario.');
        }
        return entry;
    }
    async update(id, req, updateJournalEntryDto) {
        const entry = await this.journalService.findOneEntry(id, req.user.userId);
        if (!entry) {
            throw new common_1.NotFoundException('Entrada do diario nao encontrada.');
        }
        return this.journalService.updateEntry(entry, updateJournalEntryDto);
    }
    async remove(id, req) {
        const entry = await this.journalService.findOneEntry(id, req.user.userId);
        if (!entry) {
            throw new common_1.NotFoundException('Entrada do diario nao encontrada.');
        }
        return this.journalService.removeEntry(id, req.user.userId);
    }
};
exports.JournalController = JournalController;
__decorate([
    (0, common_1.Post)(),
    __param(0, (0, common_1.Request)()),
    __param(1, (0, common_1.Body)()),
    __metadata("design:type", Function),
    __metadata("design:paramtypes", [Object, create_journal_entry_dto_1.CreateJournalEntryDto]),
    __metadata("design:returntype", Promise)
], JournalController.prototype, "create", null);
__decorate([
    (0, common_1.Get)(),
    __param(0, (0, common_1.Request)()),
    __metadata("design:type", Function),
    __metadata("design:paramtypes", [Object]),
    __metadata("design:returntype", Promise)
], JournalController.prototype, "findAll", null);
__decorate([
    (0, common_1.Get)(':id'),
    __param(0, (0, common_1.Param)('id')),
    __param(1, (0, common_1.Request)()),
    __metadata("design:type", Function),
    __metadata("design:paramtypes", [String, Object]),
    __metadata("design:returntype", Promise)
], JournalController.prototype, "findOne", null);
__decorate([
    (0, common_1.Patch)(':id'),
    __param(0, (0, common_1.Param)('id')),
    __param(1, (0, common_1.Request)()),
    __param(2, (0, common_1.Body)()),
    __metadata("design:type", Function),
    __metadata("design:paramtypes", [String, Object, update_journal_entry_dto_1.UpdateJournalEntryDto]),
    __metadata("design:returntype", Promise)
], JournalController.prototype, "update", null);
__decorate([
    (0, common_1.Delete)(':id'),
    __param(0, (0, common_1.Param)('id')),
    __param(1, (0, common_1.Request)()),
    __metadata("design:type", Function),
    __metadata("design:paramtypes", [String, Object]),
    __metadata("design:returntype", Promise)
], JournalController.prototype, "remove", null);
exports.JournalController = JournalController = __decorate([
    (0, common_1.UseGuards)((0, passport_1.AuthGuard)('jwt')),
    (0, common_1.Controller)('journal'),
    __metadata("design:paramtypes", [journal_service_1.JournalService])
], JournalController);
//# sourceMappingURL=journal.controller.js.map