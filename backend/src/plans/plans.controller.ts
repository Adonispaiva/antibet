import { Controller, Get, Post, UseGuards, Req, Body, UsePipes, ValidationPipe } from '@nestjs/common';
import { PlansService } from './plans.service';
import { JwtAuthGuard } from '../auth/guards/jwt-auth.guard';
import { InitiateCheckoutDto } from './dto/initiate-checkout.dto'; 

@Controller('plans')
export class PlansController {
  constructor(private readonly plansService: PlansService) {}

  /**
   * Rota pública para buscar todos os planos.
   */
  @Get()
  async findAll() {
    // CORREÇÃO: Chamada correta do método: findAllPlans
    return this.plansService.findAllPlans(); 
  }

  /**
   * Rota protegida para iniciar o processo de checkout.
   */
  @UseGuards(JwtAuthGuard)
  @UsePipes(new ValidationPipe({ whitelist: true, transform: true })) 
  @Post('checkout')
  async initiateCheckout(@Req() req, @Body() checkoutDto: InitiateCheckoutDto) {
    const userId = req.user.id; 
    const { planId } = checkoutDto; 

    // CORREÇÃO: Chamada correta do método: initiateCheckout
    return this.plansService.initiateCheckout(userId, planId); 
  }
}