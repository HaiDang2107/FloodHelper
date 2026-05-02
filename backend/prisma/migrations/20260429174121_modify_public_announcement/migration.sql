/*
  Warnings:

  - Added the required column `title` to the `PublicAnnouncement` table without a default value. This is not possible if the table is not empty.
  - Added the required column `type` to the `PublicAnnouncement` table without a default value. This is not possible if the table is not empty.
  - Changed the type of `publisher_id` on the `PublicAnnouncement` table. No cast exists, the column would be dropped and recreated, which cannot be done if there is data, since the column is required.

*/
-- CreateEnum
CREATE TYPE "PublicAnnouncementType" AS ENUM ('DAILY', 'AUTHORITY', 'APP');

-- AlterTable
ALTER TABLE "PublicAnnouncement" ADD COLUMN     "created_at" TIMESTAMP(3) NOT NULL DEFAULT CURRENT_TIMESTAMP,
ADD COLUMN     "title" VARCHAR(255) NOT NULL,
ADD COLUMN     "type" "PublicAnnouncementType" NOT NULL,
DROP COLUMN "publisher_id",
ADD COLUMN     "publisher_id" UUID NOT NULL;

-- AddForeignKey
ALTER TABLE "PublicAnnouncement" ADD CONSTRAINT "PublicAnnouncement_publisher_id_fkey" FOREIGN KEY ("publisher_id") REFERENCES "User"("user_id") ON DELETE RESTRICT ON UPDATE CASCADE;
