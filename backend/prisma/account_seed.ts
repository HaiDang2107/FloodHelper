import { PrismaClient } from '@prisma/client';
import * as bcrypt from 'bcrypt'; // Nếu bạn dùng bcrypt để hash password

const prisma = new PrismaClient();

async function seedAccount() {
  const TARGET_USER_ID = '41e99818-a134-4b45-b108-95257ded0d8c';
  
  // 1. Kiểm tra xem User có tồn tại không để tránh lỗi Foreign Key
  const user = await prisma.user.findUnique({
    where: { userId: TARGET_USER_ID },
  });

  if (!user) {
    console.error('Lỗi: Không tìm thấy User với ID đã cho. Hãy đảm bảo bạn đã tạo User trước.');
    return;
  }

  // 2. Tạo Account cho User đó
  const newAccount = await prisma.account.upsert({
    where: { userId: TARGET_USER_ID }, // Vì userId là @unique
    update: {}, // Nếu đã có rồi thì không làm gì cả
    create: {
      userId: TARGET_USER_ID,
      username: 'flood_helper_admin', // Bạn có thể đổi username tùy ý
      // Password mẫu đã hash (tương ứng với "123456")
      password: await bcrypt.hash('123456', 10), 
      state: 'ACTIVE', // Chuyển sang ACTIVE để có thể đăng nhập ngay
      createdAt: new Date(),
    },
  });

  console.log('--- Đã tạo tài khoản thành công ---');
  console.log(newAccount);
}

seedAccount()
  .catch((e) => {
    console.error(e);
    process.exit(1);
  })
  .finally(async () => {
    await prisma.$disconnect();
  });