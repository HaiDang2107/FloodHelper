-- CreateTable
CREATE TABLE "RoleUpdatingRequest" (
    "request_id" UUID NOT NULL,
    "created_by" UUID NOT NULL,
    "type" TEXT NOT NULL,
    "state" TEXT NOT NULL,
    "note" TEXT,
    "created_at" TIMESTAMP(3) NOT NULL DEFAULT CURRENT_TIMESTAMP,
    "responsed_at" TIMESTAMP(3),

    CONSTRAINT "RoleUpdatingRequest_pkey" PRIMARY KEY ("request_id")
);

-- CreateTable
CREATE TABLE "PublicAnnouncement" (
    "announcement_id" UUID NOT NULL,
    "publisher_id" TEXT NOT NULL,
    "document_url" TEXT,
    "text_content" TEXT,

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
    "campaign_name" TEXT NOT NULL,
    "purpose" TEXT NOT NULL,
    "destination" TEXT NOT NULL,
    "charity_object" TEXT NOT NULL,
    "state" TEXT NOT NULL,
    "start_distribution_at" TIMESTAMP(3),
    "finish_distribution_at" TIMESTAMP(3),
    "bank_statement_file_url" TEXT,
    "created_at" TIMESTAMP(3) NOT NULL DEFAULT CURRENT_TIMESTAMP,

    CONSTRAINT "CharityCampaign_pkey" PRIMARY KEY ("campaign_id")
);

-- CreateTable
CREATE TABLE "Transaction" (
    "transaction_id" UUID NOT NULL,
    "campaign_id" UUID NOT NULL,
    "transfer_type" TEXT NOT NULL,
    "donate_at" TIMESTAMP(3) NOT NULL,
    "transfer_by" TEXT,
    "transfer_amount" DECIMAL(15,2) NOT NULL,
    "message" TEXT,

    CONSTRAINT "Transaction_pkey" PRIMARY KEY ("transaction_id")
);

