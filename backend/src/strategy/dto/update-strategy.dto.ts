// backend/src/strategy/dto/update-strategy.dto.ts

import { IsString, IsOptional, MaxLength } from 'class-validator';

/**
 * Data Transfer Object (DTO) para a atualização parcial de uma estratégia (PATCH).
 * * Todos os campos são opcionais, permitindo ao usuário atualizar apenas uma parte 
 * da estratégia (ex: corrigir um erro de digitação na descrição ou renomear).
 */
export class UpdateStrategyDto {
  @IsOptional()
  @IsString({ message: 'O nome da estratégia deve ser uma string.' })
  @MaxLength(100)
  name?: string;

  @IsOptional()
  @IsString({ message: 'A descrição da estratégia deve ser uma string.' })
  @MaxLength(1000)
  description?: string; // Descrição detalhada da regra/abordagem da estratégia
}