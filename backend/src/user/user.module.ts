import { Module } from '@nestjs/common';
import { UserService } from './user.service';
import { UserController } from './user.controller';
import { TypeOrmModule } from '@nestjs/typeorm'; // Importação do TypeORM
import { User } from './user.entity'; // Importação da Entidade User

@Module({
  imports: [
    // Registra a Entidade User para injeção de repositório neste módulo
    TypeOrmModule.forFeature([User]), 
  ],
  controllers: [UserController],
  providers: [UserService],
  // Exportar UserService e o Repositório de User é CRÍTICO
  exports: [UserService, TypeOrmModule.forFeature([User])], 
})
export class UserModule {}