import {
  IsEnum,
  IsJSON,
  IsNotEmpty,
  IsOptional,
  IsString,
  IsUUID,
} from 'class-validator';
import { NotificationType } from '../entities/notification.entity';

/**
 * Data Transfer Object (DTO) para criar uma nova notificação.
 * (Usado principalmente por services internos, não por endpoints públicos).
 */
export class CreateNotificationDto {
  @IsUUID('4', { message: 'O ID do destinatario deve ser um UUID valido.' })
  @IsNotEmpty({ message: 'O ID do destinatario (recipientId) e obrigatorio.' })
  recipientId: string;

  @IsString({ message: 'O titulo deve ser um texto.' })
  @IsNotEmpty({ message: 'O titulo e obrigatorio.' })
  title: string;

  @IsString({ message: 'A mensagem deve ser um texto.' })
  @IsNotEmpty({ message: 'A mensagem e obrigatoria.' })
  message: string;

  @IsEnum(NotificationType, { message: 'Tipo de notificacao invalido.' })
  @IsOptional()
  type?: NotificationType;

  @IsJSON({ message: 'Os metadados devem ser um JSON valido.' })
  @IsOptional()
  metadata?: any;
}