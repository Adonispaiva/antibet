import { Module } from '@nestjs/common';
import { TypeOrmModule } from '@nestjs/typeorm';

import { UserService } from './user.service';
import { UserController } from './user.controller';
import { User } from './entities/user.entity';
import { Subscription } from '../subscription/entities/subscription.entity'; // Importado

@Module({
  imports: [
    // Registra a UserEntity e a SubscriptionEntity para garantir o mapeamento da relação 1:1
    TypeOrmModule.forFeature([User, Subscription]),
  ],
  controllers: [UserController],
  providers: [UserService],
  // Exportamos o UserService para que o AuthModule e o PaymentsModule possam utilizá-lo.
  exports: [UserService],
})
export class UserModule {}