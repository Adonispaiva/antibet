import { Module } from '@nestjs/common';
import { ConfigModule } from '@nestjs/config';
import { AuthModule } from './auth/auth.module';
import { UserModule } from './user/user.module';
import { AiChatModule } from './ai-chat/ai-chat.module';
import { PlansModule } from './plans/plans.module';
import { PaymentsModule } from './payments/payments.module';

// --- NOVO: TypeORM ---
import { TypeOrmModule } from '@nestjs/typeorm';
import { User } from './user/user.entity';
// O PlansModule também usará uma entidade, que idealmente seria registrada aqui.

@Module({
  imports: [
    // 1. Configuração de Variáveis de Ambiente
    ConfigModule.forRoot({ isGlobal: true }),

    // 2. Configuração do Banco de Dados (TypeORM)
    TypeOrmModule.forRoot({
      // Usaremos Postgre em produção, mas SQLite ou stub para desenvolvimento:
      type: 'postgres', // Substitua por 'sqlite' para ambiente local sem DB
      host: process.env.DB_HOST || 'localhost',
      port: parseInt(process.env.DB_PORT, 10) || 5432,
      username: process.env.DB_USERNAME || 'postgres',
      password: process.env.DB_PASSWORD || 'postgres',
      database: process.env.DB_DATABASE || 'antibet_db',
      
      entities: [User], // Registra a entidade User
      // O ideal é usar `synchronize: false` em produção e migrações.
      synchronize: true, // Auto-criação de tabelas para desenvolvimento
      autoLoadEntities: true, // Carrega entidades automaticamente
      ssl: process.env.NODE_ENV === 'production',
    }),
    
    // 3. Módulos de Feature
    AuthModule,
    UserModule,
    AiChatModule,
    PlansModule,
    PaymentsModule,
  ],
  controllers: [],
  providers: [],
})
export class AppModule {}