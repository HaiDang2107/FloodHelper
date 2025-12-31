# Authentication Module

This module handles user authentication, authorization, and account management.

## Features

- ✅ User registration and login
- ✅ JWT-based authentication with refresh tokens
- ✅ Session management
- ✅ Protected routes with JWT guards
- ✅ Password reset functionality
- ✅ Google OAuth integration (framework ready)
- ✅ Role-based access control

## File Structure

```
src/auth/
├── dto/                    # Data Transfer Objects
│   ├── index.ts           # Export all DTOs
│   ├── register.dto.ts    # Registration DTOs
│   ├── login.dto.ts       # Login DTOs
│   ├── logout.dto.ts      # Logout DTOs
│   ├── forgot-password.dto.ts  # Password reset DTOs
│   ├── refresh-token.dto.ts    # Token refresh DTOs
│   ├── google-callback.dto.ts  # Google OAuth DTOs
│   └── responses.dto.ts   # Response DTOs
├── guards/                # Authentication guards
│   └── jwt-auth.guard.ts  # JWT authentication guard
├── strategies/            # Passport strategies
│   └── jwt.strategy.ts    # JWT strategy for token validation
├── decorators/            # Custom decorators
│   └── current-user.decorator.ts # Get current user from request
├── controllers/           # API endpoints
├── services/             # Business logic
├── index.ts              # Export all auth components
└── README.md             # This file
```

## API Documentation

See `docs/AUTH_API_DOCUMENTATION.md` for detailed API specifications.

## API Endpoints

### Public Endpoints
- `POST /auth/register` - User registration
- `POST /auth/login` - User login
- `POST /auth/forgot-password` - Request password reset
- `POST /auth/reset-password` - Reset password with code
- `POST /auth/refresh` - Refresh access token
- `GET /auth/google` - Initiate Google OAuth
- `POST /auth/google/callback` - Handle Google OAuth callback

### Protected Endpoints
- `POST /auth/logout` - User logout (requires JWT token)

## Usage Examples

### Protecting Routes
```typescript
import { UseGuards } from '@nestjs/common';
import { JwtAuthGuard } from './auth';

@Controller('protected')
export class ProtectedController {
  @UseGuards(JwtAuthGuard)
  @Get('profile')
  getProfile(@CurrentUser() user) {
    return user;
  }
}
```

### Getting Current User
```typescript
import { CurrentUser } from './auth';

@Controller('user')
export class UserController {
  @UseGuards(JwtAuthGuard)
  @Get('me')
  getCurrentUser(@CurrentUser() user) {
    return user;
  }
}
```

## Quick Start

1. Install dependencies
2. Set up environment variables
3. Implement controllers and services
4. Add authentication guards to protected routes

## Security

- Passwords are hashed using bcrypt
- JWT tokens with configurable expiration
- Refresh token rotation
- Protected logout endpoint with JWT guard
- Session-based authentication
- HTTPS required in production