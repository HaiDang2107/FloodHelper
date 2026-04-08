/*
  Warnings:

  - You are about to alter the column `nickname` on the `User` table. The data in that column could be lost. The data in that column will be cast from `Text` to `VarChar(255)`.

*/
-- DropIndex
DROP INDEX "RoleUpdatingRequest_check_by_idx";

-- DropIndex
DROP INDEX "Signal_created_by_idx";

-- DropIndex
DROP INDEX "Signal_handled_by_idx";

-- DropIndex
DROP INDEX "Signal_state_idx";

-- AlterTable
ALTER TABLE "CharityCampaign" ADD COLUMN     "note_by_authority" TEXT,
ADD COLUMN     "requested_at" TIMESTAMP(3),
ADD COLUMN     "responded_at" TIMESTAMP(3);

-- AlterTable
ALTER TABLE "Friendship" ALTER COLUMN "friend_map_mode" SET DEFAULT true;

-- AlterTable
ALTER TABLE "User" ALTER COLUMN "nickname" SET DATA TYPE VARCHAR(255),
ALTER COLUMN "visibility_mode" SET DEFAULT 'JUST_FRIEND';
