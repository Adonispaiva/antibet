// backend/src/notification/dto/update-notification.dto.ts

import { IsOptional, IsBoolean } from 'class-validator';

/**
 * Data Transfer Object (DTO) para a atualização parcial de uma notificação (PATCH).
 * * O principal caso de uso é marcar a notificação como lida (`isRead: true`).
 */
export class UpdateNotificationDto {
  @IsOptional()
  @IsBoolean({ message: 'O status de leitura deve ser um booleano.' })
  /**
   * Status de leitura da notificação (true = lida, false = não lida).
   */
  isRead?: boolean;
  
  // O título e a mensagem não são tipicamente atualizáveis pelo cliente, 
  // mas poderiam ser adicionados se houvesse necessidade de reclassificação/correção. 
  // Mantemos o DTO enxuto, focado na funcionalidade principal.
}