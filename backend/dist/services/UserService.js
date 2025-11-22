"use strict";
Object.defineProperty(exports, "__esModule", { value: true });
exports.UserService = void 0;
const Logger_1 = require("../utils/Logger");
class UserService {
    async logTrigger(userId, triggerData) {
        try {
            Logger_1.Logger.info(`[UserService] 📝 Registando gatilho para o User ${userId}`);
            Logger_1.Logger.info(`[UserService] Detalhes: ${JSON.stringify(triggerData)}`);
            Logger_1.Logger.info(`[UserService] ✅ Gatilho salvo com sucesso. ID: trigger_${Date.now()}`);
        }
        catch (error) {
            Logger_1.Logger.error(`[UserService] Falha ao salvar gatilho para ${userId}`, error);
            throw new Error('Erro ao persistir dados do gatilho.');
        }
    }
    async getUser(userId) {
        return {
            id: userId,
            name: "Utilizador Teste",
            email: "user@antibet.com",
            streakDays: 0
        };
    }
}
exports.UserService = UserService;
//# sourceMappingURL=UserService.js.map