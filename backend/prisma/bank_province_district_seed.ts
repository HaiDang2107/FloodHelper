import { PrismaClient } from '@prisma/client';
import * as fs from 'fs';
import * as path from 'path';

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