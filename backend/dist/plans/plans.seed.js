"use strict";
Object.defineProperty(exports, "__esModule", { value: true });
exports.PLANS_SEED_DATA = void 0;
exports.PLANS_SEED_DATA = [
    {
        name: 'Free',
        description: 'Funcionalidade básica com respostas normais.',
        price: 0.00,
        aiTokens: 10,
        stripePriceId: 'PLAN-FREE-INTERNAL',
        isSubscription: false,
    },
    {
        name: 'Autocontrole',
        description: 'Voz do avatar (TTS), dark mode e alertas personalizados.',
        price: 14.90,
        aiTokens: 25,
        stripePriceId: 'price_1Pcb4fPRIg9s8yJVALZUZI6M3YX',
        isSubscription: true,
    },
    {
        name: 'Fortaleza',
        description: 'Tudo do anterior + Relatórios de uso/bloqueios e recomendações.',
        price: 29.90,
        aiTokens: 45,
        stripePriceId: 'price_1Pcb5hPRIg9s8yJVALZUZI6M3YJ',
        isSubscription: true,
    },
    {
        name: 'Liberdade',
        description: 'Uso total com todos os recursos adicionais e controles diversos.',
        price: 49.90,
        aiTokens: 70,
        stripePriceId: 'price_1Pcb5hPRIg9s8yJVALZUZI6M3YX',
        isSubscription: true,
    },
];
//# sourceMappingURL=plans.seed.js.map