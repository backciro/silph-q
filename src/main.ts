import "reflect-metadata";
// import * as helmet from 'helmet';
import {AppModule} from './app.module';

import {NestFactory} from '@nestjs/core';
import {FastifyAdapter, NestFastifyApplication} from '@nestjs/platform-fastify';

async function bootstrap() {
    const app = await NestFactory.create<NestFastifyApplication>(
        AppModule,
        new FastifyAdapter(),
        {logger: ['error', 'warn', 'log', 'debug', 'verbose']}
    );

    // app.use(helmet());
    app.enableCors();

    await app.listen(parseInt(process.env.PORT) || 8080);
}

bootstrap().then();
