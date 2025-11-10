import { PartialType } from '@nestjs/mapped-types';
import { CreateGoalDto } from './create-goal.dto';
import { IsBoolean, IsOptional } from 'class-validator';

/**
 * DTO para validar a atualização de uma Meta (PATCH).
 * Herda as validações de CreateGoalDto, mas as torna opcionais.
 */
export class UpdateGoalDto extends PartialType(CreateGoalDto) {
  @IsOptional()
  @IsBoolean({ message: 'Status de conclusão deve ser booleano.' })
  isCompleted?: boolean;
}