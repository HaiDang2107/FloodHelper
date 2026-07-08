import { PrismaClient, Prisma } from '@prisma/client';
import * as fs from 'fs';
import * as path from 'path';
import * as bcrypt from 'bcrypt';

const prisma = new PrismaClient();

async function main() {
  console.log('Bắt đầu quá trình seed dữ liệu...');

  // 1. ĐỌC VÀ NẠP DỮ LIỆU NGÂN HÀNG
  const banksPath = path.join(__dirname, '../fetch_data/banks.json'); 
  
  if (fs.existsSync(banksPath)) {
    const banksRaw = fs.readFileSync(banksPath, 'utf-8');
    const banksData = JSON.parse(banksRaw);
    const banks = banksData.data || banksData; 
    
    console.log(`⏳ Đang nạp ${banks.length} ngân hàng...`);
    await prisma.bank.createMany({
      data: banks.map((b: any) => ({
        id: b.id,
        name: b.name,
        code: b.code,
        bin: String(b.bin),
        shortName: b.shortName,
      })),
      skipDuplicates: true,
    });
    console.log('✅ Nạp dữ liệu Ngân hàng thành công!');
  } else {
    console.log('⚠️ Không tìm thấy file banks.json, bỏ qua bước này.');
  }

  // 2. ĐỌC VÀ NẠP DỮ LIỆU TỈNH THÀNH & PHƯỜNG XÃ (WARD)
  const provincesPath = path.join(__dirname, '../fetch_data/provinces.json');
  
  if (fs.existsSync(provincesPath)) {
    const provincesRaw = fs.readFileSync(provincesPath, 'utf-8');
    const provincesData = JSON.parse(provincesRaw);
    
    // Mảng chứa toàn bộ phường/xã để insert 1 lần cho tối ưu hiệu suất
    const wardsToInsert: any[] = [];

    const provincesToInsert = provincesData.map((p: any) => {
      // Nếu có mảng wards bên trong JSON
      if (p.wards && p.wards.length > 0) {
        p.wards.forEach((w: any) => {
          wardsToInsert.push({
            code: w.code,
            name: w.name,
            divisionType: w.division_type,
            codename: w.codename,
            provinceCode: p.code, // Gắn ID của tỉnh/thành hiện tại vào phường/xã
          });
        });
      }

      // Trả về object Province chuẩn bị insert
      return {
        code: p.code,
        name: p.name,
        divisionType: p.division_type,
        codename: p.codename,
        phoneCode: p.phone_code,
      };
    });

    console.log(`⏳ Đang nạp ${provincesToInsert.length} tỉnh/thành phố...`);
    // Chèn Tỉnh/Thành phố trước để tạo khóa chính
    await prisma.province.createMany({
      data: provincesToInsert,
      skipDuplicates: true,
    });
    console.log('✅ Nạp dữ liệu Tỉnh/Thành phố thành công!');

    if (wardsToInsert.length > 0) {
      console.log(`⏳ Đang nạp ${wardsToInsert.length} phường/xã...`);
      // Chèn Phường/Xã sau cùng
      await prisma.ward.createMany({
        data: wardsToInsert,
        skipDuplicates: true,
      });
      console.log('✅ Nạp dữ liệu Phường/Xã thành công!');
    }
  } else {
    console.log('⚠️ Không tìm thấy file provinces.json, bỏ qua bước này.');
  }

  // 3. ĐỌC VÀ NẠP DỮ LIỆU USER, ACCOUNT, PROFILE, SIGNAL, CHARITYCAMPAIGN
  console.log('⏳ Đang nạp dữ liệu User, Account, Profile...');
  const adminPassword = await bcrypt.hash('admin123', 10);
  const rescuerPassword = await bcrypt.hash('rescuer123', 10);
  const userPassword = await bcrypt.hash('user123', 10);
  const authorityPassword = await bcrypt.hash('authority123', 10);

  // Tạo Admin
  const adminUser = await prisma.user.create({
    data: {
      role: ['NORMAL_USER', 'ADMIN'],
      curLatitude: new Prisma.Decimal(21.028511),
      curLongitude: new Prisma.Decimal(105.854444),
      account: {
        create: {
          username: 'admin',
          password: adminPassword,
          state: 'ACTIVE',
        }
      },
      profiles: {
        create: {
          fullname: 'Nguyễn Văn Admin',
          phoneNumber: '0912345678',
          isCurrent: true,
          gender: 'MALE',
          residenceProvinceCode: 1,
          residenceWardCode: 4, // Phường Ba Đình
        }
      }
    }
  });

  // Tạo Rescuer
  const rescuerUser = await prisma.user.create({
    data: {
      role: ['NORMAL_USER', 'RESCUER'],
      curLatitude: new Prisma.Decimal(21.033333),
      curLongitude: new Prisma.Decimal(105.833333),
      account: {
        create: {
          username: 'rescuer',
          password: rescuerPassword,
          state: 'ACTIVE',
        }
      },
      profiles: {
        create: {
          fullname: 'Trần Văn Cứu Hộ',
          phoneNumber: '0987654321',
          isCurrent: true,
          gender: 'MALE',
          residenceProvinceCode: 1,
          residenceWardCode: 8, // Phường Ngọc Hà
        }
      }
    }
  });

  // Tạo Normal User 1 (Main user)
  const normalUser = await prisma.user.create({
    data: {
      role: ['NORMAL_USER'],
      curLatitude: new Prisma.Decimal(21.025),
      curLongitude: new Prisma.Decimal(105.84),
      account: {
        create: {
          username: 'user',
          password: userPassword,
          state: 'ACTIVE',
        }
      },
      profiles: {
        create: {
          fullname: 'Lê Thị Người Dùng 1',
          phoneNumber: '0901234567',
          isCurrent: true,
          gender: 'FEMALE',
          residenceProvinceCode: 1,
          residenceWardCode: 25, // Phường Giảng Võ
        }
      }
    }
  });

  // Tạo Authority User
  const authorityUser = await prisma.user.create({
    data: {
      role: ['NORMAL_USER', 'AUTHORITY'],
      curLatitude: new Prisma.Decimal(21.015),
      curLongitude: new Prisma.Decimal(105.82),
      account: {
        create: {
          username: 'authority',
          password: authorityPassword,
          state: 'ACTIVE',
        }
      },
      profiles: {
        create: {
          fullname: 'Cơ Quan Chính Quyền',
          phoneNumber: '0999888777',
          isCurrent: true,
          gender: 'OTHER',
          residenceProvinceCode: 1,
          residenceWardCode: 103, // Phường Tây Hồ
        }
      }
    }
  });

  // Tạo thêm 4 Normal Users phụ để tạo các tín hiệu (Tránh unique constraint state=BROADCASTING cho cùng 1 user)
  const createMockUser = async (index: number, fullname: string, phone: string, wardCode: number) => {
    return prisma.user.create({
      data: {
        role: ['NORMAL_USER'],
        curLatitude: new Prisma.Decimal(21.02 + index * 0.01),
        curLongitude: new Prisma.Decimal(105.8 + index * 0.01),
        account: {
          create: {
            username: `user${index}`,
            password: userPassword,
            state: 'ACTIVE',
          }
        },
        profiles: {
          create: {
            fullname,
            phoneNumber: phone,
            isCurrent: true,
            gender: index % 2 === 0 ? 'MALE' : 'FEMALE',
            residenceProvinceCode: 1,
            residenceWardCode: wardCode,
          }
        }
      }
    });
  };

  const user2 = await createMockUser(2, 'Nguyễn Văn Người Dùng 2', '0902234567', 70); // Hoàn Kiếm
  const user3 = await createMockUser(3, 'Trần Thị Người Dùng 3', '0903234567', 91);  // Phú Thượng
  const user4 = await createMockUser(4, 'Phạm Văn Người Dùng 4', '0904234567', 160); // Nghĩa Đô
  const user5 = await createMockUser(5, 'Hoàng Thị Người Dùng 5', '0905234567', 175); // Yên Hòa

  console.log('✅ Nạp dữ liệu User, Account, Profile thành công!');

  // Tạo Signals (Đủ 5 signals)
  console.log('⏳ Đang nạp dữ liệu Signal...');
  // Signal 1: BROADCASTING (tạo bởi user 1)
  await prisma.signal.create({
    data: {
      createdBy: normalUser.userId,
      trappedCount: 3,
      childrenNum: 1,
      elderlyNum: 0,
      hasFood: false,
      hasWater: true,
      state: 'BROADCASTING',
      note: 'Nước ngập đến mái nhà, cần cứu hộ gấp!',
    }
  });

  // Signal 2: HANDLED (tạo bởi user 2, cứu hộ bởi rescuerUser)
  await prisma.signal.create({
    data: {
      createdBy: user2.userId,
      handledBy: rescuerUser.userId,
      trappedCount: 5,
      childrenNum: 2,
      elderlyNum: 1,
      hasFood: false,
      hasWater: false,
      state: 'HANDLED',
      note: 'Gia đình có người già và trẻ nhỏ, đã được cứu hộ tiếp cận.',
      handledAt: new Date(),
    }
  });

  // Signal 3: BROADCASTING (tạo bởi user 3)
  await prisma.signal.create({
    data: {
      createdBy: user3.userId,
      trappedCount: 2,
      childrenNum: 0,
      elderlyNum: 2,
      hasFood: true,
      hasWater: false,
      state: 'BROADCASTING',
      note: 'Hai người già bị cô lập tại tầng 2, mất điện, cần thuốc men và nước uống sạch.',
    }
  });

  // Signal 4: STOPPED (tạo bởi user 4)
  await prisma.signal.create({
    data: {
      createdBy: user4.userId,
      trappedCount: 1,
      childrenNum: 0,
      elderlyNum: 0,
      hasFood: true,
      hasWater: true,
      state: 'STOPPED',
      note: 'Cần hỗ trợ di dời tài sản khẩn cấp trước khi xả lũ.',
      stoppedAt: new Date(),
    }
  });

  // Signal 5: BROADCASTING (tạo bởi user 5)
  await prisma.signal.create({
    data: {
      createdBy: user5.userId,
      trappedCount: 4,
      childrenNum: 3,
      elderlyNum: 0,
      hasFood: false,
      hasWater: false,
      state: 'BROADCASTING',
      note: 'Trẻ em bị sốt cao, nước dâng cao không thể ra ngoài tự mua thuốc.',
    }
  });
  console.log('✅ Nạp dữ liệu 5 Signal thành công!');

  // Tạo CharityCampaign
  console.log('⏳ Đang nạp dữ liệu CharityCampaign...');
  const firstBank = await prisma.bank.findFirst();
  let bankAccountId: string | undefined = undefined;

  if (firstBank) {
    const bankAccount = await prisma.bankAccount.create({
      data: {
        userBankName: 'NGUYEN VAN ADMIN',
        bankId: firstBank.id,
        bankAccountNumber: '190203040506',
      }
    });
    bankAccountId = bankAccount.bankAccountId;
  }

  const now = new Date();
  const daysAgo = (num: number) => new Date(now.getTime() - num * 24 * 60 * 60 * 1000);

  // // Campaign 1: Quyên góp hỗ trợ đồng bào (Trạng thái DONATING)
  // await prisma.charityCampaign.create({
  //   data: {
  //     organizedBy: adminUser.userId,
  //     bankAccountId: bankAccountId,
  //     campaignName: 'Ủng hộ đồng bào lũ lụt miền Bắc',
  //     purpose: 'Quyên góp nhu yếu phẩm và tiền mặt hỗ trợ vùng lũ.',
  //     destinationProvinceCode: 1,
  //     destinationWardCode: 70, // Phường Hoàn Kiếm
  //     destinationDetail: 'UBND Phường Hoàn Kiếm, Hà Nội',
  //     campaignLatitude: new Prisma.Decimal(21.0285),
  //     campaignLongitude: new Prisma.Decimal(105.8542),
  //     charityObject: 'Người dân chịu ảnh hưởng lũ lụt tại miền Bắc',
  //     state: 'DONATING',
  //     requestedAt: daysAgo(4),
  //     respondedAt: daysAgo(3),
  //     startedDonationAt: daysAgo(3),
  //     finishedDonationAt: null,
  //     startedDistributionAt: null,
  //     finishedDistributionAt: null,
  //   }
  // });

  // Campaign 2: Được tạo bởi User bình thường, đang cứu trợ (Trạng thái DISTRIBUTING)
  await prisma.charityCampaign.create({
    data: {
      organizedBy: normalUser.userId,
      checkedBy: adminUser.userId,
      campaignName: 'Hỗ trợ thuốc men cho bà con Quảng Ninh',
      purpose: 'Cung cấp túi thuốc gia đình, thuốc tiêu hóa, hạ sốt cho vùng ngập lụt.',
      destinationProvinceCode: 1,
      destinationWardCode: 91, // Phường Phú Thượng
      destinationDetail: 'Trạm y tế phường Phú Thượng, Tây Hồ, Hà Nội',
      campaignLatitude: new Prisma.Decimal(21.0833),
      campaignLongitude: new Prisma.Decimal(105.8167),
      charityObject: 'Bà con vùng ngập lụt cần chăm sóc y tế',
      state: 'DISTRIBUTING',
      requestedAt: daysAgo(7),
      respondedAt: daysAgo(6),
      startedDonationAt: daysAgo(6),
      finishedDonationAt: daysAgo(2),
      startedDistributionAt: daysAgo(1),
      finishedDistributionAt: null,
    }
  });

  // Campaign 3: Hoàn thành hoàn toàn (Trạng thái FINISHED)
  await prisma.charityCampaign.create({
    data: {
      organizedBy: adminUser.userId,
      checkedBy: adminUser.userId,
      campaignName: 'Hỗ trợ đồng bào khắc phục hậu quả bão số 3',
      purpose: 'Dọn dẹp vệ sinh môi trường, khử trùng nguồn nước và tặng cây giống sau bão.',
      destinationProvinceCode: 1,
      destinationWardCode: 160, // Phường Nghĩa Đô
      destinationDetail: 'Nhà văn hóa Phường Nghĩa Đô, Cầu Giấy, Hà Nội',
      campaignLatitude: new Prisma.Decimal(21.0475),
      campaignLongitude: new Prisma.Decimal(105.8035),
      charityObject: 'Các hộ gia đình nghèo chịu thiệt hại nặng nề',
      state: 'FINISHED',
      requestedAt: daysAgo(15),
      respondedAt: daysAgo(14),
      startedDonationAt: daysAgo(14),
      finishedDonationAt: daysAgo(8),
      startedDistributionAt: daysAgo(7),
      finishedDistributionAt: daysAgo(2),
    }
  });
  console.log('✅ Nạp dữ liệu CharityCampaign thành công!');

  console.log('🎉 HOÀN TẤT TOÀN BỘ QUÁ TRÌNH SEED!');
}

main()
  .catch((e) => {
    console.error('❌ Có lỗi nghiêm trọng xảy ra:', e);
    process.exit(1);
  })
  .finally(async () => {
    await prisma.$disconnect();
  });