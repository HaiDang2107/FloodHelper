# Authentication Module

This module handles signup/signin, verification code workflow, refresh token, and password reset.

## Current Structure

- src/auth/auth.controller.ts
- src/auth/auth.service.ts
- src/auth/auth.module.ts
- src/auth/dto
- src/auth/guards
- src/auth/strategies
- src/auth/decorators
- src/auth/interfaces
- src/auth/index.ts

Note: There are no nested controllers or services folders in current layout.

## Current Endpoint Shape

Base path: /auth

- POST /auth/signup
- POST /auth/verify
- POST /auth/resend-code
- POST /auth/signin
- POST /auth/authority/signin
- DELETE /auth/signout
- POST /auth/password/forgot
- POST /auth/password/reset
- POST /auth/token/refresh

## Token Notes

- Refresh token is set as httpOnly cookie during signin.
- Access token is returned in response payload.
- JwtAuthGuard protects signout and password reset routes.

## Source References

- Controller contract: src/auth/auth.controller.ts
- DTO contract: src/auth/dto
- Guard/strategy behavior: src/auth/guards and src/auth/strategies
