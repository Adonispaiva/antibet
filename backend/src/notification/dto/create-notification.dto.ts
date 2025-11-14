// backend/src/notification/dto/create-notification.dto.ts

import { IsNotEmpty, IsString, MaxLength, IsOptional, IsBoolean } from 'class-validator';

/**
 * Data Transfer Object (DTO) para a criação de uma nova notificação para o usuário.
 * * Este DTO é usado tipicamente pela camada de Serviço para registrar um novo alerta 
 * que será exibido no Mobile.
 */
export class CreateNotificationDto {
  @IsNotEmpty({ message: 'O título da notificação é obrigatório.' })
  @IsString({ message: 'O título deve ser uma string.' })
  @MaxLength(100)
  title: string;

  @IsNotEmpty({ message: 'A mensagem da notificação é obrigatória.' })
  @IsString({ message: 'A mensagem deve ser uma string.' })
  @MaxLength(500)
  message: string;

  @IsOptional()
  @IsBoolean({ message: 'O status de leitura deve ser um booleano.' })
  // Opcional, pois na criação é esperado que seja 'false', mas tipado para segurança.
  isRead?: boolean; 
}