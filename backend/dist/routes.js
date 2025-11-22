"use strict";
Object.defineProperty(exports, "__esModule", { value: true });
const express_1 = require("express");
const AiInterventionController_1 = require("./controllers/AiInterventionController");
const routes = (0, express_1.Router)();
const aiController = new AiInterventionController_1.AiInterventionController();
routes.get('/', (req, res) => {
    return res.json({
        application: 'AntiBet API',
        status: 'online',
        version: '1.0.0'
    });
});
routes.post('/ai/chat', aiController.handleChat);
exports.default = routes;
//# sourceMappingURL=routes.js.map