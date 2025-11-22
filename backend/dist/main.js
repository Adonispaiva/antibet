"use strict";
Object.defineProperty(exports, "__esModule", { value: true });
const core_1 = require("@nestjs/core");
const app_module_1 = require("./app.module");
const common_1 = require("@nestjs/common");
const bodyParser = require("body-parser");
const logger = new common_1.Logger('Bootstrap');
async function bootstrap() {
    const app = await core_1.NestFactory.create(app_module_1.AppModule, {
        bufferLogs: true,
    });
    app.useGlobalPipes(new common_1.ValidationPipe({
        whitelist: true,
        transform: true,
    }));
    app.enableCors({
        origin: true,
        methods: 'GET,HEAD,PUT,PATCH,POST,DELETE',
        credentials: true,
    });
    app.use((req, res, next) => {
        if (req.originalUrl === '/payments/webhook/stripe') {
            bodyParser.raw({ type: '*/*', limit: '5mb' })(req, res, next);
        }
        else {
            bodyParser.json()(req, res, next);
        }
    });
    app.setGlobalPrefix('api/v1');
    const port = process.env.PORT || 3000;
    await app.listen(port);
    logger.log(`API AntiBet rodando em: http://localhost:${port}/api/v1`);
}
bootstrap();
//# sourceMappingURL=main.js.map