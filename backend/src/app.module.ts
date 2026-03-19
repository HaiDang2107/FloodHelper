import { Module, MiddlewareConsumer } from '@nestjs/common';
import { MailerModule } from '@nestjs-modules/mailer';
import { CacheModule } from '@nestjs/cache-manager';
import * as redisStore from 'cache-manager-redis-store';
import { AppController } from './app.controller';
import { AppService } from './app.service';
import { UserModule } from './user/user.module';
import { AuthModule } from './auth/auth.module';
import { FriendModule } from './friend/friend.module';
import { FirebaseModule } from './firebase/firebase.module';
import { LoggingMiddleware } from './common/logging.middleware';

@Module({
  imports: [
    UserModule, 
    AuthModule,
    FriendModule,
    FirebaseModule,
    CacheModule.register({
      isGlobal: true, // Để dùng ở mọi nơi không cần import lại
      store: redisStore,
      host: process.env.REDIS_HOST,
      port: process.env.REDIS_PORT
    }),
    MailerModule.forRoot({
      transport: {
        host: process.env.EMAIL_HOST,
        port: Number(process.env.EMAIL_PORT ?? 587),
        secure: process.env.EMAIL_SECURE === 'true',
        connectionTimeout: Number(process.env.EMAIL_CONNECTION_TIMEOUT_MS ?? 10000),
        greetingTimeout: Number(process.env.EMAIL_GREETING_TIMEOUT_MS ?? 10000),
        socketTimeout: Number(process.env.EMAIL_SOCKET_TIMEOUT_MS ?? 20000),
        auth: {
          user: process.env.EMAIL_USER,
          pass: process.env.EMAIL_PASSWORD,
        },
      },
    }),
  ],
  controllers: [AppController],
  providers: [AppService],
})
export class AppModule {
  configure(consumer: MiddlewareConsumer) {
    consumer.apply(LoggingMiddleware).forRoutes('*');
  }
}
