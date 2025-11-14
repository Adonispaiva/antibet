// backend/src/common/decorators/is-premium.decorator.ts

import { SetMetadata } from '@nestjs/common';

/**
 * Chave de metadados usada para identificar rotas que exigem uma assinatura Premium.
 */
export const IS_PREMIUM_KEY = 'isPremiumRequired';

/**
 * Decorator Customizado para marcar uma rota de API como Premium.
 * * Se este decorator for aplicado a um handler (método do controller), 
 * o PremiumGuard (a ser criado no próximo passo) irá interceptar a requisição 
 * e verificar se o usuário autenticado possui uma assinatura Premium ativa.
 * * Exemplo de uso:
 * @UseGuards(AuthGuard('jwt'), PremiumGuard)
 * @IsPremium()
 * @Get('premium-stats')
 * getPremiumStats() { ... }
 */
export const IsPremium = () => SetMetadata(IS_PREMIUM_KEY, true);