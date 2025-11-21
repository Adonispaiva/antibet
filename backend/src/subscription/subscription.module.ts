import { Module } from '@nestjs/common';
import { TypeOrmModule }S from '@nestjs/typeorm';
import { Subscription } from './entities/subscription.entity';
import { SubscriptionService } from './subscription.service';

@Module({
  imports: [
    // Registra a entidade Subscription no TypeORM
    TypeOrmModule.forFeature([Subscription]),
  ],
  providers: [SubscriptionService],
  // Exportamos o SubscriptionService para que o PaymentsModule
  // e o UserModule (para verificar status) possam usa-lo.
  exports: [SubscriptionService], 
})
export class SubscriptionModule {}