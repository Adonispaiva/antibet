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
exports.NotificationService = void 0;
const common_1 = require("@nestjs/common");
const typeorm_1 = require("@nestjs/typeorm");
const typeorm_2 = require("typeorm");
const notification_entity_1 = require("./entities/notification.entity");
let NotificationService = class NotificationService {
    constructor(notificationRepository) {
        this.notificationRepository = notificationRepository;
    }
    async createNotification(recipient, title, message, type, metadata = null) {
        const newNotification = this.notificationRepository.create({
            recipient: recipient,
            recipientId: recipient.id,
            title: title,
            message: message,
            type: type,
            metadata: metadata,
            isRead: false,
        });
        return this.notificationRepository.save(newNotification);
    }
    async findAllUserNotifications(recipientId) {
        return this.notificationRepository.find({
            where: { recipientId: recipientId },
            order: { createdAt: 'DESC' },
        });
    }
    async markAsRead(id, recipientId) {
        const notification = await this.notificationRepository.findOne({
            where: { id: id, recipientId: recipientId },
        });
        if (!notification) {
            throw new common_1.NotFoundException('Notificacao nao encontrada ou nao pertence a este usuario.');
        }
        if (!notification.isRead) {
            notification.isRead = true;
            return this.notificationRepository.save(notification);
        }
        return notification;
    }
    async getUnreadCount(recipientId) {
        return this.notificationRepository.count({
            where: { recipientId: recipientId, isRead: false },
        });
    }
};
exports.NotificationService = NotificationService;
exports.NotificationService = NotificationService = __decorate([
    (0, common_1.Injectable)(),
    __param(0, (0, typeorm_1.InjectRepository)(notification_entity_1.Notification)),
    __metadata("design:paramtypes", [typeorm_2.Repository])
], NotificationService);
//# sourceMappingURL=notification.service.js.map