// backend/src/common/guards/premium.guard.ts

import { CanActivate, ExecutionContext, Injectable, ForbiddenException, Inject } from '@nestjs/common';
import { Reflector } from '@nestjs/core';
import { Observable } from 'rxjs';
import { IS_PREMIUM_KEY } from '../decorators/is-premium.decorator'; // O decorator criado
import { User } from '../../user/entities/user.entity'; // Assumindo a entidade de Usuário injetada

/**
 * Guard de proteção que verifica se o usuário autenticado tem uma assinatura Premium ativa 
 * para acessar uma rota marcada com o decorator @IsPremium().
 */
@Injectable()
export class PremiumGuard implements CanActivate {
  constructor(private reflector: Reflector) {}

  canActivate(
    context: ExecutionContext,
  ): boolean | Promise<boolean> | Observable<boolean> {
    
    // 1. Verifica a Metadata: Checa se a rota atual requer acesso Premium
    const isPremiumRequired = this.reflector.getAllAndOverride<boolean>(
      IS_PREMIUM_KEY,
      [
        context.getHandler(), // Verifica o método
        context.getClass(), // Verifica a classe
      ],
    );

    // Se o decorator @IsPremium() não estiver na rota, permite o acesso (não-Premium)
    if (!isPremiumRequired) {
      return true;
    }

    // 2. Obtém o Objeto de Usuário
    // Assumimos que o AuthGuard('jwt') foi executado ANTES deste Guard, 
    // e que ele injetou o objeto de usuário (User) na requisição (req.user).
    const request = context.switchToHttp().getRequest();
    const user: User = request.user;

    // 3. Verifica o Status Premium do Usuário
    // Assumimos que a entidade User tem um campo para verificar o status de assinatura.
    // Em um sistema real, este campo seria atualizado pelo módulo de Pagamentos (Webhook).
    // Para simplificação arquitetural, assumimos a existência de um campo no objeto injetado:
    const isPremium = user.isPremiumActive; // Propriedade hipotética na Entidade User

    if (isPremium) {
      return true;
    } else {
      // 4. Bloqueia o Acesso e Lança Exceção
      throw new ForbiddenException(
        'Acesso negado. Esta funcionalidade é exclusiva para assinantes Premium.',
      );
    }
  }
}