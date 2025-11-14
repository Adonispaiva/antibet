// backend/src/user/dto/update-user.dto.ts

import { IsString, IsEmail, IsOptional, MinLength, MaxLength } from 'class-validator';

/**
 * Data Transfer Object (DTO) para a atualização dos dados do usuário.
 * * Todos os campos são opcionais, permitindo atualizações parciais de perfil.
 * * A validação garante que, se um campo for fornecido, ele cumpra os requisitos de integridade.
 */
export class UpdateUserDto {
  @IsOptional()
  @IsEmail({}, { message: 'O email deve ser um endereço de email válido.' })
  @MaxLength(255)
  email?: string;

  @IsOptional()
  @MinLength(8, { message: 'A senha deve ter no mínimo 8 caracteres.' })
  @MaxLength(32, { message: 'A senha deve ter no máximo 32 caracteres.' })
  password?: string; // Usado para troca de senha

  @IsOptional()
  @IsString({ message: 'O nome deve ser uma string.' })
  @MaxLength(100)
  name?: string;

  @IsOptional()
  @IsString({ message: 'A moeda deve ser uma string de 3 letras.' })
  @MaxLength(3)
  currency?: string; // Ex: BRL, USD
}