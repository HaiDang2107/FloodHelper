/*
  Warnings:

  - You are about to drop the column `created_by` on the `RoleUpdatingRequest` table. All the data in the column will be lost.
  - You are about to drop the column `avatar_url` on the `User` table. All the data in the column will be lost.
  - You are about to drop the column `back_citizen_id_card_image_url` on the `User` table. All the data in the column will be lost.
  - You are about to drop the column `citizen_id` on the `User` table. All the data in the column will be lost.
  - You are about to drop the column `citizen_id_card_img` on the `User` table. All the data in the column will be lost.
  - You are about to drop the column `date_of_expire` on the `User` table. All the data in the column will be lost.
  - You are about to drop the column `date_of_issue` on the `User` table. All the data in the column will be lost.
  - You are about to drop the column `dob` on the `User` table. All the data in the column will be lost.
  - You are about to drop the column `front_citizen_id_card_image_url` on the `User` table. All the data in the column will be lost.
  - You are about to drop the column `fullname` on the `User` table. All the data in the column will be lost.
  - You are about to drop the column `gender` on the `User` table. All the data in the column will be lost.
  - You are about to drop the column `job_position` on the `User` table. All the data in the column will be lost.
  - You are about to drop the column `nickname` on the `User` table. All the data in the column will be lost.
  - You are about to drop the column `origin_Ward_code` on the `User` table. All the data in the column will be lost.
  - You are about to drop the column `origin_province_code` on the `User` table. All the data in the column will be lost.
  - You are about to drop the column `phone_number` on the `User` table. All the data in the column will be lost.
  - You are about to drop the column `residence_province_code` on the `User` table. All the data in the column will be lost.
  - You are about to drop the column `residence_ward_code` on the `User` table. All the data in the column will be lost.
  - Added the required column `profile_id` to the `RoleUpdatingRequest` table without a default value. This is not possible if the table is not empty.

*/
-- CreateEnum
CREATE TYPE "ProfileRequestState" AS ENUM ('PENDING', 'APPROVED', 'REJECTED', 'REVOKED');

-- AlterEnum
ALTER TYPE "RoleRequestState" ADD VALUE 'REVOKED';

-- DropForeignKey
ALTER TABLE "RoleUpdatingRequest" DROP CONSTRAINT "RoleUpdatingRequest_created_by_fkey";

-- DropForeignKey
ALTER TABLE "User" DROP CONSTRAINT "User_origin_Ward_code_fkey";

-- DropForeignKey
ALTER TABLE "User" DROP CONSTRAINT "User_origin_province_code_fkey";

-- DropForeignKey
ALTER TABLE "User" DROP CONSTRAINT "User_residence_province_code_fkey";

-- DropForeignKey
ALTER TABLE "User" DROP CONSTRAINT "User_residence_ward_code_fkey";

-- DropIndex
DROP INDEX "User_phone_number_key";

-- AlterTable
ALTER TABLE "RoleUpdatingRequest" DROP COLUMN "created_by",
ADD COLUMN     "profile_id" UUID NOT NULL;

-- AlterTable
ALTER TABLE "User" DROP COLUMN "avatar_url",
DROP COLUMN "back_citizen_id_card_image_url",
DROP COLUMN "citizen_id",
DROP COLUMN "citizen_id_card_img",
DROP COLUMN "date_of_expire",
DROP COLUMN "date_of_issue",
DROP COLUMN "dob",
DROP COLUMN "front_citizen_id_card_image_url",
DROP COLUMN "fullname",
DROP COLUMN "gender",
DROP COLUMN "job_position",
DROP COLUMN "nickname",
DROP COLUMN "origin_Ward_code",
DROP COLUMN "origin_province_code",
DROP COLUMN "phone_number",
DROP COLUMN "residence_province_code",
DROP COLUMN "residence_ward_code";

-- CreateTable
CREATE TABLE "ProfileUpdatingRequest" (
    "request_id" UUID NOT NULL,
    "current_profile_id" UUID NOT NULL,
    "new_profile_id" UUID NOT NULL,
    "checked_by" UUID,
    "state" "ProfileRequestState" NOT NULL DEFAULT 'PENDING',
    "note" TEXT,
    "created_at" TIMESTAMP(3) NOT NULL DEFAULT CURRENT_TIMESTAMP,
    "responded_at" TIMESTAMP(3),

    CONSTRAINT "ProfileUpdatingRequest_pkey" PRIMARY KEY ("request_id")
);

