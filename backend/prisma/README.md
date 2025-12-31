# Database Seeding

This guide explains how to seed the database with sample data for development and testing.

## Prerequisites

Make sure you have:
- Node.js installed
- PostgreSQL database running
- Prisma CLI installed globally: `npm install -g prisma`

## Setup

1. **Install dependencies:**
   ```bash
   npm install
   ```

2. **Configure environment variables:**
   Copy `.env.example` to `.env` and update the database connection string:
   ```bash
   cp .env.example .env
   ```

3. **Generate Prisma Client:**
   ```bash
   npx prisma generate
   ```

4. **Run database migrations:**
   ```bash
   npx prisma migrate dev
   ```

## Seeding the Database

Run the seed script to populate the database with sample data:

```bash
npm run db:seed
```

## What Gets Seeded

The seed script creates sample data for all major entities:

### User Roles
Users can have multiple roles from the following:
- **ADMIN**: System administrator
- **AUTHORITY**: Government authority (limited to one user)
- **GUEST**: Regular user
- **BENEFACTOR**: Charity organizer/donor
- **RESCUER**: Emergency rescue personnel

### Users (7 users)
- Nguyễn Văn An (Software Engineer) - **GUEST**
- Trần Thị Bình (Teacher) - **GUEST**
- Lê Văn Cường (Rescue Worker) - **RESCUER**
- Phạm Thị Dung (Doctor) - **BENEFACTOR**
- Hoàng Văn Em (Student) - **BENEFACTOR**
- Trần Văn Minh (Government Official) - **AUTHORITY**
- Nguyễn Thị Lan (System Administrator) - **ADMIN**

### Accounts (5 accounts)
Linked accounts for users with login credentials.

#### Login Credentials:
- **anguyen** (An Nguyen): `password123`
- **btran** (Binh Tran): `password123`
- **cle** (Cuong Le): `rescuer456`
- **mtran** (Minh Tran - AUTHORITY): `authority789`
- **lnguyen** (Lan Nguyen - ADMIN): `admin999`

### Friendships (3 friendships)
- An ↔ Bình (map sharing enabled)
- An ↔ Cường (map sharing disabled)
- Bình ↔ Dung (map sharing enabled)

### Posts (5 posts)
Flood-related posts with images, locations, and timestamps.

### Likes & Comments
Sample interactions on posts.

### Charity Campaigns (2 campaigns)
- "Flood Relief Fund 2023" (Active)
- "Emergency Rescue Equipment" (Completed)

### Transactions (2 transactions)
Donations to the charity campaigns.

### Signals (2 SOS signals)
Emergency distress signals from users.

### Chat Rooms & Messages (2 rooms, 2 messages)
Sample chat conversations.

### Verification Codes (2 codes)
Sample verification codes for password reset and account creation.

## Sample Data Structure

```
Users
├── Accounts (1:1 relationship)
│   └── Verification Codes (1:many)
├── Friendships (many:many)
├── Posts (1:many)
│   ├── Likes (many:many)
│   └── Comments (1:many)
├── Charity Campaigns (organized by users)
│   └── Transactions (donations)
├── Signals (SOS messages)
└── Chat Rooms (created by users)
    └── Messages
```

## Resetting Data

To reset and reseed the database:

```bash
# Reset database (WARNING: This deletes all data)
npx prisma migrate reset

# Re-run migrations
npx prisma migrate dev

# Seed again
npm run db:seed
```

## Viewing Data

You can view the seeded data using Prisma Studio:

```bash
npx prisma studio
```

This opens a web interface at `http://localhost:5555` where you can browse and edit the data.

## Notes

- All UUIDs are pre-defined for consistency
- Passwords are hashed (use proper hashing in production)
- Users can have multiple roles (stored as arrays)
- Locations are centered around Hanoi, Vietnam
- Timestamps are set to realistic dates in October 2023
- The data represents a flood emergency scenario