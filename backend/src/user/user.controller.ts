import { Controller, Get, UseGuards, Request } from '@nestjs/common';
import { UserService } from './user.service';
import { JwtAuthGuard } from '../auth/guards/jwt-auth.guard'; // Importar o Guard já criado

@Controller('user')
export class UserController {
  constructor(private readonly userService: UserService) {}

  /**
   * Rota protegida para obter o perfil do usuário logado.
   * Requer um JWT válido no header de autorização.
   * @returns O perfil do usuário.
   */
  @UseGuards(JwtAuthGuard)
  @Get('profile')
  async getProfile(@Request() req) {
    // O ID do usuário foi injetado na requisição pelo JwtAuthGuard
    return this.userService.findProfile(req.user.id);
  }
}