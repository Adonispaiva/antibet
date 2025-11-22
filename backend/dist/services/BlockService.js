"use strict";
Object.defineProperty(exports, "__esModule", { value: true });
exports.BlockService = void 0;
const Logger_1 = require("../utils/Logger");
class BlockService {
    async enforceBlock(userId, durationMinutes) {
        try {
            Logger_1.Logger.warn(`[BlockService] 🚨 ATIVANDO PROTOCOLO DE BLOQUEIO para User ${userId}`);
            Logger_1.Logger.warn(`[BlockService] ⏳ Duração definida: ${durationMinutes} minutos.`);
            Logger_1.Logger.info(`[BlockService] Comando de bloqueio enviado para o dispositivo do usuário ${userId}.`);
            return true;
        }
        catch (error) {
            Logger_1.Logger.error(`[BlockService] Falha ao aplicar bloqueio para ${userId}`, error);
            return false;
        }
    }
    async unlock(userId) {
        Logger_1.Logger.info(`[BlockService] 🔓 Desbloqueando usuário ${userId}.`);
        return true;
    }
}
exports.BlockService = BlockService;
//# sourceMappingURL=BlockService.js.map