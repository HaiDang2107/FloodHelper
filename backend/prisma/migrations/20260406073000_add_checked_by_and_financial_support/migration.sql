-- Add checked_by to CharityCampaign
ALTER TABLE "CharityCampaign"
ADD COLUMN "checked_by" UUID;

-- Link checker to User
ALTER TABLE "CharityCampaign"
ADD CONSTRAINT "CharityCampaign_checked_by_fkey"
FOREIGN KEY ("checked_by") REFERENCES "User"("user_id")
ON DELETE SET NULL
ON UPDATE CASCADE;

-- Create FinancialSupport table
CREATE TABLE "FinancialSupport" (
  "financial_support_id" UUID NOT NULL,
  "campaign_id" UUID NOT NULL,
  "household_name" TEXT NOT NULL,
  "amount" DECIMAL(15,2) NOT NULL,
  "allocated_at" TIMESTAMP(3) NOT NULL,

  CONSTRAINT "FinancialSupport_pkey" PRIMARY KEY ("financial_support_id")
);

-- Link FinancialSupport to CharityCampaign
ALTER TABLE "FinancialSupport"
ADD CONSTRAINT "FinancialSupport_campaign_id_fkey"
FOREIGN KEY ("campaign_id") REFERENCES "CharityCampaign"("campaign_id")
ON DELETE RESTRICT
ON UPDATE CASCADE;
