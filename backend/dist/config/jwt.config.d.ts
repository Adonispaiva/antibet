import { JwtModuleOptions } from '@nestjs/jwt';
declare const jwtConfig: (() => JwtModuleOptions) & import("@nestjs/config").ConfigFactoryKeyHost<JwtModuleOptions>;
export default jwtConfig;
