import { PrismaClient } from '@prisma/client';

const prisma = new PrismaClient();

async function main() {
  // Giả định bạn đã có ít nhất một User trong DB để làm Organizer.
  // Nếu chưa có, bạn cần tạo User trước hoặc thay userId dưới đây bằng ID thật.
  const organizerId1 = 'c2e07c6d-c526-4901-b00b-376503f411ea'; 
  const organizerId2 = 'ca56cc23-9f84-4fe7-b58e-175312fe6ff7'; 

  const campaigns = [
    {
      campaignName: 'Cứu trợ lũ lụt khẩn cấp tại Quảng Bình',
      organizedBy: organizerId1,
      purpose: 'Cung cấp lương thực và nước sạch cho các hộ dân bị cô lập.',
      destination: 'Lệ Thủy, Quảng Bình',
      charityObject: 'Người dân vùng rốn lũ',
      state: 'DONATING',
      startDonationAt: new Date('2026-04-01T08:00:00Z'),
      finishDonationAt: new Date('2026-04-15T18:00:00Z'),
    },
    {
      campaignName: 'Hỗ trợ cây giống sau bão tại Hà Tĩnh',
      organizedBy: organizerId2,
      purpose: 'Phục hồi sản xuất nông nghiệp cho bà con sau thiên tai.',
      destination: 'Hương Khê, Hà Tĩnh',
      charityObject: 'Hộ nông dân nghèo',
      state: 'DISTRIBUTING',
      startDonationAt: new Date('2026-03-01T08:00:00Z'),
      finishDonationAt: new Date('2026-03-25T18:00:00Z'),
      startDistributionAt: new Date('2026-04-01T08:00:00Z'),
    },
    {
      campaignName: 'Xây dựng nhà chống lũ tại Thừa Thiên Huế',
      organizedBy: organizerId1,
      purpose: 'Xây dựng 10 căn nhà an toàn cho các hộ gia đình vùng hạ lưu.',
      destination: 'Quảng Điền, Thừa Thiên Huế',
      charityObject: 'Người già neo đơn và hộ nghèo',
      state: 'FINISHED',
      startDonationAt: new Date('2026-01-10T08:00:00Z'),
      finishDonationAt: new Date('2026-02-10T18:00:00Z'),
      startDistributionAt: new Date('2026-02-15T08:00:00Z'),
      finishDistributionAt: new Date('2026-03-30T18:00:00Z'),
    },
    {
      campaignName: 'Quỹ học bổng FloodHelper 2026',
      organizedBy: organizerId2,
      purpose: 'Tặng sách vở và học bổng cho học sinh vùng lũ quay lại trường.',
      destination: 'Tỉnh Yên Bái',
      charityObject: 'Học sinh tiểu học và trung học',
      state: 'DONATING',
      startDonationAt: new Date('2026-04-05T08:00:00Z'),
      finishDonationAt: new Date('2026-05-05T18:00:00Z'),
    },
  ];

  console.log('Đang bắt đầu seed dữ liệu Campaign...');

  for (const c of campaigns) {
    await prisma.charityCampaign.create({
      data: c,
    });
  }

  console.log('Đã tạo thành công 4 chiến dịch mẫu!');
}

main()
  .catch((e) => {
    console.error(e);
    process.exit(1);
  })
  .finally(async () => {
    await prisma.$disconnect();
  });