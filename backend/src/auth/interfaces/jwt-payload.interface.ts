// backend/src/auth/interfaces/jwt-payload.interface.ts

/**
 * Interface que define a estrutura do payload contido no JSON Web Token (JWT).
 * * É crucial para o princípio de Menos Privilégio, garantindo que apenas os dados 
 * mínimos e essenciais sejam armazenados no token para identificar o usuário 
 * em cada requisição autenticada.
 * * Este contrato é usado pelo AuthService (para criar o token) e pelo 
 * JwtStrategy (para validar o token e injetar o usuário na requisição).
 */
export interface JwtPayload {
  /**
   * Identificador único do usuário no banco de dados.
   */
  id: number; 

  /**
   * Email do usuário. Usado como identificador primário.
   */
  email: string;

  // Campos padrão do JWT (como 'iat', 'exp') são adicionados automaticamente 
  // pela biblioteca 'jsonwebtoken' (usada no NestJS por baixo dos panos) 
  // e não precisam ser declarados explicitamente aqui.
}