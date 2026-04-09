ALTER TABLE "CharityCampaign"
  RENAME COLUMN "start_donation_at" TO "started_donation_at";

ALTER TABLE "CharityCampaign"
  RENAME COLUMN "finish_donation_at" TO "finished_donation_at";

ALTER TABLE "CharityCampaign"
  RENAME COLUMN "start_distribution_at" TO "started_distribution_at";

ALTER TABLE "CharityCampaign"
  RENAME COLUMN "finish_distribution_at" TO "finished_distribution_at";
