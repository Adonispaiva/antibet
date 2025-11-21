import { Controller, Get, UseGuards, Request } from '@nestjs/common';
import { AuthGuard } from '@nestjs/passport';

import { UserService } from './user.service';
import { User } from './entities/user.entity';

// Interface para garantir o objeto user injetado pelo JwtStrategy
interface RequestWithUser extends Request {
  user: {
    userId: string;
    email: string;
    role: string;
  };
}

@UseGuards(AuthGuard('jwt')) // Protege todas as rotas deste controlador
@Controller('users') 
export class UserController {
  constructor(private readonly userService: UserService) {}

  /**
   * Endpoint para retornar o perfil do usuário logado (GET /users/me).
   * Essencial para o Frontend carregar o estado da sessão.
   */
  @Get('me')
  async getProfile(@Request() req: RequestWithUser): Promise<Partial<User>> {
    // Apenas o ID é necessário, pois o UserService faz o resto
    const user = await this.userService.findOne(req.user.userId);
    
    // Remove o campo 'password' (embora já esteja com select: false na Entity)
    if (user) {
      const { password, ...result } = user;
      return result;
    }
    
    // Se o usuário não for encontrado (embora improvável após o JwtStrategy), retorna erro
    return null;
  }
}