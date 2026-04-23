const fs = require('fs').promises;

async function fetchAndSave(url, filename, description) {
    console.log(`⏳ Đang lấy dữ liệu ${description} từ: ${url}...`);
    
    try {
        const response = await fetch(url);
        
        // Kiểm tra xem request có thành công không (status 200-299)
        if (!response.ok) {
            throw new Error(`HTTP error! status: ${response.status}`);
        }
        
        const data = await response.json();
        
        // Lưu data vào file với định dạng JSON đẹp (indent = 4 space)
        await fs.writeFile(filename, JSON.stringify(data, null, 4), 'utf-8');
        
        console.log(`✅ Đã lưu thành công vào file: ${filename}`);
    } catch (error) {
        console.error(`❌ Lỗi khi gọi API ${description}:`, error.message);
    }
}

async function main() {
    // 1. Lấy dữ liệu Ngân hàng
    const BANK_API_URL = "https://api.vietqr.io/v2/banks";
    await fetchAndSave(BANK_API_URL, "banks.json", "Ngân hàng");

    console.log("-".repeat(40));

    // 2. Lấy dữ liệu Tỉnh thành (Độ sâu 1)
    const PROVINCE_API_URL = "https://provinces.open-api.vn/api/v2/?depth=2";
    await fetchAndSave(PROVINCE_API_URL, "provinces.json", "Tỉnh thành");
}

// Thực thi script
main();