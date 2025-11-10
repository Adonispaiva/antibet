import { Injectable, InternalServerErrorException, NotFoundException } from '@nestjs/common';
import { InjectRepository } from '@nestjs/typeorm';
import { Repository } from 'typeorm';
import { User } from './user.entity'; // Importação da Entidade
import * as bcrypt from 'bcrypt'; // Adicionado para hashing

@Injectable()
export class UserService {
  // Injeção de repositório real
  constructor(
    @InjectRepository(User) 
    private userRepository: Repository<User>,
  ) {}

  // --- Métodos de Leitura ---

  async findProfile(id: string): Promise<User | null> {
    return this.userRepository.findOne({ where: { id } });
  }

  async findByEmail(email: string): Promise<User | null> {
    // Nota: 'passwordHash' será carregado devido ao uso na autenticação
    return this.userRepository.findOne({ 
      where: { email },
      select: ['id', 'email', 'firstName', 'passwordHash', 'aiTokens', 'isPremium'],
    });
  }

  // --- Métodos de Escrita ---

  async create(data: { email: string, password?: string, firstName: string }): Promise<User> {
    const newUser = this.userRepository.create({
      email: data.email,
      firstName: data.firstName,
      // Hashing da senha deve ser tratado no AuthService, mas criamos o hash aqui para persistência
      passwordHash: data.password ? await bcrypt.hash(data.password, 10) : undefined,
    });
    
    try {
      return await this.userRepository.save(newUser);
    } catch (error) {
      if (error.code === '23505') { // Erro de violação de Unique Constraint (E-mail já existe)
        throw new InternalServerErrorException('Este e-mail já está em uso.');
      }
      throw new InternalServerErrorException('Falha ao criar usuário.');
    }
  }
  
  /**
   * Crédita um plano ao usuário após o Stripe Webhook.
   */
  async creditPlanToUser(userId: string, aiTokens: number): Promise<boolean> {
    const user = await this.userRepository.findOne({ where: { id: userId } });
    if (!user) {
      throw new NotFoundException(`Usuário ${userId} não encontrado para crédito.`);
    }

    // Lógica de crédito real
    user.aiTokens += aiTokens;
    user.isPremium = true; 
    
    await this.userRepository.save(user);

    return true;
  }
}