ALTER TABLE "CharityCampaign"
  RENAME COLUMN "note_by_authority" TO "note_for_response";

ALTER TABLE "CharityCampaign"
  ADD COLUMN IF NOT EXISTS "suspended_at" TIMESTAMP(3),
  ADD COLUMN IF NOT EXISTS "note_for_suspension" TEXT;
