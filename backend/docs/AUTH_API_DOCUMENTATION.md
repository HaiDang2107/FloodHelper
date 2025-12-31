# Authentication API Documentation

## Overview

This document defines the API endpoints, DTOs, and business logic for the authentication system based on the Prisma schema.

**📁 Implementation Files:**
- DTOs: `src/auth/dto/`
- Controllers: `src/auth/controllers/`
- Services: `src/auth/services/`
- Documentation: `docs/AUTH_API_DOCUMENTATION.md`

## Models Overview

### User
- `userId`: UUID primary key
- `name`: Full name
- `displayName`: Display name (optional)
- `phoneNumber`: Unique phone number
- `role`: Array of roles (default: ["GUEST"])

### Account
- `accountId`: UUID primary key
- `userId`: Reference to User
- `username`: Unique username
- `password`: Hashed password
- `providerId`: OAuth provider (optional)
- `state`: Account state ("ACTIVE", "INACTIVE", etc.)

### Session
- `sessionId`: UUID primary key
- `accountId`: Reference to Account
- `refreshToken`: JWT refresh token
- `role`: Current role for session
- `expireAt`: Token expiration

### VerificationCode
- `verificationId`: UUID primary key
- `accountId`: Reference to Account
- `code`: Verification code
- `type`: Code type ("PASSWORD_RESET", "ACCOUNT_CREATION", etc.)
- `expiresAt`: Expiration timestamp

---

## 1. User Registration

### Endpoint
```
POST /auth/register
```

### Request DTO
```typescript
export class RegisterDto {
  // User information
  name: string;
  displayName?: string;
  phoneNumber?: string;
  dob?: Date;
  village?: string;
  district?: string;
  country?: string;
  jobPosition?: string;

  // Account information
  username: string;
  password: string;
}
```

### Response DTO
```typescript
export class RegisterResponseDto {
  success: boolean;
  message: string;
  data: {
    user: {
      userId: string;
      name: string;
      displayName?: string;
      phoneNumber: string;
      role: string[];
    };
    account: {
      accountId: string;
      username: string;
      state: string;
    };
    verificationCode?: {
      verificationId: string;
      expiresAt: Date;
    };
  };
}
```

### Business Logic
1. Validate input data
2. Check if phone number already exists
3. Check if username already exists
4. Create User record
5. Hash password and create Account record
6. Generate verification code for email/phone verification
7. Send verification code via SMS/email
8. Return success response

### Error Responses
- `400 Bad Request`: Invalid input data
- `409 Conflict`: Phone number or username already exists
- `500 Internal Server Error`: Database error

---

## 2. User Login

### Endpoint
```
POST /auth/login
```

### Request DTO
```typescript
export class LoginDto {
  username: string;
  password: string;
  deviceId?: string; // For session tracking
}
```

### Response DTO
```typescript
export class LoginResponseDto {
  success: boolean;
  message: string;
  data: {
    user: {
      userId: string;
      name: string;
      displayName?: string;
      phoneNumber: string;
      role: string[];
      avatarUrl?: string;
    };
    tokens: {
      accessToken: string;
      refreshToken: string;
      expiresIn: number;
    };
    session: {
      sessionId: string;
      expireAt: Date;
    };
  };
}
```

### Business Logic
1. Find account by username
2. Verify account state is "ACTIVE"
3. Compare hashed password
4. Get user information
5. Generate JWT access token and refresh token
6. Create session record
7. Return tokens and user data

### Error Responses
- `400 Bad Request`: Invalid credentials
- `403 Forbidden`: Account is inactive/suspended
- `500 Internal Server Error`: Database error

---

## 3. User Logout

### Endpoint
```
POST /auth/logout
```

### Headers
```
Authorization: Bearer <access_token>
```

### Request DTO
```typescript
export class LogoutDto {
  sessionId?: string; // Optional, logout specific session
  logoutAll?: boolean; // Optional, logout from all devices
}
```

### Response DTO
```typescript
export class LogoutResponseDto {
  success: boolean;
  message: string;
  data: {
    loggedOutSessions: number;
  };
}
```

### Business Logic
1. Verify JWT token
2. Get account from token
3. Delete session(s) based on request
4. Return success response

### Error Responses
- `401 Unauthorized`: Invalid token
- `500 Internal Server Error`: Database error

---

## 4. Google OAuth Login

### Endpoints
```
GET /auth/google
POST /auth/google/callback
```

### Google Login Flow
1. **Initiate Google Login** (`GET /auth/google`)
   - Redirect to Google OAuth consent screen
   - State parameter for CSRF protection

2. **Google Callback** (`POST /auth/google/callback`)
   - Receive authorization code from Google
   - Exchange code for access token
   - Get user info from Google
   - Create/update user and account records

### Request DTO (for callback)
```typescript
export class GoogleCallbackDto {
  code: string; // Authorization code from Google
  state: string; // CSRF protection
  deviceId?: string;
}
```

