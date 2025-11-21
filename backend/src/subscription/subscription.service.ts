import { Injectable, NotFoundException } from '@nestjs/common';
import { InjectRepository } from '@nestjs/typeorm';
import { Repository } from 'typeorm';
import { Subscription, SubscriptionStatus } from './entities/subscription.entity';
import { User, UserRole } from '../user/entities/user.entity';

@Injectable()
export class SubscriptionService {
  constructor(
    @InjectRepository(Subscription)
    private readonly subscriptionRepository: Repository<Subscription>,
  ) {}

  /**
   * Encontra a assinatura de um usuario pelo ID do usuario.
   * @param userId O ID do usuario.
   * @returns A assinatura do usuario, ou lanca um erro.
   */
  async findByUserId(userId: string): Promise<Subscription> {
    const subscription = await this.subscriptionRepository.findOne({
      where: { userId: userId },
    });

    if (!subscription) {
      throw new NotFoundException('Assinatura nao encontrada para este usuario.');
    }
    return subscription;
  }

  /**
   * Cria uma nova assinatura (ou atualiza uma existente) para um usuario.
   * Chamado pelo webhook de pagamento bem-sucedido.
   */
  async createOrUpdateSubscription(
    user: User,
    planId: string,
    gatewaySubscriptionId: string,
    periodEnd: Date,
    status: SubscriptionStatus,
    grantedRole: UserRole, // Adicionado para atualizar o acesso
  ): Promise<Subscription> {
    let subscription = await this.subscriptionRepository.findOne({
      where: { userId: user.id },
    });

    if (!subscription) {
      // Cria uma nova assinatura se nao existir
      subscription = this.subscriptionRepository.create({
        user: user,
        userId: user.id,
      });
    }

    // Atualiza os dados
    subscription.paymentGatewaySubscriptionId = gatewaySubscriptionId;
    subscription.planId = planId;
    subscription.currentPeriodEnd = periodEnd;
    subscription.status = status;
    subscription.currentRole = grantedRole; // Atualiza o Role da assinatura

    return this.subscriptionRepository.save(subscription);
  }

  /**
   * Atualiza o status de uma assinatura (ex: via webhook de cancelamento).
   * @param gatewaySubscriptionId ID da assinatura no gateway.
   * @param newStatus O novo status (ex: CANCELED, INACTIVE).
   */
  async updateSubscriptionStatus(
    gatewaySubscriptionId: string,
    newStatus: SubscriptionStatus,
    canceledAt: Date | null = null,
  ): Promise<Subscription> {
    const subscription = await this.subscriptionRepository.findOne({
      where: { paymentGatewaySubscriptionId: gatewaySubscriptionId },
    });

    if (!subscription) {
      throw new NotFoundException(
        'Assinatura nao encontrada com este ID de gateway.',
      );
    }

    subscription.status = newStatus;
    if (canceledAt) {
      subscription.canceledAt = canceledAt;
    }
    
    // Se a assinatura for cancelada ou inativa, rebaixa o usuario
    if (newStatus === SubscriptionStatus.INACTIVE || newStatus === SubscriptionStatus.CANCELED) {
      subscription.currentRole = UserRole.BASIC;
    }

    return this.subscriptionRepository.save(subscription);
  }
}