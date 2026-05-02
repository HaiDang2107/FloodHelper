-- Normalize legacy state labels before casting to enum
UPDATE "CharityCampaign"
SET "state" = 'APPROVED'
WHERE UPPER("state") = 'ACCEPTED';

-- Introduce enum for campaign lifecycle states
DO $$
BEGIN
  CREATE TYPE "CampaignState" AS ENUM (
    'CREATED',
    'PENDING',
    'APPROVED',
    'REJECTED',
    'DONATING',
    'DISTRIBUTING',
    'SUSPENDED',
    'FINISHED'
  );
EXCEPTION
  WHEN duplicate_object THEN NULL;
END $$;

-- Convert CharityCampaign.state from TEXT to enum
ALTER TABLE "CharityCampaign"
ALTER COLUMN "state" TYPE "CampaignState"
USING UPPER("state")::"CampaignState";
