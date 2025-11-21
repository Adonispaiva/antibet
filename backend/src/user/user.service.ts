import { Injectable, NotFoundException } from '@nestjs/common';
import { InjectRepository } from '@nestjs/typeorm';
import { Repository } from 'typeorm';
import { User, UserRole } from './entities/user.entity';

@Injectable()
export class UserService {
  constructor(
    @InjectRepository(User)
    private readonly userRepository: Repository<User>,
  ) {}

  /**
   * Cria um novo usuário no banco de dados.
   * @param createUserDto DTO contendo os dados do novo usuário.
   * @returns O usuário recém-criado.
   */
  async create(createUserDto: any): Promise<User> {
    const newUser = this.userRepository.create(createUserDto);
    return this.userRepository.save(newUser);
  }

  /**
   * Retorna todos os usuários no sistema (usado principalmente para fins de ADMIN).
   * @returns Lista de todos os usuários.
   */
  async findAll(): Promise<User[]> {
    return this.userRepository.find();
  }

  /**
   * Encontra um usuário pelo ID.
   */
  async findOne(id: string): Promise<User | undefined> {
    return this.userRepository.findOne({ where: { id } });
  }
  
  /**
   * Encontra um usuário pelo email, incluindo o campo 'password'.
   * Crucial para a autenticação.
   */
  async findOneByEmail(email: string): Promise<User | undefined> {
    return this.userRepository
      .createQueryBuilder('user')
      .addSelect('user.password') // Seleciona explicitamente o campo password
      .where('user.email = :email', { email })
      .getOne();
  }

  /**
   * Atualiza o Role (nivel de acesso) de um usuario.
   * Chamado pelo PaymentsService apos um pagamento bem-sucedido ou cancelamento.
   * @param userId O ID do usuario a ser atualizado.
   * @param newRole O novo UserRole (BASIC, PREMIUM, etc.)
   */
  async updateUserRole(userId: string, newRole: UserRole): Promise<User> {
    const user = await this.findOne(userId);
    if (!user) {
      throw new NotFoundException('Usuario nao encontrado para atualizacao de Role.');
    }

    user.role = newRole;
    return this.userRepository.save(user);
  }
}