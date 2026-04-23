/*
  Warnings:

  - You are about to drop the column `destination` on the `CharityCampaign` table. All the data in the column will be lost.
  - You are about to drop the column `place_of_origin` on the `User` table. All the data in the column will be lost.
  - You are about to drop the column `place_of_residence` on the `User` table. All the data in the column will be lost.

*/
-- AlterTable
ALTER TABLE "CharityCampaign" DROP COLUMN "destination",
ADD COLUMN     "destination_detail" TEXT,
ADD COLUMN     "destination_district_code" INTEGER,
ADD COLUMN     "destination_province_code" INTEGER;

-- AlterTable
ALTER TABLE "User" DROP COLUMN "place_of_origin",
DROP COLUMN "place_of_residence",
ADD COLUMN     "origin_district_code" INTEGER,
ADD COLUMN     "origin_province_code" INTEGER,
ADD COLUMN     "residence_district_code" INTEGER,
ADD COLUMN     "residence_province_code" INTEGER;

-- CreateTable
CREATE TABLE "Province" (
    "code" INTEGER NOT NULL,
    "name" TEXT NOT NULL,
    "division_type" TEXT NOT NULL,
    "codename" TEXT NOT NULL,
    "phone_code" INTEGER NOT NULL,

    CONSTRAINT "Province_pkey" PRIMARY KEY ("code")
);

-- CreateTable
CREATE TABLE "District" (
    "code" INTEGER NOT NULL,
    "name" TEXT NOT NULL,
    "division_type" TEXT NOT NULL,
    "codename" TEXT NOT NULL,
    "province_code" INTEGER NOT NULL,

    CONSTRAINT "District_pkey" PRIMARY KEY ("code")
);

-- AddForeignKey
ALTER TABLE "CharityCampaign" ADD CONSTRAINT "CharityCampaign_destination_province_code_fkey" FOREIGN KEY ("destination_province_code") REFERENCES "Province"("code") ON DELETE SET NULL ON UPDATE CASCADE;

-- AddForeignKey
ALTER TABLE "CharityCampaign" ADD CONSTRAINT "CharityCampaign_destination_district_code_fkey" FOREIGN KEY ("destination_district_code") REFERENCES "District"("code") ON DELETE SET NULL ON UPDATE CASCADE;

-- AddForeignKey
ALTER TABLE "User" ADD CONSTRAINT "User_origin_province_code_fkey" FOREIGN KEY ("origin_province_code") REFERENCES "Province"("code") ON DELETE SET NULL ON UPDATE CASCADE;

-- AddForeignKey
ALTER TABLE "User" ADD CONSTRAINT "User_origin_district_code_fkey" FOREIGN KEY ("origin_district_code") REFERENCES "District"("code") ON DELETE SET NULL ON UPDATE CASCADE;

-- AddForeignKey
ALTER TABLE "User" ADD CONSTRAINT "User_residence_province_code_fkey" FOREIGN KEY ("residence_province_code") REFERENCES "Province"("code") ON DELETE SET NULL ON UPDATE CASCADE;

-- AddForeignKey
ALTER TABLE "User" ADD CONSTRAINT "User_residence_district_code_fkey" FOREIGN KEY ("residence_district_code") REFERENCES "District"("code") ON DELETE SET NULL ON UPDATE CASCADE;

-- AddForeignKey
ALTER TABLE "District" ADD CONSTRAINT "District_province_code_fkey" FOREIGN KEY ("province_code") REFERENCES "Province"("code") ON DELETE RESTRICT ON UPDATE CASCADE;
