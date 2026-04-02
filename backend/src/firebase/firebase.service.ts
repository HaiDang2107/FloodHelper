import { Injectable, OnModuleInit, Logger } from '@nestjs/common';
import * as admin from 'firebase-admin';

@Injectable()
export class FirebaseService implements OnModuleInit {
  private readonly logger = new Logger(FirebaseService.name);

  onModuleInit() {
    if (admin.apps.length === 0) {
      const projectId = process.env.FIREBASE_PROJECT_ID;
      const clientEmail = process.env.FIREBASE_CLIENT_EMAIL;
      const privateKey = process.env.FIREBASE_PRIVATE_KEY;

      if (!projectId || !clientEmail || !privateKey) {
        this.logger.error(
          'Missing Firebase environment variables. Required: FIREBASE_PROJECT_ID, FIREBASE_CLIENT_EMAIL, FIREBASE_PRIVATE_KEY',
        );
        throw new Error('Firebase Admin SDK configuration is missing');
      }

      admin.initializeApp({
        credential: admin.credential.cert({
          projectId,
          clientEmail,
          // Private key in .env is usually stored with escaped newlines.
          privateKey: privateKey.replace(/\\n/g, '\n'),
        }),
      });

      this.logger.log('Firebase Admin SDK initialized from environment');
    }
  }

  /**
   * Send a push notification to a specific device
   */
  async sendNotification(
    fcmToken: string,
    title: string,
    body: string,
    data?: Record<string, string>,
  ): Promise<boolean> {
    try {
      const message: admin.messaging.Message = {
        token: fcmToken,
        notification: {
          title,
          body,
        },
        data: data || {},
        android: {
          priority: 'high',
          notification: {
            channelId: 'friend_requests',
            priority: 'high',
            sound: 'default',
          },
        },
      };

      const response = await admin.messaging().send(message);
      this.logger.log(`Notification sent successfully: ${response}`);
      return true;
    } catch (error) {
      this.logger.error(`Failed to send notification: ${error.message}`);
      return false;
    }
  }

  /**
   * Send notification to multiple devices
   */
  async sendMulticastNotification(
    fcmTokens: string[],
    title: string,
    body: string,
    data?: Record<string, string>,
  ): Promise<void> {
    if (fcmTokens.length === 0) return;

    try {
      const message: admin.messaging.MulticastMessage = {
        tokens: fcmTokens,
        notification: {
          title,
          body,
        },
        data: data || {},
        android: {
          priority: 'high',
          notification: {
            channelId: 'friend_requests',
            priority: 'high',
            sound: 'default',
          },
        },
      };

      const response = await admin.messaging().sendEachForMulticast(message);
      this.logger.log(
        `Multicast sent: ${response.successCount} success, ${response.failureCount} failures`,
      );
    } catch (error) {
      this.logger.error(
        `Failed to send multicast notification: ${error.message}`,
      );
    }
  }
}
