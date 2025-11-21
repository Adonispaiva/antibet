import { IsEmail, IsNotEmpty, IsString, MinLength } from 'class-validator';

/**
 * Data Transfer Object (DTO) para validar o payload
 * da requisição de login (POST /auth/login).
 */
export class LoginDto {
  @IsEmail({}, { message: 'O email fornecido nao e valido.' })
  @IsNotEmpty({ message: 'O email e obrigatorio.' })
  email: string;

  @IsString({ message: 'A senha deve ser um texto.' })
  @IsNotEmpty({ message: 'A senha e obrigatoria.' })
  @MinLength(8, { message: 'A senha deve ter no minimo 8 caracteres.' })
  password: string;
}