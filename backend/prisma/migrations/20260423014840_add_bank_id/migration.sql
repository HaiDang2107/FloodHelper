/*
  Warnings:

  - You are about to drop the column `bank_code` on the `BankAccount` table. All the data in the column will be lost.
  - You are about to drop the column `bank_name` on the `BankAccount` table. All the data in the column will be lost.
  - A unique constraint covering the columns `[bank_id,bank_account_number]` on the table `BankAccount` will be added. If there are existing duplicate values, this will fail.
  - Added the required column `bank_id` to the `BankAccount` table without a default value. This is not possible if the table is not empty.

*/

-- 1. TẠO BẢNG Bank TRƯỚC
CREATE TABLE "Bank" (
    "id" INTEGER NOT NULL,
    "name" TEXT NOT NULL,
    "code" TEXT NOT NULL,
    "bin" TEXT NOT NULL,
    "shortName" TEXT NOT NULL,

    CONSTRAINT "Bank_pkey" PRIMARY KEY ("id")
);

-- 3. XÓA UNIQUE INDEX CŨ CỦA BẢNG BankAccount
DROP INDEX "BankAccount_bank_name_bank_account_number_key";

-- 4. THÊM CỘT bank_id VÀO BankAccount (Tạm thời cho phép NULL)
ALTER TABLE "BankAccount" ADD COLUMN "bank_id" INTEGER;

-- 5. ĐỔI CỘT bank_id THÀNH BẮT BUỘC (NOT NULL) & XÓA CÁC CỘT DỮ LIỆU CŨ
ALTER TABLE "BankAccount" 
  ALTER COLUMN "bank_id" SET NOT NULL,
  DROP COLUMN "bank_code",
  DROP COLUMN "bank_name";

-- 6. TẠO LẠI UNIQUE INDEX MỚI DỰA TRÊN bank_id VÀ bank_account_number
CREATE UNIQUE INDEX "BankAccount_bank_id_bank_account_number_key" ON "BankAccount"("bank_id", "bank_account_number");

-- 7. THÊM KHÓA NGOẠI (FOREIGN KEY) LIÊN KẾT 2 BẢNG
ALTER TABLE "BankAccount" ADD CONSTRAINT "BankAccount_bank_id_fkey" FOREIGN KEY ("bank_id") REFERENCES "Bank"("id") ON DELETE RESTRICT ON UPDATE CASCADE;