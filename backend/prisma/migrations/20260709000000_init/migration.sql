-- CreateEnum
CREATE TYPE "PublicAnnouncementType" AS ENUM ('DAILY', 'AUTHORITY', 'APP');

-- CreateEnum
CREATE TYPE "CampaignState" AS ENUM ('CREATED', 'PENDING', 'APPROVED', 'REJECTED', 'DONATING', 'DISTRIBUTING', 'SUSPENDED', 'FINISHED');

-- CreateEnum
CREATE TYPE "TransactionState" AS ENUM ('CREATED', 'VERIFYING', 'SUCCESS', 'FAILED', 'EXPIRED');

-- CreateEnum
CREATE TYPE "RoleRequestType" AS ENUM ('BENEFACTOR', 'RESCUER');

-- CreateEnum
CREATE TYPE "RoleRequestState" AS ENUM ('PENDING', 'APPROVED', 'REJECTED', 'REVOKED');

-- CreateEnum
CREATE TYPE "ProfileRequestState" AS ENUM ('PENDING', 'APPROVED', 'REJECTED', 'REVOKED');

-- CreateEnum
CREATE TYPE "SignalState" AS ENUM ('BROADCASTING', 'HANDLED', 'STOPPED');

-- CreateTable
CREATE TABLE "PublicAnnouncement" (
    "announcement_id" UUID NOT NULL,
    "title" VARCHAR(255) NOT NULL,
    "text_content" TEXT,
    "document_url" TEXT,
    "publisher_id" UUID NOT NULL,
    "published_to" UUID,
    "type" "PublicAnnouncementType" NOT NULL,
    "created_at" TIMESTAMP(3) NOT NULL DEFAULT CURRENT_TIMESTAMP,

    CONSTRAINT "PublicAnnouncement_pkey" PRIMARY KEY ("announcement_id")
);

-- CreateTable
CREATE TABLE "StateModification" (
    "deact_id" UUID NOT NULL,
    "account_id" TEXT NOT NULL,
    "modify_by" TEXT NOT NULL,
    "newState" TEXT NOT NULL,
    "modify_at" TIMESTAMP(3) NOT NULL DEFAULT CURRENT_TIMESTAMP,

    CONSTRAINT "StateModification_pkey" PRIMARY KEY ("deact_id")
);

-- CreateTable
CREATE TABLE "CharityCampaign" (
    "campaign_id" UUID NOT NULL,
    "organized_by" UUID NOT NULL,
    "bank_account_id" UUID,
    "checked_by" UUID,
    "requested_at" TIMESTAMP(3),
    "responded_at" TIMESTAMP(3),
    "suspended_at" TIMESTAMP(3),
    "note_for_response" TEXT,
    "note_for_suspension" TEXT,
    "campaign_name" TEXT NOT NULL,
    "purpose" TEXT NOT NULL,
    "destination_province_code" INTEGER,
    "destination_ward_code" INTEGER,
    "destination_detail" TEXT,
    "campaign_latitude" DECIMAL(10,7),
    "campaign_longitude" DECIMAL(10,7),
    "charity_object" TEXT NOT NULL,
    "state" "CampaignState" NOT NULL,
    "started_donation_at" TIMESTAMP(3),
    "finished_donation_at" TIMESTAMP(3),
    "started_distribution_at" TIMESTAMP(3),
    "finished_distribution_at" TIMESTAMP(3),
    "bank_statement_file_url" TEXT,
    "created_at" TIMESTAMP(3) NOT NULL DEFAULT CURRENT_TIMESTAMP,

    CONSTRAINT "CharityCampaign_pkey" PRIMARY KEY ("campaign_id")
);

-- CreateTable
CREATE TABLE "Transaction" (
    "transaction_id" UUID NOT NULL,
    "campaign_id" UUID NOT NULL,
    "trans_type" TEXT NOT NULL DEFAULT 'C',
    "donate_at" TIMESTAMP(3) NOT NULL,
    "donated_by" TEXT,
    "amount" DECIMAL(15,2) NOT NULL,
    "content" TEXT,
    "transaction_id_from_vietqr" TEXT,
    "transaction_ref_id" TEXT,
    "referencenumber" TEXT,
    "qr_link" TEXT,
    "created_at" TIMESTAMP(3) NOT NULL DEFAULT CURRENT_TIMESTAMP,
    "transaction_time" TIMESTAMP(3),
    "expired_at" TIMESTAMP(3),
    "state" "TransactionState" NOT NULL DEFAULT 'CREATED',

    CONSTRAINT "Transaction_pkey" PRIMARY KEY ("transaction_id")
);

