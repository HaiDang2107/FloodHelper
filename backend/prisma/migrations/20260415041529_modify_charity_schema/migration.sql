/*
  Warnings:

  - You are about to drop the column `bank_account_name` on the `BankAccount` table. All the data in the column will be lost.
  - You are about to drop the column `message` on the `Transaction` table. All the data in the column will be lost.
  - You are about to drop the column `transfer_amount` on the `Transaction` table. All the data in the column will be lost.
  - You are about to drop the column `transfer_by` on the `Transaction` table. All the data in the column will be lost.
  - You are about to drop the column `transfer_type` on the `Transaction` table. All the data in the column will be lost.
  - Added the required column `amount` to the `Transaction` table without a default value. This is not possible if the table is not empty.

*/
-- CreateEnum
CREATE TYPE "TransactionState" AS ENUM ('CREATED', 'VERIFYING', 'SUCCESS', 'FAILED', 'EXPIRED');

-- AlterTable
ALTER TABLE "BankAccount" DROP COLUMN "bank_account_name",
ADD COLUMN     "bank_code" TEXT NOT NULL DEFAULT 'UNKNOWN',
ADD COLUMN     "user_bank_name" TEXT NOT NULL DEFAULT 'UNKNOWN';

-- AlterTable
ALTER TABLE "Transaction" DROP COLUMN "message",
DROP COLUMN "transfer_amount",
DROP COLUMN "transfer_by",
DROP COLUMN "transfer_type",
ADD COLUMN     "amount" DECIMAL(15,2) NOT NULL,
ADD COLUMN     "content" TEXT,
ADD COLUMN     "created_at" TIMESTAMP(3) NOT NULL DEFAULT CURRENT_TIMESTAMP,
ADD COLUMN     "donated_by" TEXT,
ADD COLUMN     "expired_at" TIMESTAMP(3),
ADD COLUMN     "qr_link" TEXT,
ADD COLUMN     "referencenumber" TEXT,
ADD COLUMN     "state" "TransactionState" NOT NULL DEFAULT 'CREATED',
ADD COLUMN     "trans_type" TEXT NOT NULL DEFAULT 'C',
ADD COLUMN     "transaction_id_from_vietqr" TEXT,
ADD COLUMN     "transaction_ref_id" TEXT,
ADD COLUMN     "transaction_time" TIMESTAMP(3);
