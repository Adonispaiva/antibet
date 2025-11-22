import { Logger } from '../utils/Logger';

/**
 * Serviço responsável pela gestão de dados do utilizador.
 * Inclui perfil, configurações e registo de métricas psicométricas (Gatilhos).
 */
export class UserService {

  /**
   * Regista um gatilho emocional identificado pela IA ou reportado pelo utilizador.
   * * Estes dados alimentam o dashboard de evolução psicométrica.
   * * @param userId ID do utilizador.
   * @param triggerData Dados estruturados do gatilho (categoria, intensidade, nota).
   */
  public async logTrigger(userId: string, triggerData: any): Promise<void> {
    try {
      Logger.info(`[UserService] 📝 Registando gatilho para o User ${userId}`);
      Logger.info(`[UserService] Detalhes: ${JSON.stringify(triggerData)}`);

      // Simulação de persistência em Banco de Dados (SQL/NoSQL)
      // const triggerEntry = {
      //   userId,
      //   category: triggerData.trigger_category,
      //   intensity: triggerData.intensity,
      //   note: triggerData.note,
      //   timestamp: new Date()
      // };
      // await db.triggers.create(triggerEntry);

      Logger.info(`[UserService] ✅ Gatilho salvo com sucesso. ID: trigger_${Date.now()}`);
      
    } catch (error) {
      Logger.error(`[UserService] Falha ao salvar gatilho para ${userId}`, error);
      throw new Error('Erro ao persistir dados do gatilho.');
    }
  }

  /**
   * Recupera o perfil do utilizador (Mock).
   */
  public async getUser(userId: string): Promise<any> {
    // Mock return
    return {
      id: userId,
      name: "Utilizador Teste",
      email: "user@antibet.com",
      streakDays: 0
    };
  }
}