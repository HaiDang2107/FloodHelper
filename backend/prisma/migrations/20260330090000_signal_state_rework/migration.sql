-- Create enum for signal state
DO $$ BEGIN
  CREATE TYPE "SignalState" AS ENUM ('BROADCASTING', 'HANDLED', 'STOPPED');
EXCEPTION
  WHEN duplicate_object THEN null;
END $$;

-- Rename existing boolean columns and convert to integer counters
ALTER TABLE "Signal" RENAME COLUMN "has_children" TO "children_num";
ALTER TABLE "Signal" RENAME COLUMN "has_elderly" TO "elderly_num";
ALTER TABLE "Signal" RENAME COLUMN "deleted_at" TO "stopped_at";

ALTER TABLE "Signal"
  ALTER COLUMN "children_num" DROP DEFAULT,
  ALTER COLUMN "elderly_num" DROP DEFAULT;

ALTER TABLE "Signal"
  ALTER COLUMN "children_num" TYPE INTEGER USING CASE WHEN "children_num" THEN 1 ELSE 0 END,
  ALTER COLUMN "children_num" SET DEFAULT 0,
  ALTER COLUMN "children_num" SET NOT NULL,
  ALTER COLUMN "elderly_num" TYPE INTEGER USING CASE WHEN "elderly_num" THEN 1 ELSE 0 END,
  ALTER COLUMN "elderly_num" SET DEFAULT 0,
  ALTER COLUMN "elderly_num" SET NOT NULL;

-- Add new fields
ALTER TABLE "Signal"
  ADD COLUMN IF NOT EXISTS "has_water" BOOLEAN NOT NULL DEFAULT false,
  ADD COLUMN IF NOT EXISTS "handled_by" UUID,
  ADD COLUMN IF NOT EXISTS "state" "SignalState" NOT NULL DEFAULT 'BROADCASTING';

-- Backfill state based on legacy timestamps
UPDATE "Signal"
SET "state" = CASE
  WHEN "stopped_at" IS NOT NULL THEN 'STOPPED'::"SignalState"
  WHEN "handled_at" IS NOT NULL THEN 'HANDLED'::"SignalState"
  ELSE 'BROADCASTING'::"SignalState"
END;

-- Add FK for handled_by
DO $$ BEGIN
  ALTER TABLE "Signal"
    ADD CONSTRAINT "Signal_handled_by_fkey"
    FOREIGN KEY ("handled_by") REFERENCES "User"("user_id")
    ON DELETE SET NULL ON UPDATE CASCADE;
EXCEPTION
  WHEN duplicate_object THEN null;
END $$;

-- Add indexes for common queries
CREATE INDEX IF NOT EXISTS "Signal_created_by_idx" ON "Signal"("created_by");
CREATE INDEX IF NOT EXISTS "Signal_handled_by_idx" ON "Signal"("handled_by");
CREATE INDEX IF NOT EXISTS "Signal_state_idx" ON "Signal"("state");

-- Enforce one active broadcasting signal per creator
CREATE UNIQUE INDEX IF NOT EXISTS "Signal_created_by_broadcasting_key"
ON "Signal"("created_by")
WHERE "state" = 'BROADCASTING'::"SignalState";
