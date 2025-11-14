import { Module } from '@nestjs/common';
import { TypeOrmModule } from '@nestjs/typeorm';
import { UserService } from './user.service';
import { User } from './entities/user.entity';

@Module({
  imports: [
    // Registra a UserEntity no TypeORM para que o repositório possa ser injetado.
    TypeOrmModule.forFeature([User]),
  ],
  controllers: [], // O UserController será adicionado posteriormente se houver endpoints de usuário não-autenticados.
  providers: [UserService],
  // Exportamos o UserService para que outros módulos (especialmente o AuthModule) possam utilizá-lo.
  exports: [UserService],
})
export class UserModule {}