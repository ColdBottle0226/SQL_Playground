import { NestFactory } from '@nestjs/core';
import { AppModule } from './app.module';

async function bootstrap() {
  const app = await NestFactory.create(AppModule);
  app.enableCors({ origin: '*' });
  app.setGlobalPrefix('api');
  await app.listen(4000);
  console.log('🚀 NestJS Backend running on :4000');
}
bootstrap();