-- CreateTable
CREATE TABLE "BankAccount" (
    "bank_account_id" UUID NOT NULL,
    "user_bank_name" TEXT NOT NULL DEFAULT 'UNKNOWN',
    "bank_id" INTEGER NOT NULL,
    "bank_account_number" TEXT NOT NULL,

    CONSTRAINT "BankAccount_pkey" PRIMARY KEY ("bank_account_id")
);

-- CreateTable
CREATE TABLE "Bank" (
    "id" INTEGER NOT NULL,
    "name" TEXT NOT NULL,
    "code" TEXT NOT NULL,
    "bin" TEXT NOT NULL,
    "shortName" TEXT NOT NULL,

    CONSTRAINT "Bank_pkey" PRIMARY KEY ("id")
);

-- CreateTable
CREATE TABLE "Supply" (
    "supply_id" UUID NOT NULL,
    "campaign_id" UUID NOT NULL,
    "supply_name" TEXT NOT NULL,
    "unit_price" DECIMAL(65,30),
    "quantity" INTEGER NOT NULL,
    "price" DECIMAL(65,30) NOT NULL,
    "bought_at" TIMESTAMP(3) NOT NULL,
    "supply_image_url" TEXT,
    "invoice_image_url" TEXT,

    CONSTRAINT "Supply_pkey" PRIMARY KEY ("supply_id")
);

-- CreateTable
CREATE TABLE "AnnouncementFromBenefactor" (
    "announcement_id" UUID NOT NULL,
    "campaign_id" UUID NOT NULL,
    "caption" TEXT,
    "image_url" TEXT,
    "posted_at" TIMESTAMP(3) NOT NULL DEFAULT CURRENT_TIMESTAMP,

    CONSTRAINT "AnnouncementFromBenefactor_pkey" PRIMARY KEY ("announcement_id")
);

-- CreateTable
CREATE TABLE "FinancialSupport" (
    "financial_support_id" UUID NOT NULL,
    "campaign_id" UUID NOT NULL,
    "household_name" TEXT NOT NULL,
    "amount" DECIMAL(15,2) NOT NULL,
    "allocated_at" TIMESTAMP(3) NOT NULL,

    CONSTRAINT "FinancialSupport_pkey" PRIMARY KEY ("financial_support_id")
);

-- CreateTable
CREATE TABLE "ChatRoom" (
    "room_id" UUID NOT NULL,
    "created_by" UUID,
    "member_count" INTEGER NOT NULL DEFAULT 0,

    CONSTRAINT "ChatRoom_pkey" PRIMARY KEY ("room_id")
);

-- CreateTable
CREATE TABLE "Message" (
    "message_id" UUID NOT NULL,
    "room_id" UUID NOT NULL,
    "sent_by" UUID NOT NULL,
    "type" TEXT NOT NULL,
    "text_content" TEXT,
    "image_url" TEXT,
    "sent_at" TIMESTAMP(3) NOT NULL DEFAULT CURRENT_TIMESTAMP,
    "unsent_at" TIMESTAMP(3),

    CONSTRAINT "Message_pkey" PRIMARY KEY ("message_id")
);

-- CreateTable
CREATE TABLE "RoomMember" (
    "room_id" UUID NOT NULL,
    "member_id" UUID NOT NULL,
    "role" TEXT NOT NULL,
    "nickname" TEXT,
    "enter_at" TIMESTAMP(3) NOT NULL DEFAULT CURRENT_TIMESTAMP,
    "leave_at" TIMESTAMP(3),

    CONSTRAINT "RoomMember_pkey" PRIMARY KEY ("room_id","member_id")
);

