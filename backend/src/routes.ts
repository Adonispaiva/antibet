import { Router } from 'express';
import { AiInterventionController } from './controllers/AiInterventionController';

const routes = Router();

// Instâncias dos Controladores
const aiController = new AiInterventionController();

// === ROTA DE VERIFICAÇÃO (HEALTH CHECK) ===
routes.get('/', (req, res) => {
  return res.json({ 
    application: 'AntiBet API', 
    status: 'online', 
    version: '1.0.0' 
  });
});

// === ROTAS DE INTELIGÊNCIA ARTIFICIAL (NOVO CORE) ===
// Endpoint principal: Recebe { userId, message } e retorna a resposta do Agente
routes.post('/ai/chat', aiController.handleChat);

// === ROTAS DE USUÁRIO E AUTENTICAÇÃO (PREVISTAS) ===
// Futuras integrações de rotas de usuário virão aqui.
// Ex: routes.post('/auth/login', authController.login);

export default routes;