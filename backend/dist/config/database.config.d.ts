import { TypeOrmModuleOptions } from '@nestjs/typeorm';
declare const databaseConfig: (() => TypeOrmModuleOptions) & import("@nestjs/config").ConfigFactoryKeyHost<TypeOrmModuleOptions>;
export default databaseConfig;
