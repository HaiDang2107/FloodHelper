# Thiết Kế Giao Diện Người Dùng (User Interface Design) - Dự Án FloodHelper

## 1. Đặc Tả Thiết Bị Hướng Tới

Dự án FloodHelper được thiết kế để phục vụ hai nhóm đối tượng chính với hai nền tảng riêng biệt: Mobile App dành cho người dân và Web App dành cho Chính quyền (Authority) và Quản trị viên (Admin).

### 1.1. Nền Tảng Mobile (Dành Cho Người Dùng Thông Thường)
Thiết bị di động là phương tiện chính để người dân báo cáo sự cố, nhận cảnh báo và tìm kiếm cứu trợ trong các tình huống khẩn cấp. Do đó, ứng dụng cần hỗ trợ dải thiết bị rộng từ các dòng máy cũ đến smartphone hiện đại.

*   **Kích Thước Màn Hình Hướng Tới:** 
    *   Hỗ trợ kích thước từ 4.7 inches đến 6.9 inches.
    *   Tỉ lệ màn hình phổ biến: 16:9, 18:9, 19.5:9 và 20:9.
*   **Độ Phân Giải Màn Hình:**
    *   Tối thiểu: 720 x 1280 pixels (HD).
    *   Tiêu chuẩn & Tối ưu: 1080 x 1920 pixels (FHD) đến 1440 x 3200 pixels (QHD+).
*   **Màu Sắc Hỗ Trợ:** 
    *   Hỗ trợ dải màu sRGB tiêu chuẩn và DCI-P3 (cho các thiết bị cao cấp) với 16 triệu màu (24-bit color depth), đảm bảo các icon cảnh báo và bản đồ phân hóa màu sắc hiển thị rõ nét ngay cả trong điều kiện ngoài trời ánh sáng mạnh.
*   **Cảm Ứng & Thao Tác:** 
    *   Hỗ trợ cảm ứng đa điểm (Multi-touch).
    *   Tối ưu hóa các vùng thao tác (Tap target size) tối thiểu đạt 44x44 pt theo tiêu chuẩn accessibility của Apple và Google để đảm bảo người dùng có thể thao tác dễ dàng trong lúc hoảng loạn hoặc khi màn hình bị ướt.

### 1.2. Nền Tảng Web (Dành Cho Authority & Admin)
Hệ thống Web Dashboard được sử dụng bởi các cơ quan chức năng để giám sát bản đồ lũ lụt tổng thể, duyệt báo cáo và điều phối lực lượng. Nền tảng này đòi hỏi không gian hiển thị rộng lớn cho dữ liệu lưới, biểu đồ và bản đồ GIS.

*   **Kích Thước Màn Hình Hướng Tới:** 
    *   Màn hình Laptop/Desktop từ 13 inches đến 27 inches trở lên.
*   **Độ Phân Giải Màn Hình:**
    *   Tối thiểu: 1024 x 768 pixels (Có hỗ trợ cuộn trang ngang/dọc cho thiết bị cũ).
    *   Khuyến nghị & Tối ưu: 1366 x 768 pixels (Laptop phổ thông), 1920 x 1080 pixels (Full HD) trở lên.
*   **Màu Sắc Hỗ Trợ:** 
    *   Hỗ trợ True Color (24-bit) hoặc 32-bit. Cần đảm bảo độ tương phản màu sắc cao, hỗ trợ tốt cho việc phân biệt các lớp địa hình (layers) và vùng ngập lụt trên bản đồ vệ tinh.
*   **Thiết Bị Nhập Liệu:** 
    *   Tối ưu hóa cho thao tác bằng Chuột (Mouse) và Bàn phím (Keyboard). 
    *   Hỗ trợ các phím tắt (shortcuts) giúp nhân viên điều phối thao tác nhanh chóng.

---

## 2. Chuẩn Hóa & Thống Nhất Thiết Kế Giao Diện (UI Conventions)

Để đảm bảo tính nhất quán (consistency), dễ học, dễ sử dụng và thể hiện tính chuyên nghiệp của hệ thống FloodHelper, các quy tắc chuẩn hóa sau đây được áp dụng xuyên suốt giữa cả Mobile và Web.

