import { Injectable } from '@nestjs/common';
import { RegisterAuthDto } from './dto/signup-auth.dto';
import { LoginAuthDto } from './dto/signin-auth.dto';

@Injectable()
export class AuthService {
  register(registerAuthDto: RegisterAuthDto) {
    // TODO: Implement user registration
    // 1. Validate input (username, email, password)
    // 2. Check if username/email already exists
    // 3. Hash password
    // 4. Create account in database
    // 5. Return success response with account info
    return { message: 'User registered successfully' };
  }

  login(loginAuthDto: LoginAuthDto) {
    // TODO: Implement user login
    // 1. Validate input (username, password)
    // 2. Find account by username
    // 3. Verify password
    // 4. Generate JWT token
    // 5. Return token and account info
    return { message: 'Login successful', token: null };
  }
}
