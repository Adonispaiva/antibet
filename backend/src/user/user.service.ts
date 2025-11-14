import { Injectable } from '@nestjs/common';
import { InjectRepository } from '@nestjs/typeorm';
import { Repository } from 'typeorm';
import { User } from './entities/user.entity';

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
   * Este método é crucial para a autenticação, permitindo que o AuthService
   * acesse a senha hasheada para comparação.
   */
  async findOneByEmail(email: string): Promise<User | undefined> {
    return this.userRepository
      .createQueryBuilder('user')
      .addSelect('user.password') // Seleciona explicitamente o campo password
      .where('user.email = :email', { email })
      .getOne();
  }
}