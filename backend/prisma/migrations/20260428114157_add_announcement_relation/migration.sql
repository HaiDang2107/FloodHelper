-- AddForeignKey
ALTER TABLE "AnnouncementFromBenefactor" ADD CONSTRAINT "AnnouncementFromBenefactor_campaign_id_fkey" FOREIGN KEY ("campaign_id") REFERENCES "CharityCampaign"("campaign_id") ON DELETE RESTRICT ON UPDATE CASCADE;
