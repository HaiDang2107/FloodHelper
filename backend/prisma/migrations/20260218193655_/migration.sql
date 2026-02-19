/*
  Warnings:

  - You are about to drop the `VerificationCode` table. If the table is not empty, all the data it contains will be lost.
  - A unique constraint covering the columns `[account_id,device_id]` on the table `Session` will be added. If there are existing duplicate values, this will fail.

*/
-- DropForeignKey
ALTER TABLE "VerificationCode" DROP CONSTRAINT "VerificationCode_account_id_fkey";

-- AlterTable
ALTER TABLE "Account" ALTER COLUMN "state" SET DEFAULT 'INACTIVE';

-- DropTable
DROP TABLE "VerificationCode";

-- CreateIndex
CREATE UNIQUE INDEX "Session_account_id_device_id_key" ON "Session"("account_id", "device_id");
