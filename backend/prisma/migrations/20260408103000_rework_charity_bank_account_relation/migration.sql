-- Rework bank account relation:
-- - CharityCampaign now references one bank account via bank_account_id
-- - BankAccount no longer references campaign_id
-- - Bank identity is unique by (bank_name, bank_account_number)
-- - Remove BankAccount.balance

ALTER TABLE "CharityCampaign"
ADD COLUMN "bank_account_id" UUID;

-- Backfill bank_account_id from the old relation (pick one account per campaign).
UPDATE "CharityCampaign" cc
SET "bank_account_id" = ba."bank_account_id"
FROM (
  SELECT DISTINCT ON ("campaign_id")
    "campaign_id",
    "bank_account_id"
  FROM "BankAccount"
  ORDER BY "campaign_id", "bank_account_id"
) ba
WHERE cc."campaign_id" = ba."campaign_id";

-- Canonicalize references so duplicated account records map to a single bank account id.
UPDATE "CharityCampaign" cc
SET "bank_account_id" = canonical."canonical_id"
FROM "BankAccount" ba
JOIN (
  SELECT DISTINCT ON ("bank_name", "bank_account_number")
    "bank_name",
    "bank_account_number",
    "bank_account_id" AS "canonical_id"
  FROM "BankAccount"
  ORDER BY "bank_name", "bank_account_number", "bank_account_id"
) canonical
  ON canonical."bank_name" = ba."bank_name"
 AND canonical."bank_account_number" = ba."bank_account_number"
WHERE cc."bank_account_id" = ba."bank_account_id";

-- Remove duplicated bank account rows after repointing campaigns.
DELETE FROM "BankAccount" ba
USING (
  SELECT DISTINCT ON ("bank_name", "bank_account_number")
    "bank_name",
    "bank_account_number",
    "bank_account_id" AS "canonical_id"
  FROM "BankAccount"
  ORDER BY "bank_name", "bank_account_number", "bank_account_id"
) canonical
WHERE ba."bank_name" = canonical."bank_name"
  AND ba."bank_account_number" = canonical."bank_account_number"
  AND ba."bank_account_id" <> canonical."canonical_id";

ALTER TABLE "BankAccount"
DROP CONSTRAINT IF EXISTS "BankAccount_campaign_id_fkey";

ALTER TABLE "BankAccount"
DROP COLUMN IF EXISTS "campaign_id",
DROP COLUMN IF EXISTS "balance";

CREATE UNIQUE INDEX IF NOT EXISTS "BankAccount_bank_name_bank_account_number_key"
ON "BankAccount"("bank_name", "bank_account_number");

ALTER TABLE "CharityCampaign"
ADD CONSTRAINT "CharityCampaign_bank_account_id_fkey"
FOREIGN KEY ("bank_account_id") REFERENCES "BankAccount"("bank_account_id")
ON DELETE SET NULL ON UPDATE CASCADE;
