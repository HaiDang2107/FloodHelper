-- Step 1: Add the new visibility_mode column
ALTER TABLE "User" ADD COLUMN "visibility_mode" VARCHAR(20) NOT NULL DEFAULT 'PUBLIC';

-- Step 2: Migrate existing data (public_map_mode true → PUBLIC, false → JUST_FRIEND)
UPDATE "User" SET "visibility_mode" = CASE
  WHEN "public_map_mode" = true THEN 'PUBLIC'
  ELSE 'JUST_FRIEND'
END;

-- Step 3: Drop the old column
ALTER TABLE "User" DROP COLUMN "public_map_mode";
