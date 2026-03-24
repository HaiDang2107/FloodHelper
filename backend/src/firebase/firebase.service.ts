import { Injectable, OnModuleInit, Logger } from '@nestjs/common';
import * as admin from 'firebase-admin';
import * as path from 'path';

@Injectable()
export class FirebaseService implements OnModuleInit {
  private readonly logger = new Logger(FirebaseService.name);

  onModuleInit() {
    if (admin.apps.length === 0) {
      const serviceAccountPath = path.join(
        process.cwd(),
        'floodhelper-374c0-firebase-adminsdk-fbsvc-5f8beff8a6.json',
      );

      admin.initializeApp({
        credential: admin.credential.cert(serviceAccountPath),
      });

      this.logger.log('Firebase Admin SDK initialized');
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
