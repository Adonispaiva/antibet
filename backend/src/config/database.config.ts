import { TypeOrmModuleOptions } from '@nestjs/typeorm';
import { registerAs } from '@nestjs/config';
import { User } from '../user/user.entity'; // Importa a Entidade que acabamos de criar

const databaseConfig = registerAs('database', (): TypeOrmModuleOptions => ({
  type: 'postgres',
  host: process.env.DB_HOST,
  port: parseInt(process.env.DB_PORT, 10) || 5432,
  username: process.env.DB_USER,
  password: process.env.DB_PASSWORD,
  database: process.env.DB_NAME,
  
  // Lista de entidades (tabelas) que o TypeORM deve gerenciar
  entities: [User],
  
  // Sincroniza o esquema do banco de dados com as entidades
  // DEVE SER 'false' EM AMBIENTE DE PRODUÇÃO para evitar perda de dados.
  synchronize: process.env.NODE_ENV === 'development',
  
  // Exibe as queries SQL no console (útil para debug)
  logging: process.env.NODE_ENV === 'development',
}));

// A exportação default é usada pelo TypeOrmModule no AppModule
export default databaseConfig;