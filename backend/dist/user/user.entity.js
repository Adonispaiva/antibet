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
var _a;
Object.defineProperty(exports, "__esModule", { value: true });
exports.User = void 0;
const typeorm_1 = require("typeorm");
const plan_entity_1 = require("../plans/entities/plan.entity");
const ai_log_entity_1 = require("../ai-chat/entities/ai-log.entity");
const journal_entry_entity_1 = require("../journal/entities/journal-entry.entity");
const goal_entity_1 = require("../goals/entities/goal.entity");
let User = class User {
};
exports.User = User;
__decorate([
    (0, typeorm_1.PrimaryGeneratedColumn)('uuid'),
    __metadata("design:type", String)
], User.prototype, "id", void 0);
__decorate([
    (0, typeorm_1.Column)({ unique: true }),
    __metadata("design:type", String)
], User.prototype, "email", void 0);
__decorate([
    (0, typeorm_1.Column)(),
    __metadata("design:type", String)
], User.prototype, "passwordHash", void 0);
__decorate([
    (0, typeorm_1.Column)(),
    __metadata("design:type", String)
], User.prototype, "avatarName", void 0);
__decorate([
    (0, typeorm_1.Column)(),
    __metadata("design:type", Number)
], User.prototype, "birthYear", void 0);
__decorate([
    (0, typeorm_1.Column)(),
    __metadata("design:type", String)
], User.prototype, "gender", void 0);
__decorate([
    (0, typeorm_1.Column)({ nullable: true }),
    __metadata("design:type", String)
], User.prototype, "mainConcern", void 0);
__decorate([
    (0, typeorm_1.CreateDateColumn)(),
    __metadata("design:type", Date)
], User.prototype, "createdAt", void 0);
__decorate([
    (0, typeorm_1.UpdateDateColumn)(),
    __metadata("design:type", Date)
], User.prototype, "updatedAt", void 0);
__decorate([
    (0, typeorm_1.Column)({ nullable: true }),
    __metadata("design:type", String)
], User.prototype, "planId", void 0);
__decorate([
    (0, typeorm_1.OneToOne)(() => plan_entity_1.Plan, { eager: true }),
    (0, typeorm_1.JoinColumn)(),
    __metadata("design:type", typeof (_a = typeof plan_entity_1.Plan !== "undefined" && plan_entity_1.Plan) === "function" ? _a : Object)
], User.prototype, "plan", void 0);
__decorate([
    (0, typeorm_1.OneToMany)(() => ai_log_entity_1.AiInteractionLog, (log) => log.user),
    __metadata("design:type", Array)
], User.prototype, "aiLogs", void 0);
__decorate([
    (0, typeorm_1.OneToMany)(() => journal_entry_entity_1.JournalEntry, (entry) => entry.user),
    __metadata("design:type", Array)
], User.prototype, "journalEntries", void 0);
__decorate([
    (0, typeorm_1.OneToMany)(() => goal_entity_1.Goal, (goal) => goal.user),
    __metadata("design:type", Array)
], User.prototype, "goals", void 0);
exports.User = User = __decorate([
    (0, typeorm_1.Entity)('users')
], User);
//# sourceMappingURL=user.entity.js.map