-- CreateTable
CREATE TABLE "Profile" (
    "profile_id" UUID NOT NULL,
    "user_id" UUID NOT NULL,
    "updated_at" TIMESTAMP(3) NOT NULL,
    "is_current" BOOLEAN NOT NULL DEFAULT false,
    "fullname" VARCHAR(255) NOT NULL,
    "nickname" VARCHAR(255),
    "dob" DATE,
    "gender" VARCHAR(20),
    "phone_number" TEXT NOT NULL,
    "avatar_url" TEXT,
    "citizen_id" TEXT,
    "rescuer_certificate_url" TEXT,
    "front_citizen_id_card_image_url" TEXT,
    "back_citizen_id_card_image_url" TEXT,
    "occupation" TEXT,
    "origin_province_code" INTEGER,
    "origin_ward_code" INTEGER,
    "residence_province_code" INTEGER,
    "residence_ward_code" INTEGER,
    "date_of_issue" DATE,
    "date_of_expire" DATE,

    CONSTRAINT "Profile_pkey" PRIMARY KEY ("profile_id")
);

-- CreateIndex
CREATE UNIQUE INDEX "Profile_phone_number_key" ON "Profile"("phone_number");

-- CreateIndex
CREATE INDEX "Profile_user_id_idx" ON "Profile"("user_id");

-- CreateIndex
CREATE UNIQUE INDEX "Profile_user_id_is_current_key" ON "Profile"("user_id", "is_current");

-- AddForeignKey
ALTER TABLE "RoleUpdatingRequest" ADD CONSTRAINT "RoleUpdatingRequest_profile_id_fkey" FOREIGN KEY ("profile_id") REFERENCES "Profile"("profile_id") ON DELETE RESTRICT ON UPDATE CASCADE;

-- AddForeignKey
ALTER TABLE "ProfileUpdatingRequest" ADD CONSTRAINT "ProfileUpdatingRequest_current_profile_id_fkey" FOREIGN KEY ("current_profile_id") REFERENCES "Profile"("profile_id") ON DELETE RESTRICT ON UPDATE CASCADE;

-- AddForeignKey
ALTER TABLE "ProfileUpdatingRequest" ADD CONSTRAINT "ProfileUpdatingRequest_new_profile_id_fkey" FOREIGN KEY ("new_profile_id") REFERENCES "Profile"("profile_id") ON DELETE RESTRICT ON UPDATE CASCADE;

-- AddForeignKey
ALTER TABLE "ProfileUpdatingRequest" ADD CONSTRAINT "ProfileUpdatingRequest_checked_by_fkey" FOREIGN KEY ("checked_by") REFERENCES "User"("user_id") ON DELETE SET NULL ON UPDATE CASCADE;

-- AddForeignKey
ALTER TABLE "Profile" ADD CONSTRAINT "Profile_origin_province_code_fkey" FOREIGN KEY ("origin_province_code") REFERENCES "Province"("code") ON DELETE SET NULL ON UPDATE CASCADE;

-- AddForeignKey
ALTER TABLE "Profile" ADD CONSTRAINT "Profile_origin_ward_code_fkey" FOREIGN KEY ("origin_ward_code") REFERENCES "Ward"("code") ON DELETE SET NULL ON UPDATE CASCADE;

-- AddForeignKey
ALTER TABLE "Profile" ADD CONSTRAINT "Profile_residence_province_code_fkey" FOREIGN KEY ("residence_province_code") REFERENCES "Province"("code") ON DELETE SET NULL ON UPDATE CASCADE;

-- AddForeignKey
ALTER TABLE "Profile" ADD CONSTRAINT "Profile_residence_ward_code_fkey" FOREIGN KEY ("residence_ward_code") REFERENCES "Ward"("code") ON DELETE SET NULL ON UPDATE CASCADE;

-- AddForeignKey
ALTER TABLE "Profile" ADD CONSTRAINT "Profile_user_id_fkey" FOREIGN KEY ("user_id") REFERENCES "User"("user_id") ON DELETE RESTRICT ON UPDATE CASCADE;
