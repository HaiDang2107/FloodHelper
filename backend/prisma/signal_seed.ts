import { PrismaClient, SignalState } from '@prisma/client';

const prisma = new PrismaClient();

async function main() {
  console.log('--- Đang bắt đầu quá trình seed bổ sung dữ liệu ---');

  // 1. Tạo thêm 4 User mới (Sử dụng upsert để tránh trùng lặp số điện thoại)
  const users = await Promise.all([
    prisma.user.upsert({
      where: { phoneNumber: '0911111111' },
      update: {},
      create: {
        fullname: 'Phạm Văn C',
        phoneNumber: '0911111111',
        role: ['NORMAL_USER'],
        visibilityMode: 'PUBLIC',
      },
    }),
    prisma.user.upsert({
      where: { phoneNumber: '0922222222' },
      update: {},
      create: {
        fullname: 'Lê Thị D',
        phoneNumber: '0922222222',
        role: ['NORMAL_USER'],
        visibilityMode: 'JUST_FRIEND',
      },
    }),
    prisma.user.upsert({
      where: { phoneNumber: '0933333333' },
      update: {},
      create: {
        fullname: 'Hoàng Văn E (Cứu hộ viên)',
        phoneNumber: '0933333333',
        role: ['RESCUER'],
        visibilityMode: 'PUBLIC',
      },
    }),
    prisma.user.upsert({
      where: { phoneNumber: '0944444444' },
      update: {},
      create: {
        fullname: 'Ngô Văn F',
        phoneNumber: '0944444444',
        role: ['NORMAL_USER'],
        visibilityMode: 'PUBLIC',
      },
    }),
  ]);

  const [u3, u4, u5, u6] = users;
  console.log('Đã tạo/cập nhật xong 4 User mới.');

  // 2. Tạo 6 Signal (4 BROADCASTING, 1 HANDLED, 1 STOPPED)
  const signalsData = [
    // 4 Signal trạng thái BROADCASTING
    {
      createdBy: u3.userId,
      trappedCount: 3,
      childrenNum: 1,
      elderlyNum: 0,
      hasFood: false,
      hasWater: false,
      state: SignalState.BROADCASTING,
      note: 'Gia đình 3 người đang ở trên tầng thượng, nước đã ngập tầng 1.',
    },
    {
      createdBy: u4.userId,
      trappedCount: 5,
      childrenNum: 2,
      elderlyNum: 2,
      hasFood: true,
      hasWater: false,
      state: SignalState.BROADCASTING,
      note: 'Cần nước sạch gấp, có người già đang sốt.',
    },
    {
      createdBy: u6.userId,
      trappedCount: 1,
      childrenNum: 0,
      elderlyNum: 0,
      hasFood: false,
      hasWater: false,
      state: SignalState.BROADCASTING,
      note: 'Bị kẹt trong khu vực sạt lở, một mình, điện thoại sắp hết pin.',
    },
    {
      createdBy: u3.userId,
      trappedCount: 2,
      childrenNum: 0,
      elderlyNum: 1,
      hasFood: false,
      hasWater: true,
      state: SignalState.BROADCASTING,
      note: 'Cần hỗ trợ di chuyển người già không đi lại được.',
    },
    // 1 Signal trạng thái HANDLED
    {
      createdBy: u4.userId,
      handledBy: u5.userId,
      trappedCount: 4,
      childrenNum: 1,
      elderlyNum: 1,
      hasFood: true,
      hasWater: true,
      state: SignalState.HANDLED,
      note: 'Đã liên lạc được với đội cứu hộ, đang đợi xuồng đến.',
      handledAt: new Date(),
    },
    // 1 Signal trạng thái STOPPED
    {
      createdBy: u6.userId,
      trappedCount: 2,
      childrenNum: 1,
      elderlyNum: 0,
      hasFood: true,
      hasWater: true,
      state: SignalState.STOPPED,
      note: 'Đã an toàn, đã được người dân địa phương hỗ trợ.',
      stoppedAt: new Date(),
    },
  ];

  console.log('Đang khởi tạo 6 tín hiệu cứu hộ...');
  
  for (const signal of signalsData) {
    await prisma.signal.create({
      data: signal,
    });
  }

  console.log('Hoàn thành seed 4 User và 6 Signal!');
}

main()
  .then(async () => {
    await prisma.$disconnect();
  })
  .catch(async (e) => {
    console.error(e);
    await prisma.$disconnect();
    process.exit(1);
  });