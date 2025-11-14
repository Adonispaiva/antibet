// backend/src/user/user.controller.ts

import { Controller, Get, UseGuards, Patch, Body, Req, HttpCode, HttpStatus } from '@nestjs/common';
import { AuthGuard } from '@nestjs/passport'; // Assumindo a estratégia 'jwt' como padrão
import { Request } from 'express'; // Tipagem para o objeto Request do Express

import { UserService } from './user.service';
import { UpdateUserDto } from './dto/update-user.dto'; // O DTO de atualização
import { User } from './entities/user.entity'; // A Entidade de Usuário

/**
 * Interface customizada para a requisição com o objeto User injetado pelo JwtStrategy.
 * NOTA: Isso deve ser definido globalmente, mas é repetido aqui para clareza.
 */
interface RequestWithUser extends Request {
  user: User; // O objeto de usuário injetado pelo JwtStrategy
}

@Controller('user')
@UseGuards(AuthGuard('jwt')) // Protege todas as rotas deste controller
export class UserController {
  constructor(private readonly userService: UserService) {}

  /**
   * Obtém o perfil do usuário autenticado (logado).
   * @param req O objeto de requisição, contendo o objeto 'user' injetado.
   * @returns O objeto de usuário (excluindo a senha).
   */
  @Get('profile')
  getProfile(@Req() req: RequestWithUser) {
    // O JwtStrategy já injetou a entidade de usuário na requisição (req.user).
    // O campo 'password' será excluído automaticamente pela entidade @Exclude().
    return req.user;
  }

  /**
   * Atualiza os dados de perfil do usuário autenticado.
   * @param req O objeto de requisição, contendo o objeto 'user' injetado.
   * @param updateUserDto Os dados parciais a serem atualizados.
   * @returns O objeto de usuário atualizado.
   */
  @Patch('profile')
  @HttpCode(HttpStatus.OK)
  async updateProfile(
    @Req() req: RequestWithUser,
    @Body() updateUserDto: UpdateUserDto,
  ) {
    const userId = req.user.id;
    // Delega a lógica de atualização (hash de senha, persistência) para o serviço.
    const updatedUser = await this.userService.update(userId, updateUserDto);
    
    // Retorna a entidade atualizada.
    return updatedUser;
  }
}