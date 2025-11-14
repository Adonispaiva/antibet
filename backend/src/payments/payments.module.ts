// backend/src/payments/payments.module.ts

import { Module, forwardRef } from '@nestjs/common';
import { TypeOrmModule } from '@nestjs/typeorm';
import { PaymentsService } from './payments.service';
import { PaymentsController } from './payments.controller';
import { AuthModule } from '../auth/auth.module';
import { UserModule } from '../user/user.module';

// Assumindo a existência de entidades relacionadas a pagamentos
import { Subscription } from './entities/subscription.entity'; 
import { PaymentLog } from './entities/payment-log.entity'; 

@Module({
  imports: [
    // 1. Importa as entidades de pagamentos para o TypeORM
    TypeOrmModule.forFeature([Subscription, PaymentLog]), 
    
    // 2. Importa o módulo de autenticação para proteger rotas (ex: get subscription status)
    forwardRef(() => AuthModule), 
    
    // 3. Importa o módulo de usuário para atualizar o campo isPremiumActive após o pagamento
    forwardRef(() => UserModule), 
  ],
  controllers: [PaymentsController],
  providers: [PaymentsService],
  exports: [
    PaymentsService, // Exporta o serviço para que o UserModule (ou outros) possa checar pagamentos
    TypeOrmModule, // Exporta o TypeOrmModule de pagamentos
  ],
})
export class PaymentsModule {}