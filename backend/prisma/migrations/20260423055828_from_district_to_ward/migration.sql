/*
  Warnings:

  - You are about to drop the column `destination_district_code` on the `CharityCampaign` table. All the data in the column will be lost.
  - You are about to drop the column `origin_district_code` on the `User` table. All the data in the column will be lost.
  - You are about to drop the column `residence_district_code` on the `User` table. All the data in the column will be lost.
  - You are about to drop the `District` table. If the table is not empty, all the data it contains will be lost.

*/
-- DropForeignKey
ALTER TABLE "CharityCampaign" DROP CONSTRAINT "CharityCampaign_destination_district_code_fkey";

-- DropForeignKey
ALTER TABLE "District" DROP CONSTRAINT "District_province_code_fkey";

-- DropForeignKey
ALTER TABLE "User" DROP CONSTRAINT "User_origin_district_code_fkey";

-- DropForeignKey
ALTER TABLE "User" DROP CONSTRAINT "User_residence_district_code_fkey";

-- AlterTable
ALTER TABLE "CharityCampaign" DROP COLUMN "destination_district_code",
ADD COLUMN     "destination_ward_code" INTEGER;

-- AlterTable
ALTER TABLE "User" DROP COLUMN "origin_district_code",
DROP COLUMN "residence_district_code",
ADD COLUMN     "origin_Ward_code" INTEGER,
ADD COLUMN     "residence_ward_code" INTEGER;

-- DropTable
DROP TABLE "District";

-- CreateTable
CREATE TABLE "Ward" (
    "code" INTEGER NOT NULL,
    "name" TEXT NOT NULL,
    "division_type" TEXT NOT NULL,
    "codename" TEXT NOT NULL,
    "province_code" INTEGER NOT NULL,

    CONSTRAINT "Ward_pkey" PRIMARY KEY ("code")
);

-- AddForeignKey
ALTER TABLE "CharityCampaign" ADD CONSTRAINT "CharityCampaign_destination_ward_code_fkey" FOREIGN KEY ("destination_ward_code") REFERENCES "Ward"("code") ON DELETE SET NULL ON UPDATE CASCADE;

-- AddForeignKey
ALTER TABLE "User" ADD CONSTRAINT "User_origin_Ward_code_fkey" FOREIGN KEY ("origin_Ward_code") REFERENCES "Ward"("code") ON DELETE SET NULL ON UPDATE CASCADE;

-- AddForeignKey
ALTER TABLE "User" ADD CONSTRAINT "User_residence_ward_code_fkey" FOREIGN KEY ("residence_ward_code") REFERENCES "Ward"("code") ON DELETE SET NULL ON UPDATE CASCADE;

-- AddForeignKey
ALTER TABLE "Ward" ADD CONSTRAINT "Ward_province_code_fkey" FOREIGN KEY ("province_code") REFERENCES "Province"("code") ON DELETE RESTRICT ON UPDATE CASCADE;
