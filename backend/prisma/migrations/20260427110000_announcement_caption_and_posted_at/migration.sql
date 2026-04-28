/*
  AnnouncementFromBenefactor phase-1 updates:
  - Rename text_content -> caption
  - Add posted_at with deterministic backfill for existing rows
*/

-- Rename column text_content to caption
ALTER TABLE "AnnouncementFromBenefactor"
RENAME COLUMN "text_content" TO "caption";

-- Add posted_at and backfill existing rows before making it required
ALTER TABLE "AnnouncementFromBenefactor"
ADD COLUMN "posted_at" TIMESTAMP(3);

UPDATE "AnnouncementFromBenefactor"
SET "posted_at" = NOW()
WHERE "posted_at" IS NULL;

ALTER TABLE "AnnouncementFromBenefactor"
ALTER COLUMN "posted_at" SET NOT NULL,
ALTER COLUMN "posted_at" SET DEFAULT CURRENT_TIMESTAMP;
