# Authentication API Documentation

This document reflects the current auth module structure and endpoint naming in this repository.

## Implementation Location

- Module: src/auth/auth.module.ts
- Controller: src/auth/auth.controller.ts
- Service: src/auth/auth.service.ts
- DTOs: src/auth/dto
- Guards: src/auth/guards
- Strategies: src/auth/strategies

## Current Endpoints

Base path: /auth.

1. POST /auth/signup.

- Create account and trigger verification flow.

1. POST /auth/verify.

- Verify account using code.

1. POST /auth/resend-code.

- Re-send verification code.

1. POST /auth/signin.

- Sign in standard user.
- Sets refresh token cookie.

1. POST /auth/authority/signin.

- Sign in authority role user.
- Sets refresh token cookie.

1. DELETE /auth/signout.

- Requires JWT auth.
- Clears refresh token cookie.

1. POST /auth/password/forgot.

- Trigger forgot-password flow.

1. POST /auth/password/reset.

- Requires JWT auth.
- Reset password for authenticated account.

1. POST /auth/token/refresh.

- Reads refresh token from cookie and returns new access token.

## Contract Rule

If this file differs from controller/service code, treat src/auth/auth.controller.ts and related DTO files as source of truth.
