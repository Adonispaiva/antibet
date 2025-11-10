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
exports.AuthService = void 0;
const common_1 = require("@nestjs/common");
const jwt_1 = require("@nestjs/jwt");
const user_service_1 = require("../user/user.service");
const bcrypt = require("bcrypt");
let AuthService = class AuthService {
    constructor(userService, jwtService) {
        this.userService = userService;
        this.jwtService = jwtService;
    }
    async hashPassword(password) {
        const salt = await bcrypt.genSalt();
        return bcrypt.hash(password, salt);
    }
    async comparePassword(password, hash) {
        return bcrypt.compare(password, hash);
    }
    async register(registerDto) {
        registerDto.password = await this.hashPassword(registerDto.password);
        const user = await this.userService.create(registerDto);
        const payload = { id: user.id, email: user.email };
        const accessToken = this.jwtService.sign(payload);
        return {
            accessToken,
            user: {
                id: user.id,
                email: user.email,
                name: user.name,
            },
        };
    }
    async login(loginDto) {
        const user = await this.userService.findByEmail(loginDto.email);
        if (!user) {
            throw new common_1.UnauthorizedException('Credenciais inválidas.');
        }
        const isMatch = await this.comparePassword(loginDto.password, user.password);
        if (!isMatch) {
            throw new common_1.UnauthorizedException('Credenciais inválidas.');
        }
        const payload = { id: user.id, email: user.email };
        const accessToken = this.jwtService.sign(payload);
        return {
            accessToken,
            user: {
                id: user.id,
                email: user.email,
                name: user.name,
            },
        };
    }
    async getProfile(userId) {
        const user = await this.userService.findById(userId);
        if (!user) {
            throw new common_1.NotFoundException('Perfil de usuário não encontrado.');
        }
        return {
            id: user.id,
            email: user.email,
            name: user.name,
            plan: {
                id: user.currentPlan.id,
                name: user.currentPlan.name,
                price: user.currentPlan.price,
            },
        };
    }
};
exports.AuthService = AuthService;
exports.AuthService = AuthService = __decorate([
    (0, common_1.Injectable)(),
    __metadata("design:paramtypes", [user_service_1.UserService,
        jwt_1.JwtService])
], AuthService);
//# sourceMappingURL=auth.service.js.map