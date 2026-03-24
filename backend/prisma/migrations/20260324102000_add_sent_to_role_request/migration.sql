ALTER TABLE "RoleUpdatingRequest"
ADD COLUMN "sent_to" UUID;

ALTER TABLE "RoleUpdatingRequest"
ADD CONSTRAINT "RoleUpdatingRequest_sent_to_fkey"
FOREIGN KEY ("sent_to") REFERENCES "User"("user_id")
ON DELETE SET NULL ON UPDATE CASCADE;

CREATE INDEX "RoleUpdatingRequest_sent_to_idx"
ON "RoleUpdatingRequest"("sent_to");