### 2.1. Phối Màu (Color Palette)
Hệ thống sử dụng ngôn ngữ màu sắc mang tính cứu trợ, an toàn và rõ ràng, tuyệt đối tránh các màu sắc gây nhầm lẫn.
*   **Màu Chủ Đạo (Primary Color):** Xanh dương đậm (#1A56DB) - Thể hiện sự tin cậy, liên quan đến nước và các tổ chức hành chính/cứu trợ.
*   **Màu Nền (Background):** 
    *   *Nền tảng Web/Sáng (Light Mode):* Trắng (#FFFFFF) cho các nội dung chính, và Xám nhạt (#F3F4F6) cho màu nền tổng thể giúp nổi bật các khung nội dung (Cards).
    *   *Nền tảng Mobile (Dark Mode/Tiết kiệm pin):* Khuyến khích hỗ trợ nền Đen (#121212) hoặc Xám đậm (#1F2937) giúp tiết kiệm pin thiết bị trong hoàn cảnh cúp điện diện rộng do mưa bão.
*   **Màu Trạng Thái (Semantic Colors):** Rất quan trọng trong hệ thống báo cáo khẩn cấp:
    *   **Nguy hiểm/Cảnh báo cấp bách (Danger):** Đỏ (#E02424) - Dùng cho nút SOS, mức nước lũ nguy hiểm, báo động khẩn cấp.
    *   **Cảnh báo mức trung (Warning):** Cam/Vàng (#D97706) - Dùng cho khu vực có nguy cơ ngập, báo cáo đang chờ xác duyệt.
    *   **Thành công/An toàn (Success):** Xanh lá (#057A55) - Dùng cho khu vực tập kết an toàn, báo cáo cứu trợ đã được giải quyết.
    *   **Thông báo (Info):** Xanh lam nhạt (#3F83F8) - Dùng cho các thông báo hướng dẫn thông thường.
*   **Màu Chữ (Text):** Đen than (#111827) cho tiêu đề và nội dung chính, Xám trung tính (#6B7280) cho văn bản phụ, ghi chú.

### 2.2. Kiểu Chữ (Typography)
*   **Font Chữ:** Lựa chọn `Inter` hoặc `Roboto` - Đây là các bộ font Sans-serif hiện đại, hỗ trợ tiếng Việt rất tốt, đảm bảo tính dễ đọc (legibility) tuyệt đối trên cả màn hình nhỏ lẫn lớn.
*   **Thứ Bậc Kích Thước (Type Scale):**
    *   **Tiêu đề trang (H1):** 24px - 32px (Đậm - Bold).
    *   **Tiêu đề phân mục (H2, H3):** 18px - 22px (Bán đậm - Semi-bold).
    *   **Nội dung văn bản (Body Text):** 14px - 16px (Regular). Mức này đủ lớn để dễ đọc khi di chuyển.
    *   **Chú thích (Caption/Hint):** 12px (Regular/Italic).

### 2.3. Thiết Kế Nút Bấm (Button Design)
Các nút tương tác cần có thứ bậc thị giác rõ ràng để hướng người dùng (đặc biệt là người dân đang hoảng loạn) vào đúng hành động cần thiết.
*   **Nút Hành Động Chính (Primary Button):** 
    *   Có màu nền đặc (Xanh dương chủ đạo hoặc Đỏ cho hành động SOS khẩn cấp), chữ màu Trắng. 
    *   Bo góc tròn (Border-radius): `8px` cho Web để tạo cảm giác gọn gàng, chuyên nghiệp; và `12px` - `16px` (hoặc Pill-shape) cho Mobile để tạo sự thân thiện, dễ chạm.
*   **Nút Phụ (Secondary / Outlined Button):** 
    *   Sử dụng nền trong suốt, viền Xanh dương hoặc Xám, chữ trùng màu viền. Dành cho các hành động như "Hủy bỏ", "Xem chi tiết", "Bộ lọc".
*   **Nút Văn Bản (Text/Ghost Button):** 
    *   Không nền, không viền, chỉ đổi màu hoặc thêm gạch chân khi tương tác (Dùng cho "Quên mật khẩu", "Xem thêm").
*   **Trạng Thái Nút (State):** 
    *   *Hover (chỉ trên Web):* Giảm độ sáng màu nền (darken) đi 10% hoặc hiển thị bóng đổ (Drop shadow) sâu hơn.
    *   *Pressed/Active:* Hiệu ứng thu nhỏ nhẹ (scale 0.98) tạo phản hồi xúc giác giả lập.
    *   *Disabled (Vô hiệu hóa):* Màu nền xám nhạt (#D1D5DB), chữ xám, con trỏ dạng `not-allowed`.

### 2.4. Thiết Kế Điều Khiển (Controls & Inputs)
*   **Trường Nhập Liệu (Input Fields):** 
    *   Sử dụng viền mỏng (#D1D5DB). Khi được chọn (Focus), viền chuyển sang màu Xanh dương (#1A56DB) với độ dày 2px hoặc thêm hiệu ứng viền sáng (Glow/Ring).
    *   Chiều cao (Height) của input box ít nhất là 44px (trên Mobile) và 40px (trên Web).
*   **Checkbox & Radio Button:** 
    *   Sử dụng hình vuông có bo góc nhẹ (4px) cho Checkbox (chọn nhiều) và hình tròn hoàn toàn cho Radio (chọn một). Màu active là màu Primary.
*   **Toggle Switch (Công tắc):** 
    *   Dùng để thiết lập cấu hình nhanh (Ví dụ: "Bật nhận thông báo khẩn cấp", "Bật chế độ hiển thị trạm cứu trợ").

### 2.5. Vị Trí Hiển Thị Thông Điệp Phản Hồi (Feedback Messages)
Trong hệ thống liên quan đến tính mạng và tài sản, thông tin phản hồi phải luôn xuất hiện ngay lập tức, minh bạch và tại vị trí dễ chú ý nhất:
*   **Thông báo đẩy nhanh (Toast/Snackbar):** 
    *   *Vị trí Mobile:* Xuất hiện ở cạnh dưới (Bottom) của màn hình, đè lên trên nội dung, cách đáy 16px. Tự động biến mất sau 3-5 giây. (Ví dụ: "Đã cập nhật vị trí của bạn").
    *   *Vị trí Web:* Xuất hiện ở góc trên cùng bên phải (Top-Right) màn hình.
*   **Hộp thoại xác nhận (Modal / Dialog):**
    *   Sử dụng cho các thao tác mang tính quyết định, không thể hoàn tác (Ví dụ: "Gửi cảnh báo sơ tán khẩn cấp toàn khu vực", "Đóng báo cáo sự cố").
    *   Luôn hiển thị ở chính giữa màn hình (Center) trên cả Web và Mobile. Nền phía sau phải được làm mờ (Dim overlay 50% opacity) để ép buộc người dùng phải tương tác với Modal trước.
*   **Phản hồi cục bộ (Inline Validation):** 
    *   Các lỗi điền biểu mẫu (như để trống số điện thoại, chọn sai định dạng) phải hiển thị chữ màu đỏ ngay phía dưới trường dữ liệu tương ứng ngay trong lúc người dùng đang gõ (Real-time validation).

### 2.6. Bố Cục (Layout) & Lưới (Grid System)
*   **Nền tảng Web (Admin Dashboard):** 
    *   Sử dụng hệ thống lưới 12 cột (12-column grid fluid).
    *   Bố cục tiêu chuẩn bao gồm: Thanh điều hướng bên trái (Left Sidebar) chiếm khoảng 250px và phần nội dung chính (Main Content / Map View) chiếm toàn bộ diện tích còn lại.
*   **Nền tảng Mobile:** 
    *   Sử dụng lưới 4 cột, viền lề (Margin) trái và phải thống nhất là 16px.
    *   Điều hướng chính thông qua thanh công cụ dưới cùng (Bottom Navigation Bar) (với các tab: Trang chủ/Bản đồ, Báo cáo sự cố, Thông báo, Cài đặt cá nhân) để ngón tay cái có thể với tới dễ dàng.

### 2.7. Biểu Tượng (Iconography)
*   Sử dụng một bộ icon thống nhất (ví dụ: Material Icons, FontAwesome hoặc Heroicons). Ưu tiên các icon có nét vẽ đơn giản, rõ ràng, dạng outline (chưa chọn) và dạng filled (đã chọn).
*   **Quy tắc đi kèm:** Các chức năng quan trọng (như Nút SOS, Gửi vị trí) không chỉ dùng icon đơn độc mà phải LUÔN có nhãn văn bản (Text label) đi kèm để tránh người dùng hiểu lầm ý nghĩa trong lúc hoảng loạn.

---
*Tổng kết lại, triết lý thiết kế UI của FloodHelper xoay quanh các yếu tố: Rõ Ràng (Clarity) – Tốc Độ (Speed) – và An Toàn (Safety). Mọi thành phần từ màu sắc đến nút bấm đều phục vụ mục đích duy nhất là giúp thông tin cứu trợ được truyền tải đi nhanh và chính xác nhất.*
