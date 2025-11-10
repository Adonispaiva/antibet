import { Plan } from './entities/plan.entity';

// Dados de Planos FINAIS, baseados na planilha do produto.
// OS IDS FORAM ATUALIZADOS COM BASE NO SEU ARQUIVO ANOTADO.
export const PLANS_SEED_DATA: Partial<Plan>[] = [
  {
    name: 'Free',
    description: 'Funcionalidade básica com respostas normais.',
    price: 0.00,
    aiTokens: 10, // 10 tokens/dia
    stripePriceId: 'PLAN-FREE-INTERNAL', // ID Interno para o Plano Gratuito
    isSubscription: false,
  },
  {
    name: 'Autocontrole',
    description: 'Voz do avatar (TTS), dark mode e alertas personalizados.',
    price: 14.90,
    aiTokens: 25, // 25 tokens/dia
    stripePriceId: 'price_1Pcb4fPRIg9s8yJVALZUZI6M3YX', // ID REAL DO STRIPE (Autocontrole)
    isSubscription: true,
  },
  {
    name: 'Fortaleza',
    description: 'Tudo do anterior + Relatórios de uso/bloqueios e recomendações.',
    price: 29.90,
    aiTokens: 45, // 45 tokens/dia
    stripePriceId: 'price_1Pcb5hPRIg9s8yJVALZUZI6M3YJ', // ID REAL DO STRIPE (Fortaleza)
    isSubscription: true,
  },
  {
    name: 'Liberdade',
    description: 'Uso total com todos os recursos adicionais e controles diversos.',
    price: 49.90,
    aiTokens: 70, // 70 tokens/dia
    stripePriceId: 'price_1Pcb5hPRIg9s8yJVALZUZI6M3YX', // ID REAL DO STRIPE (Liberdade)
    isSubscription: true,
  },
];