-- CreateTable
CREATE TABLE "RoleUpdatingRequest" (
    "request_id" UUID NOT NULL,
    "profile_id" UUID NOT NULL,
    "check_by" UUID,
    "type" "RoleRequestType" NOT NULL,
    "state" "RoleRequestState" NOT NULL DEFAULT 'PENDING',
    "note" TEXT,
    "created_at" TIMESTAMP(3) NOT NULL DEFAULT CURRENT_TIMESTAMP,
    "responsed_at" TIMESTAMP(3),

    CONSTRAINT "RoleUpdatingRequest_pkey" PRIMARY KEY ("request_id")
);

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
CREATE TABLE "Signal" (
    "signal_id" UUID NOT NULL,
    "created_by" UUID NOT NULL,
    "handled_by" UUID,
    "trapped_count" INTEGER NOT NULL DEFAULT 0,
    "children_num" INTEGER NOT NULL DEFAULT 0,
    "elderly_num" INTEGER NOT NULL DEFAULT 0,
    "has_food" BOOLEAN NOT NULL DEFAULT false,
    "has_water" BOOLEAN NOT NULL DEFAULT false,
    "state" "SignalState" NOT NULL DEFAULT 'BROADCASTING',
    "note" TEXT,
    "created_at" TIMESTAMP(3) NOT NULL DEFAULT CURRENT_TIMESTAMP,
    "handled_at" TIMESTAMP(3),
    "stopped_at" TIMESTAMP(3),

    CONSTRAINT "Signal_pkey" PRIMARY KEY ("signal_id")
);

-- CreateTable
CREATE TABLE "Post" (
    "post_id" UUID NOT NULL,
    "created_by" UUID NOT NULL,
    "caption" TEXT,
    "image_url" TEXT,
    "longitude" DECIMAL(10,7),
    "latitude" DECIMAL(10,7),
    "created_at" TIMESTAMP(3) NOT NULL DEFAULT CURRENT_TIMESTAMP,

    CONSTRAINT "Post_pkey" PRIMARY KEY ("post_id")
);

-- CreateTable
CREATE TABLE "Like" (
    "post_id" UUID NOT NULL,
    "created_by" UUID NOT NULL,
    "created_at" TIMESTAMP(3) NOT NULL DEFAULT CURRENT_TIMESTAMP,

    CONSTRAINT "Like_pkey" PRIMARY KEY ("post_id","created_by")
);

-- CreateTable
CREATE TABLE "Comment" (
    "commented_by" UUID NOT NULL,
    "post_id" UUID NOT NULL,
    "created_at" TIMESTAMP(3) NOT NULL DEFAULT CURRENT_TIMESTAMP,
    "text_content" TEXT,
    "image_url" TEXT,

    CONSTRAINT "Comment_pkey" PRIMARY KEY ("commented_by","post_id")
);

-- CreateTable
CREATE TABLE "Friendship" (
    "user_id" UUID NOT NULL,
    "friend_id" UUID NOT NULL,
    "friend_map_mode" BOOLEAN NOT NULL DEFAULT true,
    "last_longitude" DECIMAL(10,7),
    "last_latitude" DECIMAL(10,7),
    "last_data_at" TIMESTAMP(3) NOT NULL DEFAULT CURRENT_TIMESTAMP,

    CONSTRAINT "Friendship_pkey" PRIMARY KEY ("user_id","friend_id")
);

-- CreateTable
CREATE TABLE "FriendMakingRequest" (
    "request_id" UUID NOT NULL,
    "created_by" UUID NOT NULL,
    "sent_to" UUID NOT NULL,
    "state" TEXT NOT NULL,
    "note" TEXT,
    "created_at" TIMESTAMP(3) NOT NULL DEFAULT CURRENT_TIMESTAMP,
    "responsed_at" TIMESTAMP(3),

    CONSTRAINT "FriendMakingRequest_pkey" PRIMARY KEY ("request_id")
);

