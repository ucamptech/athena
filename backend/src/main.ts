import { NestFactory } from '@nestjs/core';
import { AppModule } from './app.module';
import { join } from 'path';
import * as express from 'express';
import { NestExpressApplication } from '@nestjs/platform-express';


async function bootstrap() {
  const app = await NestFactory.create<NestExpressApplication>(AppModule);
  app.setGlobalPrefix("api");
  app.use('/images', express.static(join(__dirname,'..','static/images')));
  app.use('/audio', express.static(join(__dirname, '..', 'static/audio')));
  await app.listen(process.env.PORT ?? 3000);
}
bootstrap();
