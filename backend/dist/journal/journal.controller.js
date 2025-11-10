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
var _a, _b, _c;
Object.defineProperty(exports, "__esModule", { value: true });
exports.JournalController = void 0;
const common_1 = require("@nestjs/common");
const jwt_auth_guard_1 = require("../auth/guards/jwt-auth.guard");
const authenticated_request_interface_1 = require("../auth/interfaces/authenticated-request.interface");
const journal_service_1 = require("./journal.service");
const create_journal_entry_dto_1 = require("./dto/create-journal-entry.dto");
let JournalController = class JournalController {
    constructor(journalService) {
        this.journalService = journalService;
    }
    create(req, createDto) {
        const userId = req.user.userId;
        return this.journalService.createEntry(userId, createDto);
    }
    findAll(req) {
        const userId = req.user.userId;
        return this.journalService.findEntriesByUserId(userId);
    }
    remove(req, entryId) {
        const userId = req.user.userId;
        return this.journalService.deleteEntry(userId, entryId);
    }
};
exports.JournalController = JournalController;
__decorate([
    (0, common_1.Post)(),
    (0, common_1.HttpCode)(common_1.HttpStatus.CREATED),
    __param(0, (0, common_1.Req)()),
    __param(1, (0, common_1.Body)()),
    __metadata("design:type", Function),
    __metadata("design:paramtypes", [typeof (_a = typeof authenticated_request_interface_1.AuthenticatedRequest !== "undefined" && authenticated_request_interface_1.AuthenticatedRequest) === "function" ? _a : Object, create_journal_entry_dto_1.CreateJournalEntryDto]),
    __metadata("design:returntype", void 0)
], JournalController.prototype, "create", null);
__decorate([
    (0, common_1.Get)(),
    __param(0, (0, common_1.Req)()),
    __metadata("design:type", Function),
    __metadata("design:paramtypes", [typeof (_b = typeof authenticated_request_interface_1.AuthenticatedRequest !== "undefined" && authenticated_request_interface_1.AuthenticatedRequest) === "function" ? _b : Object]),
    __metadata("design:returntype", void 0)
], JournalController.prototype, "findAll", null);
__decorate([
    (0, common_1.Delete)(':id'),
    (0, common_1.HttpCode)(common_1.HttpStatus.NO_CONTENT),
    __param(0, (0, common_1.Req)()),
    __param(1, (0, common_1.Param)('id', common_1.ParseUUIDPipe)),
    __metadata("design:type", Function),
    __metadata("design:paramtypes", [typeof (_c = typeof authenticated_request_interface_1.AuthenticatedRequest !== "undefined" && authenticated_request_interface_1.AuthenticatedRequest) === "function" ? _c : Object, String]),
    __metadata("design:returntype", void 0)
], JournalController.prototype, "remove", null);
exports.JournalController = JournalController = __decorate([
    (0, common_1.UseGuards)(jwt_auth_guard_1.JwtAuthGuard),
    (0, common_1.Controller)('journal'),
    __metadata("design:paramtypes", [journal_service_1.JournalService])
], JournalController);
//# sourceMappingURL=journal.controller.js.map