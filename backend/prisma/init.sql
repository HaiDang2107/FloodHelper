-- PostgreSQL initialization script for FloodHelper
-- This file runs when the PostgreSQL container starts for the first time

-- Create database if it doesn't exist (though it's already created via environment variables)
-- The database is created automatically by POSTGRES_DB environment variable

-- You can add any additional initialization here if needed
-- For example, creating additional users, schemas, or running initial data setup

-- Note: Prisma migrations will handle schema creation automatically