-- CreateTable
CREATE TABLE "User" (
    "user_id" UUID NOT NULL,
    "role" TEXT[] DEFAULT ARRAY['NORMAL_USER']::TEXT[],
    "cur_longitude" DECIMAL(10,7),
    "cur_latitude" DECIMAL(10,7),
    "visibility_mode" VARCHAR(20) NOT NULL DEFAULT 'JUST_FRIEND',
    "show_charity_campaign_locations" BOOLEAN NOT NULL DEFAULT false,
    "fcm_token" TEXT,

    CONSTRAINT "User_pkey" PRIMARY KEY ("user_id")
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

-- CreateTable
CREATE TABLE "Account" (
    "account_id" UUID NOT NULL,
    "user_id" UUID NOT NULL,
    "provider_id" UUID,
    "created_by" UUID,
    "username" TEXT NOT NULL,
    "password" TEXT NOT NULL,
    "state" TEXT NOT NULL DEFAULT 'INACTIVE',
    "created_at" TIMESTAMP(3) NOT NULL DEFAULT CURRENT_TIMESTAMP,
    "refresh_token_from_provider" TEXT,

    CONSTRAINT "Account_pkey" PRIMARY KEY ("account_id")
);

-- CreateTable
CREATE TABLE "Session" (
    "session_id" UUID NOT NULL,
    "account_id" UUID NOT NULL,
    "device_id" TEXT,
    "refresh_token" TEXT NOT NULL,
    "role" TEXT NOT NULL,
    "created_at" TIMESTAMP(3) NOT NULL DEFAULT CURRENT_TIMESTAMP,
    "expire_at" TIMESTAMP(3) NOT NULL,

    CONSTRAINT "Session_pkey" PRIMARY KEY ("session_id")
);

-- CreateTable
CREATE TABLE "Provider" (
    "provider_id" UUID NOT NULL,
    "provider_name" TEXT NOT NULL,
    "refresh_token" TEXT,

    CONSTRAINT "Provider_pkey" PRIMARY KEY ("provider_id")
);

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
CREATE TABLE "Ward" (
    "code" INTEGER NOT NULL,
    "name" TEXT NOT NULL,
    "division_type" TEXT NOT NULL,
    "codename" TEXT NOT NULL,
    "province_code" INTEGER NOT NULL,

    CONSTRAINT "Ward_pkey" PRIMARY KEY ("code")
);

-- CreateTable
CREATE TABLE "WeatherMap" (
    "longitude" DECIMAL(10,7) NOT NULL,
    "latitude" DECIMAL(10,7) NOT NULL,
    "timestamp" TIMESTAMP(3) NOT NULL,
    "precipitation" DOUBLE PRECISION,
    "temperature" DOUBLE PRECISION,

    CONSTRAINT "WeatherMap_pkey" PRIMARY KEY ("longitude","latitude","timestamp")
);

-- CreateIndex
CREATE UNIQUE INDEX "BankAccount_bank_id_bank_account_number_key" ON "BankAccount"("bank_id", "bank_account_number");

-- CreateIndex
CREATE INDEX "Profile_user_id_idx" ON "Profile"("user_id");

-- CreateIndex
CREATE UNIQUE INDEX "Account_user_id_key" ON "Account"("user_id");

-- CreateIndex
CREATE UNIQUE INDEX "Account_username_key" ON "Account"("username");

-- CreateIndex
CREATE UNIQUE INDEX "Session_account_id_device_id_key" ON "Session"("account_id", "device_id");

-- AddForeignKey
ALTER TABLE "PublicAnnouncement" ADD CONSTRAINT "PublicAnnouncement_publisher_id_fkey" FOREIGN KEY ("publisher_id") REFERENCES "User"("user_id") ON DELETE RESTRICT ON UPDATE CASCADE;

-- AddForeignKey
ALTER TABLE "PublicAnnouncement" ADD CONSTRAINT "PublicAnnouncement_published_to_fkey" FOREIGN KEY ("published_to") REFERENCES "User"("user_id") ON DELETE SET NULL ON UPDATE CASCADE;

-- AddForeignKey
ALTER TABLE "CharityCampaign" ADD CONSTRAINT "CharityCampaign_destination_province_code_fkey" FOREIGN KEY ("destination_province_code") REFERENCES "Province"("code") ON DELETE SET NULL ON UPDATE CASCADE;

-- AddForeignKey
ALTER TABLE "CharityCampaign" ADD CONSTRAINT "CharityCampaign_destination_ward_code_fkey" FOREIGN KEY ("destination_ward_code") REFERENCES "Ward"("code") ON DELETE SET NULL ON UPDATE CASCADE;

-- AddForeignKey
ALTER TABLE "CharityCampaign" ADD CONSTRAINT "CharityCampaign_organized_by_fkey" FOREIGN KEY ("organized_by") REFERENCES "User"("user_id") ON DELETE RESTRICT ON UPDATE CASCADE;

-- AddForeignKey
ALTER TABLE "CharityCampaign" ADD CONSTRAINT "CharityCampaign_bank_account_id_fkey" FOREIGN KEY ("bank_account_id") REFERENCES "BankAccount"("bank_account_id") ON DELETE SET NULL ON UPDATE CASCADE;

-- AddForeignKey
ALTER TABLE "CharityCampaign" ADD CONSTRAINT "CharityCampaign_checked_by_fkey" FOREIGN KEY ("checked_by") REFERENCES "User"("user_id") ON DELETE SET NULL ON UPDATE CASCADE;

-- AddForeignKey
ALTER TABLE "Transaction" ADD CONSTRAINT "Transaction_campaign_id_fkey" FOREIGN KEY ("campaign_id") REFERENCES "CharityCampaign"("campaign_id") ON DELETE RESTRICT ON UPDATE CASCADE;

-- AddForeignKey
ALTER TABLE "BankAccount" ADD CONSTRAINT "BankAccount_bank_id_fkey" FOREIGN KEY ("bank_id") REFERENCES "Bank"("id") ON DELETE RESTRICT ON UPDATE CASCADE;

-- AddForeignKey
ALTER TABLE "Supply" ADD CONSTRAINT "Supply_campaign_id_fkey" FOREIGN KEY ("campaign_id") REFERENCES "CharityCampaign"("campaign_id") ON DELETE RESTRICT ON UPDATE CASCADE;

-- AddForeignKey
ALTER TABLE "AnnouncementFromBenefactor" ADD CONSTRAINT "AnnouncementFromBenefactor_campaign_id_fkey" FOREIGN KEY ("campaign_id") REFERENCES "CharityCampaign"("campaign_id") ON DELETE RESTRICT ON UPDATE CASCADE;

-- AddForeignKey
ALTER TABLE "FinancialSupport" ADD CONSTRAINT "FinancialSupport_campaign_id_fkey" FOREIGN KEY ("campaign_id") REFERENCES "CharityCampaign"("campaign_id") ON DELETE RESTRICT ON UPDATE CASCADE;

-- AddForeignKey
ALTER TABLE "ChatRoom" ADD CONSTRAINT "ChatRoom_created_by_fkey" FOREIGN KEY ("created_by") REFERENCES "User"("user_id") ON DELETE SET NULL ON UPDATE CASCADE;

-- AddForeignKey
ALTER TABLE "Message" ADD CONSTRAINT "Message_room_id_fkey" FOREIGN KEY ("room_id") REFERENCES "ChatRoom"("room_id") ON DELETE RESTRICT ON UPDATE CASCADE;

-- AddForeignKey
ALTER TABLE "Message" ADD CONSTRAINT "Message_sent_by_fkey" FOREIGN KEY ("sent_by") REFERENCES "User"("user_id") ON DELETE RESTRICT ON UPDATE CASCADE;

-- AddForeignKey
ALTER TABLE "RoomMember" ADD CONSTRAINT "RoomMember_room_id_fkey" FOREIGN KEY ("room_id") REFERENCES "ChatRoom"("room_id") ON DELETE RESTRICT ON UPDATE CASCADE;

-- AddForeignKey
ALTER TABLE "RoomMember" ADD CONSTRAINT "RoomMember_member_id_fkey" FOREIGN KEY ("member_id") REFERENCES "User"("user_id") ON DELETE RESTRICT ON UPDATE CASCADE;

-- AddForeignKey
ALTER TABLE "RoleUpdatingRequest" ADD CONSTRAINT "RoleUpdatingRequest_profile_id_fkey" FOREIGN KEY ("profile_id") REFERENCES "Profile"("profile_id") ON DELETE RESTRICT ON UPDATE CASCADE;

-- AddForeignKey
ALTER TABLE "RoleUpdatingRequest" ADD CONSTRAINT "RoleUpdatingRequest_check_by_fkey" FOREIGN KEY ("check_by") REFERENCES "User"("user_id") ON DELETE SET NULL ON UPDATE CASCADE;

-- AddForeignKey
ALTER TABLE "ProfileUpdatingRequest" ADD CONSTRAINT "ProfileUpdatingRequest_current_profile_id_fkey" FOREIGN KEY ("current_profile_id") REFERENCES "Profile"("profile_id") ON DELETE RESTRICT ON UPDATE CASCADE;

-- AddForeignKey
ALTER TABLE "ProfileUpdatingRequest" ADD CONSTRAINT "ProfileUpdatingRequest_new_profile_id_fkey" FOREIGN KEY ("new_profile_id") REFERENCES "Profile"("profile_id") ON DELETE RESTRICT ON UPDATE CASCADE;

-- AddForeignKey
ALTER TABLE "ProfileUpdatingRequest" ADD CONSTRAINT "ProfileUpdatingRequest_checked_by_fkey" FOREIGN KEY ("checked_by") REFERENCES "User"("user_id") ON DELETE SET NULL ON UPDATE CASCADE;

-- AddForeignKey
ALTER TABLE "Signal" ADD CONSTRAINT "Signal_created_by_fkey" FOREIGN KEY ("created_by") REFERENCES "User"("user_id") ON DELETE RESTRICT ON UPDATE CASCADE;

-- AddForeignKey
ALTER TABLE "Signal" ADD CONSTRAINT "Signal_handled_by_fkey" FOREIGN KEY ("handled_by") REFERENCES "User"("user_id") ON DELETE SET NULL ON UPDATE CASCADE;

-- AddForeignKey
ALTER TABLE "Post" ADD CONSTRAINT "Post_created_by_fkey" FOREIGN KEY ("created_by") REFERENCES "User"("user_id") ON DELETE RESTRICT ON UPDATE CASCADE;

-- AddForeignKey
ALTER TABLE "Like" ADD CONSTRAINT "Like_post_id_fkey" FOREIGN KEY ("post_id") REFERENCES "Post"("post_id") ON DELETE RESTRICT ON UPDATE CASCADE;

-- AddForeignKey
ALTER TABLE "Like" ADD CONSTRAINT "Like_created_by_fkey" FOREIGN KEY ("created_by") REFERENCES "User"("user_id") ON DELETE RESTRICT ON UPDATE CASCADE;

-- AddForeignKey
ALTER TABLE "Comment" ADD CONSTRAINT "Comment_commented_by_fkey" FOREIGN KEY ("commented_by") REFERENCES "User"("user_id") ON DELETE RESTRICT ON UPDATE CASCADE;

-- AddForeignKey
ALTER TABLE "Comment" ADD CONSTRAINT "Comment_post_id_fkey" FOREIGN KEY ("post_id") REFERENCES "Post"("post_id") ON DELETE RESTRICT ON UPDATE CASCADE;

-- AddForeignKey
ALTER TABLE "Friendship" ADD CONSTRAINT "Friendship_user_id_fkey" FOREIGN KEY ("user_id") REFERENCES "User"("user_id") ON DELETE RESTRICT ON UPDATE CASCADE;

-- AddForeignKey
ALTER TABLE "Friendship" ADD CONSTRAINT "Friendship_friend_id_fkey" FOREIGN KEY ("friend_id") REFERENCES "User"("user_id") ON DELETE RESTRICT ON UPDATE CASCADE;

-- AddForeignKey
ALTER TABLE "FriendMakingRequest" ADD CONSTRAINT "FriendMakingRequest_created_by_fkey" FOREIGN KEY ("created_by") REFERENCES "User"("user_id") ON DELETE RESTRICT ON UPDATE CASCADE;

-- AddForeignKey
ALTER TABLE "FriendMakingRequest" ADD CONSTRAINT "FriendMakingRequest_sent_to_fkey" FOREIGN KEY ("sent_to") REFERENCES "User"("user_id") ON DELETE RESTRICT ON UPDATE CASCADE;

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

-- AddForeignKey
ALTER TABLE "Account" ADD CONSTRAINT "Account_user_id_fkey" FOREIGN KEY ("user_id") REFERENCES "User"("user_id") ON DELETE RESTRICT ON UPDATE CASCADE;

-- AddForeignKey
ALTER TABLE "Account" ADD CONSTRAINT "Account_provider_id_fkey" FOREIGN KEY ("provider_id") REFERENCES "Provider"("provider_id") ON DELETE SET NULL ON UPDATE CASCADE;

-- AddForeignKey
ALTER TABLE "Account" ADD CONSTRAINT "Account_created_by_fkey" FOREIGN KEY ("created_by") REFERENCES "Account"("account_id") ON DELETE SET NULL ON UPDATE CASCADE;

-- AddForeignKey
ALTER TABLE "Session" ADD CONSTRAINT "Session_account_id_fkey" FOREIGN KEY ("account_id") REFERENCES "Account"("account_id") ON DELETE RESTRICT ON UPDATE CASCADE;

-- AddForeignKey
ALTER TABLE "Ward" ADD CONSTRAINT "Ward_province_code_fkey" FOREIGN KEY ("province_code") REFERENCES "Province"("code") ON DELETE RESTRICT ON UPDATE CASCADE;