### Response DTO
```typescript
export class GoogleLoginResponseDto {
  success: boolean;
  message: string;
  data: {
    user: {
      userId: string;
      name: string;
      displayName?: string;
      phoneNumber?: string;
      role: string[];
      avatarUrl?: string;
    };
    tokens: {
      accessToken: string;
      refreshToken: string;
      expiresIn: number;
    };
    session: {
      sessionId: string;
      expireAt: Date;
    };
    isNewUser: boolean; // True if account was just created
  };
}
```

### Business Logic
1. Validate authorization code with Google
2. Get user profile from Google
3. Check if user exists (by email/phone)
4. Create new user/account if not exists
5. Link Google provider to account
6. Generate JWT tokens
7. Create session
8. Return response

### Error Responses
- `400 Bad Request`: Invalid authorization code
- `500 Internal Server Error`: Google API error

---

## 5. Forgot Password

### Endpoints
```
POST /auth/forgot-password
POST /auth/reset-password
```

### 5.1 Request Password Reset

#### Endpoint
```
POST /auth/forgot-password
```

#### Request DTO
```typescript
export class ForgotPasswordDto {
  username: string; // or email/phone depending on implementation
}
```

#### Response DTO
```typescript
export class ForgotPasswordResponseDto {
  success: boolean;
  message: string;
  data: {
    verificationId: string;
    expiresAt: Date;
  };
}
```

#### Business Logic
1. Find account by username
2. Check if account exists and is active
3. Generate verification code
4. Create VerificationCode record
5. Send code via SMS/email
6. Return success (don't reveal if account exists or not for security)

### 5.2 Reset Password

#### Endpoint
```
POST /auth/reset-password
```

#### Request DTO
```typescript
export class ResetPasswordDto {
  verificationId: string;
  code: string;
  newPassword: string;
}
```

#### Response DTO
```typescript
export class ResetPasswordResponseDto {
  success: boolean;
  message: string;
}
```

#### Business Logic
1. Find verification code by ID
2. Verify code matches and hasn't expired
3. Check code type is "PASSWORD_RESET"
4. Hash new password
5. Update account password
6. Mark verification code as used
7. Delete or expire the verification code
8. Return success

### Error Responses
- `400 Bad Request`: Invalid code or expired
- `404 Not Found`: Verification code not found
- `500 Internal Server Error`: Database error

---

## 6. Token Refresh

### Endpoint
```
POST /auth/refresh
```

### Request DTO
```typescript
export class RefreshTokenDto {
  refreshToken: string;
}
```

### Response DTO
```typescript
export class RefreshTokenResponseDto {
  success: boolean;
  message: string;
  data: {
    tokens: {
      accessToken: string;
      refreshToken: string;
      expiresIn: number;
    };
  };
}
```

### Business Logic
1. Verify refresh token
2. Get account from token
3. Generate new access token
4. Optionally generate new refresh token
5. Update session expiration
6. Return new tokens

---

## Common DTOs

### Error Response
```typescript
export class ErrorResponseDto {
  success: false;
  message: string;
  error: {
    code: string;
    details?: any;
  };
}
```

### User Profile DTO
```typescript
export class UserProfileDto {
  userId: string;
  name: string;
  displayName?: string;
  phoneNumber: string;
  role: string[];
  avatarUrl?: string;
  dob?: Date;
  village?: string;
  district?: string;
  country?: string;
  jobPosition?: string;
  curLongitude?: number;
  curLatitude?: number;
  publicMapMode: boolean;
}
```

---

## Security Considerations

1. **Password Hashing**: Use bcrypt with salt rounds >= 10
2. **JWT Tokens**: Use strong secrets, set appropriate expiration
3. **Rate Limiting**: Implement rate limiting for auth endpoints
4. **Input Validation**: Validate all inputs using class-validator
5. **HTTPS Only**: All auth endpoints must use HTTPS
6. **Session Management**: Implement proper session cleanup
7. **Verification Codes**: Short expiration time, one-time use

## Implementation Notes

1. **Dependencies Required:**
   ```json
   {
     "@nestjs/jwt": "^10.0.0",
     "@nestjs/passport": "^10.0.0",
     "passport": "^0.6.0",
     "passport-google-oauth20": "^2.0.0",
     "bcrypt": "^5.1.1",
     "class-validator": "^0.14.0",
     "class-transformer": "^0.5.1"
   }
   ```

2. **Environment Variables:**
   ```env
   JWT_SECRET=your-jwt-secret
   JWT_EXPIRES_IN=15m
   JWT_REFRESH_EXPIRES_IN=7d
   
   GOOGLE_CLIENT_ID=your-google-client-id
   GOOGLE_CLIENT_SECRET=your-google-client-secret
   GOOGLE_CALLBACK_URL=http://localhost:3000/auth/google/callback
   
   SMS_API_KEY=your-sms-api-key
   EMAIL_API_KEY=your-email-api-key
   ```

3. **Use `@nestjs/jwt` for JWT token management**
4. **Use `@nestjs/passport` for OAuth integration**
5. **Use `bcrypt` for password hashing**
6. **Implement proper error handling and logging**
7. **Use transactions for multi-step operations**
8. **Implement proper CORS and security headers**