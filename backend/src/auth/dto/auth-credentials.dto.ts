// backend/src/auth/dto/auth-credentials.dto.ts

import { IsNotEmpty, IsEmail, MinLength, MaxLength } from 'class-validator';

/**
 * Data Transfer Object (DTO) para credenciais de autenticação (Login/Registro).
 * * Este DTO é usado para garantir que os dados enviados pelo cliente (Mobile) 
 * para os endpoints de autenticação estejam corretos e válidos, conforme o 
 * padrão de qualidade NestJS e o princípio de Fail Fast.
 */
export class AuthCredentialsDto {
  @IsNotEmpty({ message: 'O email é obrigatório.' })
  @IsEmail({}, { message: 'O email deve ser um endereço de email válido.' })
  @MaxLength(255)
  email: string;

  @IsNotEmpty({ message: 'A senha é obrigatória.' })
  @MinLength(8, { message: 'A senha deve ter no mínimo 8 caracteres.' })
  @MaxLength(32, { message: 'A senha deve ter no máximo 32 caracteres.' })
  // Observação: O hashing da senha é feito na camada de serviço, 
  // não no DTO, mas a validação de tamanho ocorre aqui.
  password: string;
}