-- CreateTable
CREATE TABLE "BankAccount" (
    "bank_account_id" UUID NOT NULL,
    "campaign_id" UUID NOT NULL,
    "bank_name" TEXT NOT NULL,
    "bank_account_name" TEXT NOT NULL,
    "bank_account_number" TEXT NOT NULL,
    "balance" DECIMAL(65,30) NOT NULL DEFAULT 0,

    CONSTRAINT "BankAccount_pkey" PRIMARY KEY ("bank_account_id")
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
    "text_content" TEXT,
    "image_url" TEXT,

    CONSTRAINT "AnnouncementFromBenefactor_pkey" PRIMARY KEY ("announcement_id")
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
CREATE TABLE "Signal" (
    "signal_id" UUID NOT NULL,
    "created_by" UUID NOT NULL,
    "trapped_count" INTEGER NOT NULL DEFAULT 0,
    "has_children" BOOLEAN NOT NULL DEFAULT false,
    "has_elderly" BOOLEAN NOT NULL DEFAULT false,
    "has_food" BOOLEAN NOT NULL DEFAULT false,
    "note" TEXT,
    "created_at" TIMESTAMP(3) NOT NULL DEFAULT CURRENT_TIMESTAMP,
    "handled_at" TIMESTAMP(3),
    "deleted_at" TIMESTAMP(3),

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
    "friend_map_mode" BOOLEAN NOT NULL DEFAULT false,
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
    "name" VARCHAR(255) NOT NULL,
    "display_name" TEXT,
    "dob" DATE,
    "village" TEXT,
    "district" TEXT,
    "country" TEXT,
    "role" TEXT[] DEFAULT ARRAY['GUEST']::TEXT[],
    "cur_longitude" DECIMAL(10,7),
    "cur_latitude" DECIMAL(10,7),
    "public_map_mode" BOOLEAN NOT NULL DEFAULT false,
    "avatar_url" TEXT,
    "citizen_id" TEXT,
    "phone_number" TEXT NOT NULL,
    "citizen_id_card_img" TEXT,
    "job_position" TEXT,

    CONSTRAINT "User_pkey" PRIMARY KEY ("user_id")
);

-- CreateTable
CREATE TABLE "Account" (
    "account_id" UUID NOT NULL,
    "user_id" UUID NOT NULL,
    "provider_id" UUID,
    "created_by" UUID,
    "username" TEXT NOT NULL,
    "password" TEXT NOT NULL,
    "state" TEXT NOT NULL DEFAULT 'ACTIVE',
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
CREATE TABLE "VerificationCode" (
    "verification_id" UUID NOT NULL,
    "account_id" UUID NOT NULL,
    "code" TEXT NOT NULL,
    "type" TEXT NOT NULL,
    "expires_at" TIMESTAMP(3) NOT NULL,
    "created_at" TIMESTAMP(3) NOT NULL DEFAULT CURRENT_TIMESTAMP,

    CONSTRAINT "VerificationCode_pkey" PRIMARY KEY ("verification_id")
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
CREATE UNIQUE INDEX "User_phone_number_key" ON "User"("phone_number");

-- CreateIndex
CREATE UNIQUE INDEX "Account_user_id_key" ON "Account"("user_id");

-- CreateIndex
CREATE UNIQUE INDEX "Account_username_key" ON "Account"("username");

-- CreateIndex
CREATE UNIQUE INDEX "VerificationCode_code_key" ON "VerificationCode"("code");

-- AddForeignKey
ALTER TABLE "RoleUpdatingRequest" ADD CONSTRAINT "RoleUpdatingRequest_created_by_fkey" FOREIGN KEY ("created_by") REFERENCES "User"("user_id") ON DELETE RESTRICT ON UPDATE CASCADE;

-- AddForeignKey
ALTER TABLE "CharityCampaign" ADD CONSTRAINT "CharityCampaign_organized_by_fkey" FOREIGN KEY ("organized_by") REFERENCES "User"("user_id") ON DELETE RESTRICT ON UPDATE CASCADE;

-- AddForeignKey
ALTER TABLE "Transaction" ADD CONSTRAINT "Transaction_campaign_id_fkey" FOREIGN KEY ("campaign_id") REFERENCES "CharityCampaign"("campaign_id") ON DELETE RESTRICT ON UPDATE CASCADE;

-- AddForeignKey
ALTER TABLE "BankAccount" ADD CONSTRAINT "BankAccount_campaign_id_fkey" FOREIGN KEY ("campaign_id") REFERENCES "CharityCampaign"("campaign_id") ON DELETE RESTRICT ON UPDATE CASCADE;

-- AddForeignKey
ALTER TABLE "Supply" ADD CONSTRAINT "Supply_campaign_id_fkey" FOREIGN KEY ("campaign_id") REFERENCES "CharityCampaign"("campaign_id") ON DELETE RESTRICT ON UPDATE CASCADE;

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
ALTER TABLE "Signal" ADD CONSTRAINT "Signal_created_by_fkey" FOREIGN KEY ("created_by") REFERENCES "User"("user_id") ON DELETE RESTRICT ON UPDATE CASCADE;

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
ALTER TABLE "Account" ADD CONSTRAINT "Account_user_id_fkey" FOREIGN KEY ("user_id") REFERENCES "User"("user_id") ON DELETE RESTRICT ON UPDATE CASCADE;

-- AddForeignKey
ALTER TABLE "Account" ADD CONSTRAINT "Account_provider_id_fkey" FOREIGN KEY ("provider_id") REFERENCES "Provider"("provider_id") ON DELETE SET NULL ON UPDATE CASCADE;

-- AddForeignKey
ALTER TABLE "Account" ADD CONSTRAINT "Account_created_by_fkey" FOREIGN KEY ("created_by") REFERENCES "Account"("account_id") ON DELETE SET NULL ON UPDATE CASCADE;

-- AddForeignKey
ALTER TABLE "Session" ADD CONSTRAINT "Session_account_id_fkey" FOREIGN KEY ("account_id") REFERENCES "Account"("account_id") ON DELETE RESTRICT ON UPDATE CASCADE;

-- AddForeignKey
ALTER TABLE "VerificationCode" ADD CONSTRAINT "VerificationCode_account_id_fkey" FOREIGN KEY ("account_id") REFERENCES "Account"("account_id") ON DELETE RESTRICT ON UPDATE CASCADE;
