# Docker Setup for FloodHelper Backend

This guide explains how to run the FloodHelper backend using Docker and Docker Compose.

## Prerequisites

- Docker
- Docker Compose

## Quick Start

1. **Clone the repository and navigate to backend directory:**
   ```bash
   cd /path/to/FloodHelper/backend
   ```

2. **Copy environment file:**
   ```bash
   cp .env.example .env
   ```

3. **Update the `.env` file with your configuration:**
   ```env
   DB_HOST="localhost"
   DB_PORT=5432
   DB_NAME="floodhelper"
   DB_USER="floodhelper_user"
   DB_PASSWORD="floodhelper_password"
   DB_SCHEMA="public"

   REDIS_HOST="localhost"
   REDIS_PORT=6379

   JWT_SECRET="your-jwt-secret-key-here"
   AT_SECRET="your-access-token-secret-here"
   RT_SECRET="your-refresh-token-secret-here"
   PASSWORD_RESET_JWT_SECRET="your-password-reset-secret-here"

   AT_EXPIRES_IN="15m"
   RT_EXPIRES_IN="7d"
   PASSWORD_RESET_EXPIRES_IN="10m"
   ```

4. **Start PostgreSQL database:**
   ```bash
   docker-compose up -d postgres
   ```

5. **Start Redis database:**
   ```bash
   docker-compose up -d redis
   ```

6. **Run Prisma migrations:**
   ```bash
   npx prisma migrate dev
   ```

7. **Seed the database (optional):**
   ```bash
   npx prisma db seed
   ```

8. **Start the application locally:**
   ```bash
   npm run start:dev
   ```

## Docker Commands

### Start all services (PostgreSQL + App):
```bash
docker-compose up -d
```

### Start only PostgreSQL:
```bash
docker-compose up -d postgres
```

### Start only Redis:
```bash
docker-compose up -d redis
```

### Stop all services:
```bash
docker-compose down
```

### View logs:
```bash
docker-compose logs -f
```

### Rebuild and restart:
```bash
docker-compose up --build -f
```

## Database Access

- **Host:** `${DB_HOST}` (default: localhost)
- **Port:** `${DB_PORT}` (default: 5432)
- **Database:** `${DB_NAME}` (default: floodhelper)
- **Username:** `${DB_USER}` (default: floodhelper_user)
- **Password:** `${DB_PASSWORD}` (default: floodhelper_password)
- **Schema:** `${DB_SCHEMA}` (default: public)

## Redis Access

- **Host:** `${REDIS_HOST}` (default: localhost)
- **Port:** `${REDIS_PORT}` (default: 6379)

## Troubleshooting

### Database Connection Issues
1. Ensure PostgreSQL container is running: `docker-compose ps`
2. Check logs: `docker-compose logs postgres`
3. Verify DATABASE_URL in `.env` file

### Redis Connection Issues
1. Ensure Redis container is running: `docker-compose ps`
2. Check logs: `docker-compose logs redis`
3. Verify REDIS_HOST and REDIS_PORT in `.env` file

### Prisma Issues
1. Reset database: `npx prisma migrate reset`
2. Re-generate client: `npx prisma generate`

### Port Conflicts
If port 5432 is already in use, modify the ports in `docker-compose.yml`:
```yaml
ports:
  - "5433:5432"  # Use 5433 instead of 5432
```

## Development Workflow

1. **Database changes:** Modify schema in `prisma/schema/` and run `npx prisma migrate dev`
2. **Code changes:** Make changes to source code, restart app if needed
3. **Testing:** Run `npm test` for unit tests, `npm run test:e2e` for integration tests

## Production Deployment

For production, uncomment the `app` service in `docker-compose.yml` and update environment variables accordingly. Make sure to set strong secrets for JWT tokens and appropriate expiration times:

```yaml
environment:
  AT_EXPIRES_IN: 15m      # Access token expires in 15 minutes
  RT_EXPIRES_IN: 7d       # Refresh token expires in 7 days
  PASSWORD_RESET_EXPIRES_IN: 10m  # Password reset token expires in 10 minutes
```