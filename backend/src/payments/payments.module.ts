import { Module, forwardRef } from '@nestjs/common';
import { PaymentsService } from './payments.service';
import { PaymentsController } from './payments.controller';
import { PlansModule } from '../plans/plans.module'; // Importa PlansModule
import { UserModule } from '../user/user.module';  // Importa UserModule

@Module({
  imports: [
    // CRÍTICO: Usa forwardRef em PaymentsModule, pois ele é importado pelo PlansModule.
    forwardRef(() => PlansModule), 
    UserModule,  
  ],
  controllers: [PaymentsController],
  providers: [PaymentsService],
  exports: [PaymentsService],
})
export class PaymentsModule {}