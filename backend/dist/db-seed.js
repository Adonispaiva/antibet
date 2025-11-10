"use strict";
Object.defineProperty(exports, "__esModule", { value: true });
const typeorm_1 = require("typeorm");
const plans_entity_ts_1 = require("./plans/plans.entity.ts");
const dotenv = require("dotenv");
dotenv.config();
console.log('--- [SEED SCRIPT] INICIANDO ---');
const AppDataSource = new typeorm_1.DataSource({
    type: 'postgres',
    host: process.env.DB_HOST || 'localhost',
    port: parseInt(process.env.DB_PORT, 10) || 5432,
    username: process.env.DB_USERNAME,
    password: process.env.DB_PASSWORD,
    database: process.env.DB_DATABASE,
    entities: [plans_entity_ts_1.Plan],
    synchronize: true,
});
async function bootstrap() {
    try {
        await AppDataSource.initialize();
        console.log('[SEED SCRIPT] Conexão com DataSource inicializada.');
        const planRepository = AppDataSource.getRepository(plans_entity_ts_1.Plan);
        console.log('[SEED SCRIPT] Limpando dados de Planos antigos (TRUNCATE)...');
        await planRepository.query('TRUNCATE TABLE "plan" RESTART IDENTITY CASCADE;');
        console.log('[SEED SCRIPT] Inserindo novos dados de Planos...');
        const plansData = [
            {
                id: 'basic_monthly',
                name: 'Plano Básico Mensal',
                description: 'Acesso limitado aos recursos de IA e diário. Ideal para começar.',
                price: 19.9,
                stripePriceId: 'price_1P6g5pLdJg9f2qXqXXXX0001',
            },
            {
                id: 'pro_monthly',
                name: 'Plano Pro Mensal',
                description: 'Acesso completo e ilimitado a todos os recursos, incluindo IA personalizada.',
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
    }
    catch (err) {
        console.error('--- [SEED SCRIPT] ERRO FATAL ---');
        console.error(err);
        process.exit(1);
    }
    finally {
        if (AppDataSource.isInitialized) {
            await AppDataSource.destroy();
            console.log('[SEED SCRIPT] Conexão com DataSource encerrada.');
        }
    }
}
bootstrap();
//# sourceMappingURL=db-seed.js.map