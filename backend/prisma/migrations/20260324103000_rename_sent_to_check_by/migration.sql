DO $$
BEGIN
  IF EXISTS (
    SELECT 1 FROM information_schema.columns
    WHERE table_name = 'RoleUpdatingRequest' AND column_name = 'sent_to'
  ) THEN
    ALTER TABLE "RoleUpdatingRequest" RENAME COLUMN "sent_to" TO "check_by";
  END IF;
END
$$;

DO $$
BEGIN
  IF EXISTS (
    SELECT 1 FROM pg_constraint
    WHERE conname = 'RoleUpdatingRequest_sent_to_fkey'
  ) THEN
    ALTER TABLE "RoleUpdatingRequest"
      RENAME CONSTRAINT "RoleUpdatingRequest_sent_to_fkey"
      TO "RoleUpdatingRequest_check_by_fkey";
  END IF;
END
$$;

DROP INDEX IF EXISTS "RoleUpdatingRequest_sent_to_idx";
CREATE INDEX IF NOT EXISTS "RoleUpdatingRequest_check_by_idx"
  ON "RoleUpdatingRequest"("check_by");
