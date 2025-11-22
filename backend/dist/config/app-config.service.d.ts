import { ConfigService } from '@nestjs/config';
export interface IAppConfig {
    NODE_ENV: string;
    PORT: number;
    CLIENT_URL: string;
    DB_HOST: string;
    DB_PORT: number;
    DB_USERNAME: string;
    DB_PASSWORD: string;
    DB_DATABASE: string;
    JWT_SECRET: string;
    JWT_EXPIRATION_TIME: string;
    STRIPE_SECRET_KEY: string;
    STRIPE_WEBHOOK_SECRET: string;
}
export declare class AppConfigService implements IAppConfig {
    private configService;
    constructor(configService: ConfigService);
    get NODE_ENV(): string;
    get PORT(): number;
    get CLIENT_URL(): string;
    get DB_HOST(): string;
    get DB_PORT(): number;
    get DB_USERNAME(): string;
    get DB_PASSWORD(): string;
    get DB_DATABASE(): string;
    get JWT_SECRET(): string;
    get JWT_EXPIRATION_TIME(): string;
    get STRIPE_SECRET_KEY(): string;
    get STRIPE_WEBHOOK_SECRET(): string;
}
