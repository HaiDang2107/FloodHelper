-- Add campaign location coordinates (nullable for existing campaigns)
ALTER TABLE "CharityCampaign"
ADD COLUMN "campaign_latitude" DECIMAL(10,7),
ADD COLUMN "campaign_longitude" DECIMAL(10,7);

-- Persist normal user display preference for campaign locations on map
ALTER TABLE "User"
ADD COLUMN "show_charity_campaign_locations" BOOLEAN NOT NULL DEFAULT false;
