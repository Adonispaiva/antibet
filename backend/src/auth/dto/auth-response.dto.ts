/**
 * Data Transfer Object (DTO) para definir a estrutura
 * da resposta de um login bem-sucedido.
 * Isso garante que o Frontend saiba exatamente o que esperar.
 */
export class AuthResponseDto {
  /**
   * O Token de Acesso JWT (JSON Web Token)
   * @example "eyJhbGciOiJIU..."
   */
  access_token: string;

  /**
   * Os dados publicos do usuario que fez o login.
   * (O tipo 'any' sera substituido por um DTO de Usuario especifico)
   */
  user: any; 
}