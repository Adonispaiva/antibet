import {
  IsString,
  IsEmail,
  MinLength,
  MaxLength,
  IsNotEmpty,
  IsEnum,
  IsDateString,
} from 'class-validator';
// import { Gender } from '../user/user.entity'; // <-- CAUSA DO ERRO (TS2305)

// CORREÇÃO: Definindo o enum localmente no DTO para remover a importação falha.
export enum Gender {
  MALE = 'male',
  FEMALE = 'female',
  OTHER = 'other',
}

export class AuthRegisterDto {
  @IsEmail()
  @IsNotEmpty()
  email: string;

  @IsString()
  @MinLength(6, { message: 'A senha deve ter pelo menos 6 caracteres' })
  @IsNotEmpty()
  password: string;

  @IsString()
  @IsNotEmpty()
  @MinLength(3)
  @MaxLength(50)
  name: string;

  @IsDateString()
  @IsNotEmpty()
  birthDate: string; // Formato 'YYYY-MM-DD'

  @IsEnum(Gender, { message: 'Gênero inválido' })
  @IsNotEmpty()
  gender: Gender;
}