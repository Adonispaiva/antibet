// backend/src/auth/dto/auth-response.dto.ts

import { IsNotEmpty, IsString } from 'class-validator';

/**
 * Data Transfer Object (DTO) para a resposta de autenticação (Login/Registro).
 * * Define o formato esperado para o cliente (Mobile) após uma autenticação bem-sucedida.
 * * Segue o padrão OAuth/JWT, retornando o token de acesso e seu tipo.
 */
export class AuthResponseDto {
  @IsNotEmpty()
  @IsString()
  /**
   * O JSON Web Token (JWT) que o cliente deve usar nas requisições subsequentes.
   */
  accessToken: string;

  @IsNotEmpty()
  @IsString()
  /**
   * O tipo de token, geralmente "Bearer".
   */
  tokenType: string;

  // Opcional: Poderia incluir o refresh_token ou os dados do usuário aqui, 
  // mas optamos por manter o DTO focado no token para simplificar a resposta.
}