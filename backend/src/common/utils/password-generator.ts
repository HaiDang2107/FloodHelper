import { randomBytes } from 'crypto';

/**
 * Generate a secure random password
 * Requirements: 8-12 characters with uppercase + lowercase + numbers + special chars
 */
export class PasswordGenerator {
  private static readonly UPPERCASE = 'ABCDEFGHIJKLMNOPQRSTUVWXYZ';
  private static readonly LOWERCASE = 'abcdefghijklmnopqrstuvwxyz';
  private static readonly NUMBERS = '0123456789';
  private static readonly SPECIAL_CHARS = '!@#$%^&*';
  private static readonly ALL_CHARS = this.UPPERCASE + this.LOWERCASE + this.NUMBERS + this.SPECIAL_CHARS;

  static generate(): string {
    const length = this.getRandomInt(8, 12); // 8-12 characters
    const password: string[] = [];

    // Ensure password contains at least one of each required character type
    password.push(this.getRandomChar(this.UPPERCASE));
    password.push(this.getRandomChar(this.LOWERCASE));
    password.push(this.getRandomChar(this.NUMBERS));
    password.push(this.getRandomChar(this.SPECIAL_CHARS));

    // Fill remaining positions with random characters from all available
    for (let i = password.length; i < length; i++) {
      password.push(this.getRandomChar(this.ALL_CHARS));
    }

    // Shuffle the password array to avoid predictable order
    return this.shuffle(password).join('');
  }

  private static getRandomChar(chars: string): string {
    const randomByte = randomBytes(1)[0];
    return chars[randomByte % chars.length];
  }

  private static getRandomInt(min: number, max: number): number {
    const randomByte = randomBytes(1)[0];
    return min + (randomByte % (max - min + 1));
  }

  private static shuffle(array: string[]): string[] {
    const shuffled = [...array];
    for (let i = shuffled.length - 1; i > 0; i--) {
      const j = randomBytes(1)[0] % (i + 1);
      [shuffled[i], shuffled[j]] = [shuffled[j], shuffled[i]];
    }
    return shuffled;
  }
}
