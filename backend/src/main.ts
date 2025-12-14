import { NestFactory } from '@nestjs/core';
import { AppModule } from './app.module';
import { AppDataSource } from './data-source';

async function bootstrap() {
  // Initialize database connection
  if (!AppDataSource.isInitialized) {
    await AppDataSource.initialize();
    console.log('Database connected successfully');
  }

  const app = await NestFactory.create(AppModule);
  await app.listen(process.env.PORT ?? 3000);
  console.log(`Application is running on port ${process.env.PORT ?? 3000}`);
}

bootstrap().catch((error) => {
  console.error('Failed to start application:', error);
  process.exit(1);
});
