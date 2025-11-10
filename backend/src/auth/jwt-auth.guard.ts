import { Injectable } from '@nestjs/common';
import { AuthGuard } from '@nestjs/passport';

@Injectable()
// 'jwt' é o nome que definimos na JwtStrategy
export class JwtAuthGuard extends AuthGuard('jwt') {}