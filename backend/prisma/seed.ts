import { PrismaClient } from '@prisma/client';
import * as bcrypt from 'bcrypt';
import { randomUUID } from 'crypto';

const prisma = new PrismaClient();

async function main() {
  console.log('🌱 Starting seed...');

  // 1. Create Users
  const users = await Promise.all([
    prisma.user.create({
      data: {
        userId: randomUUID(),
        fullname: 'Nguyễn Văn An',
        nickname: 'An Nguyen',
        dob: new Date('1990-05-15'),
        placeOfOrigin: 'Thanh Xuân, Hà Nội, Việt Nam',
        placeOfResidence: 'Thanh Xuân, Hà Nội, Việt Nam',
        role: ['NORMAL_USER'],
        curLongitude: 105.8542,
        curLatitude: 21.0285,
        visibilityMode: 'PUBLIC',
        avatarUrl: 'https://i.pravatar.cc/150?img=12',
        phoneNumber: '+84901234567',
        dateOfIssue: new Date('2016-01-15'),
        dateOfExpire: new Date('2031-01-15'),
        citizenId: '001090123456',
        jobPosition: 'Software Engineer',
      },
    }),
    prisma.user.create({
      data: {
        userId: randomUUID(),
        fullname: 'Trần Thị Bình',
        nickname: 'Binh Tran',
        dob: new Date('1988-03-22'),
        placeOfOrigin: 'Đống Đa, Hà Nội, Việt Nam',
        placeOfResidence: 'Đống Đa, Hà Nội, Việt Nam',
        role: ['NORMAL_USER'],
        curLongitude: 105.8550,
        curLatitude: 21.0290,
        visibilityMode: 'JUST_FRIEND',
        avatarUrl: 'https://i.pravatar.cc/150?img=45',
        phoneNumber: '+84902345678',
        dateOfIssue: new Date('2015-04-10'),
        dateOfExpire: new Date('2030-04-10'),
        citizenId: '001088234567',
        jobPosition: 'Teacher',
      },
    }),
    prisma.user.create({
      data: {
        userId: randomUUID(),
        fullname: 'Lê Văn Cường',
        nickname: 'Cuong Le',
        dob: new Date('1992-11-08'),
        placeOfOrigin: 'Cầu Giấy, Hà Nội, Việt Nam',
        placeOfResidence: 'Cầu Giấy, Hà Nội, Việt Nam',
        role: ['RESCUER'],
        curLongitude: 105.8530,
        curLatitude: 21.0275,
        visibilityMode: 'PUBLIC',
        avatarUrl: 'https://i.pravatar.cc/150?img=68',
        phoneNumber: '+84903456789',
        dateOfIssue: new Date('2017-06-05'),
        dateOfExpire: new Date('2032-06-05'),
        citizenId: '001092345678',
        jobPosition: 'Rescue Worker',
      },
    }),
    prisma.user.create({
      data: {
        userId: randomUUID(),
        fullname: 'Phạm Thị Dung',
        nickname: 'Dung Pham',
        dob: new Date('1985-07-30'),
        placeOfOrigin: 'Hoàn Kiếm, Hà Nội, Việt Nam',
        placeOfResidence: 'Hoàn Kiếm, Hà Nội, Việt Nam',
        role: ['BENEFACTOR'],
        curLongitude: 105.8530,
        curLatitude: 21.0300,
        visibilityMode: 'PUBLIC',
        avatarUrl: 'https://i.pravatar.cc/150?img=20',
        phoneNumber: '+84904567890',
        dateOfIssue: new Date('2014-08-20'),
        dateOfExpire: new Date('2029-08-20'),
        citizenId: '001085456789',
        jobPosition: 'Doctor',
      },
    }),
    prisma.user.create({
      data: {
        userId: randomUUID(),
        fullname: 'Hoàng Văn Em',
        nickname: 'Em Hoang',
        dob: new Date('1995-01-12'),
        placeOfOrigin: 'Ba Đình, Hà Nội, Việt Nam',
        placeOfResidence: 'Ba Đình, Hà Nội, Việt Nam',
        role: ['BENEFACTOR'],
        curLongitude: 105.8560,
        curLatitude: 21.0260,
        visibilityMode: 'JUST_FRIEND',
        avatarUrl: 'https://i.pravatar.cc/150?img=11',
        phoneNumber: '+84905678901',
        dateOfIssue: new Date('2018-09-10'),
        dateOfExpire: new Date('2033-09-10'),
        citizenId: '001095567890',
        jobPosition: 'Student',
      },
    }),
    prisma.user.create({
      data: {
        userId: randomUUID(),
        fullname: 'Trần Văn Minh',
        nickname: 'Minh Tran',
        dob: new Date('1975-03-10'),
        placeOfOrigin: 'Hai Bà Trưng, Hà Nội, Việt Nam',
        placeOfResidence: 'Hai Bà Trưng, Hà Nội, Việt Nam',
        role: ['AUTHORITY'],
        curLongitude: 105.8570,
        curLatitude: 21.0310,
        visibilityMode: 'PUBLIC',
        avatarUrl: 'https://i.pravatar.cc/150?img=33',
        phoneNumber: '+84906789012',
        dateOfIssue: new Date('2012-11-01'),
        dateOfExpire: new Date('2027-11-01'),
        citizenId: '001075678901',
        jobPosition: 'Government Official',
      },
    }),
    prisma.user.create({
      data: {
        userId: randomUUID(),
        fullname: 'Nguyễn Thị Nga',
        nickname: 'Lan Nguyen',
        dob: new Date('1980-08-25'),
        placeOfOrigin: 'Tây Hồ, Hà Nội, Việt Nam',
        placeOfResidence: 'Tây Hồ, Hà Nội, Việt Nam',
        role: ['ADMIN'],
        curLongitude: 105.8580,
        curLatitude: 21.0320,
        visibilityMode: 'PUBLIC',
        avatarUrl: 'https://i.pravatar.cc/150?img=25',
        phoneNumber: '+84907890123',
        dateOfIssue: new Date('2011-02-18'),
        dateOfExpire: new Date('2026-02-18'),
        citizenId: '001080789012',
        jobPosition: 'System Administrator',
      },
    }),
  ]);

  console.log('✅ Created users');

  // 2. Create Accounts
  const accounts = await Promise.all([
    prisma.account.create({
      data: {
        accountId: randomUUID(),
        userId: users[0].userId,
        username: 'anguyen',
        password: await bcrypt.hash('password123', 10),
        state: 'ACTIVE',
        createdAt: new Date('2023-01-15'),
      },
    }),
    prisma.account.create({
      data: {
        accountId: randomUUID(),
        userId: users[1].userId,
        username: 'btran',
        password: await bcrypt.hash('password123', 10),
        state: 'ACTIVE',
        createdAt: new Date('2023-02-20'),
      },
    }),
    prisma.account.create({
      data: {
        accountId: randomUUID(),
        userId: users[2].userId,
        username: 'cle',
        password: await bcrypt.hash('rescuer456', 10),
        state: 'ACTIVE',
        createdAt: new Date('2023-03-10'),
      },
    }),
    prisma.account.create({
      data: {
        accountId: randomUUID(),
        userId: users[5].userId,
        username: 'mtran',
        password: await bcrypt.hash('authority789', 10),
        state: 'ACTIVE',
        createdAt: new Date('2023-04-01'),
      },
    }),
    prisma.account.create({
      data: {
        accountId: randomUUID(),
        userId: users[6].userId,
        username: 'lnguyen',
        password: await bcrypt.hash('admin999', 10),
        state: 'ACTIVE',
        createdAt: new Date('2023-04-15'),
      },
    }),
  ]);

  console.log('✅ Created accounts');

  // 3. Create Friendships
  const friendships = await Promise.all([
    prisma.friendship.create({
      data: {
        userId: users[0].userId,
        friendId: users[1].userId,
        friendMapMode: true,
        lastLongitude: 105.8542,
        lastLatitude: 21.0285,
        lastDataAt: new Date(),
      },
    }),
    prisma.friendship.create({
      data: {
        userId: users[0].userId,
        friendId: users[2].userId,
        friendMapMode: false,
        lastLongitude: 105.8530,
        lastLatitude: 21.0275,
        lastDataAt: new Date(),
      },
    }),
    prisma.friendship.create({
      data: {
        userId: users[1].userId,
        friendId: users[3].userId,
        friendMapMode: true,
        lastLongitude: 105.8560,
        lastLatitude: 21.0300,
        lastDataAt: new Date(),
      },
    }),
  ]);

  console.log('✅ Created friendships');

  // 4. Create Posts
  const posts = await Promise.all([
    prisma.post.create({
      data: {
        postId: randomUUID(),
        createdBy: users[0].userId,
        caption: 'Flood situation on Main Street. Water level is rising rapidly! Please stay safe everyone.',
        imageUrl: 'https://picsum.photos/400/300?random=1',
        longitude: 105.8548,
        latitude: 21.0290,
        createdAt: new Date('2023-10-15T10:30:00Z'),
      },
    }),
    prisma.post.create({
      data: {
        postId: randomUUID(),
        createdBy: users[1].userId,
        caption: 'Road blocked due to flooding. Please find alternative route. Emergency services are on the way.',
        imageUrl: 'https://picsum.photos/400/300?random=2',
        longitude: 105.8555,
        latitude: 21.0280,
        createdAt: new Date('2023-10-15T11:15:00Z'),
      },
    }),
    prisma.post.create({
      data: {
        postId: randomUUID(),
        createdBy: users[2].userId,
        caption: 'Emergency supplies distribution point here. Food and water available for those in need.',
        imageUrl: 'https://picsum.photos/400/300?random=3',
        longitude: 105.8538,
        latitude: 21.0295,
        createdAt: new Date('2023-10-15T09:45:00Z'),
      },
    }),
    prisma.post.create({
      data: {
        postId: randomUUID(),
        createdBy: users[3].userId,
        caption: 'Rescue boat available in this area. Contact for help if you need immediate assistance.',
        imageUrl: 'https://picsum.photos/400/300?random=4',
        longitude: 105.8565,
        latitude: 21.0300,
        createdAt: new Date('2023-10-15T08:20:00Z'),
      },
    }),
    prisma.post.create({
      data: {
        postId: randomUUID(),
        createdBy: users[4].userId,
        caption: 'Safe zone established. Evacuees welcome here. We have shelter and medical assistance.',
        imageUrl: 'https://picsum.photos/400/300?random=5',
        longitude: 105.8525,
        latitude: 21.0270,
        createdAt: new Date('2023-10-15T12:00:00Z'),
      },
    }),
  ]);

  console.log('✅ Created posts');

  // 5. Create Likes
  const likes = await Promise.all([
    prisma.like.create({
      data: {
        postId: posts[0].postId,
        createdBy: users[1].userId,
        createdAt: new Date('2023-10-15T10:35:00Z'),
      },
    }),
    prisma.like.create({
      data: {
        postId: posts[0].postId,
        createdBy: users[2].userId,
        createdAt: new Date('2023-10-15T10:40:00Z'),
      },
    }),
    prisma.like.create({
      data: {
        postId: posts[2].postId,
        createdBy: users[0].userId,
        createdAt: new Date('2023-10-15T09:50:00Z'),
      },
    }),
    prisma.like.create({
      data: {
        postId: posts[2].postId,
        createdBy: users[3].userId,
        createdAt: new Date('2023-10-15T10:00:00Z'),
      },
    }),
  ]);

  console.log('✅ Created likes');

  // 6. Create Comments
  const comments = await Promise.all([
    prisma.comment.create({
      data: {
        postId: posts[0].postId,
        commentedBy: users[1].userId,
        // content: 'Stay safe everyone! Is there any evacuation plan?',
        createdAt: new Date('2023-10-15T10:35:00Z'),
      },
    }),
    prisma.comment.create({
      data: {
        postId: posts[0].postId,
        commentedBy: users[2].userId,
        // content: 'Thanks for the update. Authorities have been notified.',
        createdAt: new Date('2023-10-15T10:40:00Z'),
      },
    }),
    prisma.comment.create({
      data: {
        postId: posts[2].postId,
        commentedBy: users[3].userId,
        // content: 'Great work! Thank you so much for helping others.',
        createdAt: new Date('2023-10-15T09:50:00Z'),
      },
    }),
  ]);

  console.log('✅ Created comments');

  // 7. Create Charity Campaigns
  const campaigns = await Promise.all([
    prisma.charityCampaign.create({
      data: {
        campaignId: randomUUID(),
        campaignName: 'Flood Relief Fund 2023',
        purpose: 'Supporting families affected by recent flooding in Hanoi. Your donation helps provide food, shelter, and medical assistance.',
        destination: 'Hanoi, Vietnam',
        charityObject: 'Flood victims and their families',
        organizedBy: users[2].userId,
        startDonationAt: new Date('2023-10-01'),
        finishDonationAt: new Date('2023-12-31'),
        state: 'ACTIVE',
        createdAt: new Date('2023-10-01'),
      },
    }),
    prisma.charityCampaign.create({
      data: {
        campaignId: randomUUID(),
        campaignName: 'Emergency Rescue Equipment',
        purpose: 'Funding for rescue boats, life jackets, and emergency supplies for flood rescue operations.',
        destination: 'Hanoi flood zones',
        charityObject: 'Rescue teams and emergency services',
        organizedBy: users[3].userId,
        startDonationAt: new Date('2023-09-15'),
        finishDonationAt: new Date('2023-11-15'),
        state: 'COMPLETED',
        createdAt: new Date('2023-09-15'),
      },
    }),
  ]);

  console.log('✅ Created charity campaigns');

  // 8. Create Transactions
  const transactions = await Promise.all([
    prisma.transaction.create({
      data: {
        transactionId: randomUUID(),
        campaignId: campaigns[0].campaignId,
        transferType: 'IN',
        donateAt: new Date('2023-10-05'),
        transferBy: 'Anonymous Donor',
        transferAmount: 5000.00,
        message: 'Stay strong Hanoi!',
      },
    }),
    prisma.transaction.create({
      data: {
        transactionId: randomUUID(),
        campaignId: campaigns[0].campaignId,
        transferType: 'IN',
        donateAt: new Date('2023-10-10'),
        transferBy: 'Corporate Sponsor',
        transferAmount: 7500.00,
        message: 'Supporting our community',
      },
    }),
  ]);

  console.log('✅ Created transactions');

  // 9. Create Signals (SOS)
  const signals = await Promise.all([
    prisma.signal.create({
      data: {
        signalId: randomUUID(),
        createdBy: users[0].userId,
        trappedCount: 3,
        childrenNum: 1,
        elderlyNum: 1,
        hasFood: false,
        hasWater: false,
        state: 'BROADCASTING',
        note: 'Family trapped on roof, urgent rescue needed. Children and elderly present.',
        createdAt: new Date('2023-10-15T14:30:00Z'),
      },
    }),
    prisma.signal.create({
      data: {
        signalId: randomUUID(),
        createdBy: users[1].userId,
        trappedCount: 1,
        childrenNum: 0,
        elderlyNum: 0,
        hasFood: true,
        hasWater: true,
        state: 'BROADCASTING',
        note: 'Stuck in flooded area, have some food but need evacuation.',
        createdAt: new Date('2023-10-15T16:45:00Z'),
      },
    }),
  ]);

  console.log('✅ Created signals');

  // 10. Create Chat Rooms
  const chatRooms = await Promise.all([
    prisma.chatRoom.create({
      data: {
        roomId: randomUUID(),
        createdBy: users[0].userId,
        memberCount: 3,
      },
    }),
    prisma.chatRoom.create({
      data: {
        roomId: randomUUID(),
        createdBy: users[1].userId,
        memberCount: 2,
      },
    }),
  ]);

  console.log('✅ Created chat rooms');

  // 11. Create Messages
  const messages = await Promise.all([
    prisma.message.create({
      data: {
        messageId: randomUUID(),
        roomId: chatRooms[0].roomId,
        sentBy: users[2].userId,
        type: 'TEXT',
        // content: 'Emergency rescue team heading to Main Street. Please stay calm.',
        sentAt: new Date('2023-10-15T14:35:00Z'),
      },
    }),
    prisma.message.create({
      data: {
        messageId: randomUUID(),
        roomId: chatRooms[0].roomId,
        sentBy: users[0].userId,
        type: 'TEXT',
        // content: 'Thank you! We can see the rescue boat approaching.',
        sentAt: new Date('2023-10-15T14:40:00Z'),
      },
    }),
  ]);

  console.log('✅ Created messages');

  // Verification codes creation removed from seed (managed dynamically in application)

  console.log('🎉 Seed completed successfully!');
  console.log(`📊 Summary:
  - ${users.length} users
  - ${accounts.length} accounts
  - ${friendships.length} friendships
  - ${posts.length} posts
  - ${likes.length} likes
  - ${comments.length} comments
  - ${campaigns.length} charity campaigns
  - ${transactions.length} transactions
  - ${signals.length} signals
  - ${chatRooms.length} chat rooms
  - ${messages.length} messages
  `);
}

main()
  .catch((e) => {
    console.error('❌ Seed failed:', e);
    process.exit(1);
  })
  .finally(async () => {
    await prisma.$disconnect();
  });