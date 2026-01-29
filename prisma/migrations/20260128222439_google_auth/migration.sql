/*
  Warnings:

  - You are about to drop the `EmailVerificationToken` table. If the table is not empty, all the data it contains will be lost.
  - A unique constraint covering the columns `[google_sub]` on the table `User` will be added. If there are existing duplicate values, this will fail.

*/
-- DropForeignKey
ALTER TABLE "EmailVerificationToken" DROP CONSTRAINT "EmailVerificationToken_user_id_fkey";

-- AlterTable
ALTER TABLE "User" ADD COLUMN     "google_sub" TEXT,
ALTER COLUMN "password_hash" DROP NOT NULL;

-- DropTable
DROP TABLE "EmailVerificationToken";

-- CreateIndex
CREATE UNIQUE INDEX "User_google_sub_key" ON "User"("google_sub");
