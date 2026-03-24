-- User contract migration
ALTER TABLE "User" RENAME COLUMN "name" TO "fullname";
ALTER TABLE "User" RENAME COLUMN "display_name" TO "nickname";

ALTER TABLE "User" DROP COLUMN IF EXISTS "village";
ALTER TABLE "User" DROP COLUMN IF EXISTS "district";
ALTER TABLE "User" DROP COLUMN IF EXISTS "country";

ALTER TABLE "User" ADD COLUMN "place_of_origin" TEXT;
ALTER TABLE "User" ADD COLUMN "place_of_residence" TEXT;
ALTER TABLE "User" ADD COLUMN "date_of_issue" DATE;
ALTER TABLE "User" ADD COLUMN "date_of_expire" DATE;

ALTER TABLE "User" ALTER COLUMN "role" SET DEFAULT ARRAY['NORMAL_USER']::TEXT[];
UPDATE "User"
SET "role" = array_replace("role", 'GUEST', 'NORMAL_USER')
WHERE "role" @> ARRAY['GUEST']::TEXT[];

-- Role update request constraints
DO $$
BEGIN
  IF NOT EXISTS (SELECT 1 FROM pg_type WHERE typname = 'RoleRequestType') THEN
    CREATE TYPE "RoleRequestType" AS ENUM ('BENEFACTOR', 'RESCUER');
  END IF;
END
$$;

DO $$
BEGIN
  IF NOT EXISTS (SELECT 1 FROM pg_type WHERE typname = 'RoleRequestState') THEN
    CREATE TYPE "RoleRequestState" AS ENUM ('PENDING', 'APPROVED', 'REJECTED');
  END IF;
END
$$;

UPDATE "RoleUpdatingRequest"
SET "type" = CASE
  WHEN UPPER("type") = 'RESCUER' THEN 'RESCUER'
  ELSE 'BENEFACTOR'
END;

UPDATE "RoleUpdatingRequest"
SET "state" = CASE
  WHEN UPPER("state") = 'APPROVED' THEN 'APPROVED'
  WHEN UPPER("state") = 'REJECTED' THEN 'REJECTED'
  ELSE 'PENDING'
END;

ALTER TABLE "RoleUpdatingRequest"
  ALTER COLUMN "type" TYPE "RoleRequestType"
  USING "type"::"RoleRequestType";

ALTER TABLE "RoleUpdatingRequest"
  ALTER COLUMN "state" TYPE "RoleRequestState"
  USING "state"::"RoleRequestState";

ALTER TABLE "RoleUpdatingRequest"
  ALTER COLUMN "state" SET DEFAULT 'PENDING';
