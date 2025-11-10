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
exports.JournalService = void 0;
const common_1 = require("@nestjs/common");
const typeorm_1 = require("@nestjs/typeorm");
const typeorm_2 = require("typeorm");
const journal_entry_entity_1 = require("./entities/journal-entry.entity");
let JournalService = class JournalService {
    constructor(journalRepository) {
        this.journalRepository = journalRepository;
    }
    async createEntry(userId, createDto) {
        const newEntry = this.journalRepository.create({
            ...createDto,
            userId: userId,
        });
        return this.journalRepository.save(newEntry);
    }
    async findEntriesByUserId(userId) {
        return this.journalRepository.find({
            where: { userId: userId },
            order: {
                createdAt: 'DESC',
            },
        });
    }
    async deleteEntry(userId, entryId) {
        const result = await this.journalRepository.delete({
            id: entryId,
            userId: userId,
        });
        if (result.affected === 0) {
            throw new common_1.NotFoundException('Entrada do diário não encontrada ou não pertence ao usuário.');
        }
    }
};
exports.JournalService = JournalService;
exports.JournalService = JournalService = __decorate([
    (0, common_1.Injectable)(),
    __param(0, (0, typeorm_1.InjectRepository)(journal_entry_entity_1.JournalEntry)),
    __metadata("design:paramtypes", [typeorm_2.Repository])
], JournalService);
//# sourceMappingURL=journal.service.js.map