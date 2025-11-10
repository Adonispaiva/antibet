/*
 * SCRIPT DE SEED (v2.3)
 * Correção Final de Pathing (Forçando Path Relativo com Extensão)
 */
import { DataSource } from 'typeorm';
// CORREÇÃO FINAL: Path relativo com extensão forçada
import { Plan } from './plans/plans.entity.ts';
import * as dotenv from 'dotenv';

// Carrega as variáveis de ambiente do .env
dotenv.config();

console.log('--- [SEED SCRIPT] INICIANDO ---');
// ... (código omitido)

// Configuração do DataSource (API Moderna)
const AppDataSource = new DataSource({
  type: 'postgres', 
  host: process.env.DB_HOST || 'localhost',
  port: parseInt(process.env.DB_PORT, 10) || 5432,
  username: process.env.DB_USERNAME,
  password: process.env.DB_PASSWORD,
  database: process.env.DB_DATABASE,
  entities: [Plan], 
  synchronize: true, 
});
// ... (resto da lógica)

async function bootstrap() {
  try {
    await AppDataSource.initialize();
    console.log('[SEED SCRIPT] Conexão com DataSource inicializada.');

    const planRepository = AppDataSource.getRepository(Plan);

    console.log('[SEED SCRIPT] Limpando dados de Planos antigos (TRUNCATE)...');
    await planRepository.query('TRUNCATE TABLE "plan" RESTART IDENTITY CASCADE;');

    console.log('[SEED SCRIPT] Inserindo novos dados de Planos...');
    const plansData = [
      {
        id: 'basic_monthly',
        name: 'Plano Básico Mensal',
        description:
          'Acesso limitado aos recursos de IA e diário. Ideal para começar.',
        price: 19.9,
        stripePriceId: 'price_1P6g5pLdJg9f2qXqXXXX0001', 
      },
      {
        id: 'pro_monthly',
        name: 'Plano Pro Mensal',
        description:
          'Acesso completo e ilimitado a todos os recursos, incluindo IA personalizada.',
        price: 49.9,
        stripePriceId: 'price_1P6g5pLdJg9f2qXqXXXX0002', 
      },
    ];
    
    for (const data of plansData) { 
      const plan = planRepository.create(data);
      await planRepository.save(plan);
      console.log(`[SEED SCRIPT] Plano '${data.name}' criado com sucesso.`);
    }

    console.log('--- [SEED SCRIPT] CONCLUÍDO ---');
  } catch (err) {
    console.error('--- [SEED SCRIPT] ERRO FATAL ---');
    console.error(err);
    process.exit(1);
  } finally {
    if (AppDataSource.isInitialized) {
      await AppDataSource.destroy();
      console.log('[SEED SCRIPT] Conexão com DataSource encerrada.');
    }
  }
}

// Inicia o processo
bootstrap();