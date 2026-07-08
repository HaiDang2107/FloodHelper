-- -- 1. Xóa các chiến dịch cũ của user này để tránh trùng lặp nếu chạy lại script
-- DELETE FROM "CharityCampaign" WHERE organized_by = '62255459-5a8b-4ab5-9122-886979faed72';

-- 2. Thực hiện chèn 9 chiến dịch mới tương ứng với các trạng thái
INSERT INTO "CharityCampaign" (
  campaign_id,
  organized_by,
  bank_account_id,
  checked_by,
  campaign_name,
  purpose,
  charity_object,
  state,
  created_at,
  requested_at,
  responded_at,
  started_donation_at,
  finished_donation_at,
  started_distribution_at,
  finished_distribution_at,
  suspended_at,
  note_for_response,
  note_for_suspension,
  destination_province_code,
  destination_ward_code,
  destination_detail
) VALUES 
-- 1. Trạng thái: CREATED (Vừa mới tạo, chưa gửi kiểm duyệt)
(
  'a1111111-1111-1111-1111-111111111111',
  '62255459-5a8b-4ab5-9122-886979faed72',
  '1ca14446-9ac3-4944-bb28-7c13f5e253e6', -- bank_account_id
  '6b1e2f42-291b-4a05-8bfc-40b3f1b840d4', -- checked_by
  'Chiến dịch Mới Tạo - Hỗ trợ khẩn cấp lũ quét',
  'Ủng hộ đồng bào vùng lũ quét khắc phục hậu quả ban đầu.',
  'Hộ gia đình bị sập nhà hoàn toàn tại vùng lũ quét.',
  'CREATED'::"CampaignState",
  NOW() - INTERVAL '1 hour', -- Tạo cách đây 1 giờ
  NULL,
  NULL,
  NOW() + INTERVAL '1 day',          -- Lên lịch quyên góp bắt đầu sau 1 ngày
  NOW() + INTERVAL '10 days',         -- Dự kiến kết thúc quyên góp sau 10 ngày
  NOW() + INTERVAL '11 days',         -- Dự kiến bắt đầu phân phát sau 11 ngày
  NOW() + INTERVAL '20 days',         -- Dự kiến hoàn thành phân phát sau 20 ngày
  NULL,
  NULL,
  NULL,
  1,   -- Hà Nội
  602, -- Phường Đông Ngạc
  'Khu vực sạt lở ven sông'
),

-- 2. Trạng thái: PENDING (Đang chờ chính quyền phê duyệt)
(
  'b2222222-2222-2222-2222-222222222222',
  '62255459-5a8b-4ab5-9122-886979faed72',
  '1ca14446-9ac3-4944-bb28-7c13f5e253e6', -- bank_account_id
  '6b1e2f42-291b-4a05-8bfc-40b3f1b840d4', -- checked_by
  'Chiến dịch Đang Phê Duyệt - Áo ấm cho em',
  'Mua quần áo ấm và đồ dùng học tập cho học sinh tiểu học vùng cao.',
  'Các em học sinh nghèo vượt khó vùng chịu ảnh hưởng bão lũ.',
  'PENDING'::"CampaignState",
  NOW() - INTERVAL '1 day',
  NOW() - INTERVAL '23 hours', -- Gửi duyệt cách đây 23 giờ
  NULL,
  NOW() + INTERVAL '1 day',          -- Dự kiến bắt đầu quyên góp sau 1 ngày
  NOW() + INTERVAL '10 days',         -- Dự kiến kết thúc quyên góp sau 10 ngày
  NOW() + INTERVAL '11 days',         -- Dự kiến bắt đầu phân phát sau 11 ngày
  NOW() + INTERVAL '20 days',         -- Dự kiến hoàn thành phân phát sau 20 ngày
  NULL,
  NULL,
  NULL,
  1,   -- Hà Nội
  602, -- Phường Đông Ngạc
  'Điểm trường Bản cao'
),

-- 3. Trạng thái: APPROVED (Đã duyệt nhưng chưa đến thời gian nhận quyên góp)
(
  'c3333333-3333-3333-3333-333333333333',
  '62255459-5a8b-4ab5-9122-886979faed72',
  '1ca14446-9ac3-4944-bb28-7c13f5e253e6', -- bank_account_id
  '6b1e2f42-291b-4a05-8bfc-40b3f1b840d4', -- checked_by
  'Chiến dịch Đã Phê Duyệt - Khắc phục sau bão số 2',
  'Mua con giống và cây giống giúp bà con tái sản xuất nông nghiệp.',
  'Nông dân bị thiệt hại trắng hoa màu và gia súc.',
  'APPROVED'::"CampaignState",
  NOW() - INTERVAL '2 days',
  NOW() - INTERVAL '1 day 23 hours',
  NOW() - INTERVAL '1 day 20 hours', -- Được duyệt cách đây 1 ngày 20 giờ
  NOW() + INTERVAL '12 hours',        -- Bắt đầu quyên góp sau 12 giờ
  NOW() + INTERVAL '10 days',         -- Kết thúc quyên góp sau 10 ngày
  NOW() + INTERVAL '11 days',         -- Bắt đầu phân phát sau 11 ngày
  NOW() + INTERVAL '20 days',         -- Hoàn thành phân phát sau 20 ngày
  NULL,
  NULL,
  NULL,
  1,   -- Hà Nội
  602, -- Phường Đông Ngạc
  'Hợp tác xã nông nghiệp xã'
),

-- 4. Trạng thái: REJECTED (Bị từ chối phê duyệt)
(
  'd4444444-4444-4444-4444-444444444444',
  '62255459-5a8b-4ab5-9122-886979faed72',
  '1ca14446-9ac3-4944-bb28-7c13f5e253e6', -- bank_account_id
  '6b1e2f42-291b-4a05-8bfc-40b3f1b840d4', -- checked_by
  'Chiến dịch Bị Từ Chối - Hỗ trợ xây cầu dân sinh',
  'Quyên góp xây dựng cầu tạm qua suối bị lũ cuốn trôi.',
  'Người dân di chuyển khó khăn qua suối.',
  'REJECTED'::"CampaignState",
  NOW() - INTERVAL '3 days',
  NOW() - INTERVAL '2 days 23 hours',
  NOW() - INTERVAL '2 days 20 hours', -- Bị từ chối cách đây 2 ngày 20 giờ
  NOW() - INTERVAL '1 day',           -- Kế hoạch bắt đầu quyên góp ban đầu
  NOW() + INTERVAL '9 days',          -- Kế hoạch kết thúc quyên góp ban đầu
  NOW() + INTERVAL '10 days',         -- Kế hoạch phân phát ban đầu
  NOW() + INTERVAL '15 days',         -- Kế hoạch hoàn thành ban đầu
  NULL,
  'Hồ sơ pháp lý của tổ chức bảo trợ chưa rõ ràng. Cần bổ sung giấy phép xây dựng cầu tạm.',
  NULL,
  1,   -- Hà Nội
  602, -- Phường Đông Ngạc
  'Thôn Bản Ngòi'
),

-- 5. Trạng thái: DONATING (Đang mở cổng nhận quyên góp)
(
  'e5555555-5555-5555-5555-555555555555',
  '62255459-5a8b-4ab5-9122-886979faed72',
  '1ca14446-9ac3-4944-bb28-7c13f5e253e6', -- bank_account_id
  '6b1e2f42-291b-4a05-8bfc-40b3f1b840d4', -- checked_by
  'Chiến dịch Đang Quyên Góp - Chung tay vì vùng lũ',
  'Quyên góp quỹ mua lương thực, mì tôm và nước sạch hỗ trợ khẩn cấp.',
  'Người dân bị cô lập trong vùng ngập lụt sâu.',
  'DONATING'::"CampaignState",
  NOW() - INTERVAL '5 days',
  NOW() - INTERVAL '4 days 23 hours',
  NOW() - INTERVAL '4 days 20 hours',
  NOW() - INTERVAL '4 days 18 hours', -- Bắt đầu nhận quyên góp cách đây 4 ngày 18 giờ
  NOW() + INTERVAL '6 days',          -- Kết thúc quyên góp sau 6 ngày
  NOW() + INTERVAL '7 days',          -- Dự kiến bắt đầu phân phát sau 7 ngày
  NOW() + INTERVAL '12 days',         -- Dự kiến hoàn thành phân phát sau 12 ngày
  NULL,
  NULL,
  NULL,
  1,   -- Hà Nội
  602, -- Phường Đông Ngạc
  'Nhà văn hóa trung tâm xã'
),

-- 6. Trạng thái: DISTRIBUTING (Đã đóng cổng quyên góp, đang phân phát quà cứu trợ)
(
  'f6666666-6666-6666-6666-666666666666',
  '62255459-5a8b-4ab5-9122-886979faed72',
  '1ca14446-9ac3-4944-bb28-7c13f5e253e6', -- bank_account_id
  '6b1e2f42-291b-4a05-8bfc-40b3f1b840d4', -- checked_by
  'Chiến dịch Đang Phân Phát - Sách vở tới trường',
  'Trao tặng balo và bộ sách giáo khoa mới cho học sinh vùng bão.',
  'Các em học sinh bị bão lũ làm ướt, mất hết sách vở đồ dùng.',
  'DISTRIBUTING'::"CampaignState",
  NOW() - INTERVAL '10 days',
  NOW() - INTERVAL '9 days 23 hours',
  NOW() - INTERVAL '9 days 20 hours',
  NOW() - INTERVAL '9 days 18 hours', -- Bắt đầu quyên góp cách đây 9 ngày
  NOW() - INTERVAL '3 days',        -- Đóng quyên góp cách đây 3 ngày
  NOW() - INTERVAL '2 days',        -- Bắt đầu đi trao quà cách đây 2 ngày
  NOW() + INTERVAL '5 days',         -- Dự kiến hoàn thành phân phát sau 5 ngày
  NULL,
  NULL,
  NULL,
  1,   -- Hà Nội
  602, -- Phường Đông Ngạc
  'Trường THCS xã'
),

-- 7. Trạng thái: SUSPENDED (Đang bị tạm dừng/đóng băng do có vấn đề phát sinh)
(
  '77777777-7777-7777-7777-777777777777',
  '62255459-5a8b-4ab5-9122-886979faed72',
  '1ca14446-9ac3-4944-bb28-7c13f5e253e6', -- bank_account_id
  '6b1e2f42-291b-4a05-8bfc-40b3f1b840d4', -- checked_by
  'Chiến dịch Bị Tạm Dừng - Hỗ trợ y tế vùng ngập',
  'Quyên góp mua túi thuốc gia dịch chống dịch bệnh sau lũ.',
  'Người dân vùng ngập úng dài ngày có nguy cơ dịch bệnh.',
  'SUSPENDED'::"CampaignState",
  NOW() - INTERVAL '10 days',
  NOW() - INTERVAL '9 days 23 hours',
  NOW() - INTERVAL '9 days 20 hours',
  NOW() - INTERVAL '9 days 18 hours', -- Bắt đầu quyên góp
  NOW() - INTERVAL '1 day',          -- Đóng quyên góp
  NOW(),                             -- Bắt đầu phân phát
  NOW() + INTERVAL '5 days',         -- Dự kiến hoàn thành phân phát
  NOW() - INTERVAL '12 hours',       -- Bị tạm đình chỉ cách đây 12 giờ
  NULL,
  'Phát hiện sự bất nhất trong báo cáo danh sách nhà thuốc phân phối vật tư y tế. Tạm dừng để thẩm định.',
  1,   -- Hà Nội
  602, -- Phường Đông Ngạc
  'Trạm y tế xã'
),

-- 8. Trạng thái: FINISHED (Chiến dịch hoàn thành trọn vẹn)
(
  '88888888-8888-8888-8888-888888888888',
  '62255459-5a8b-4ab5-9122-886979faed72',
  '1ca14446-9ac3-4944-bb28-7c13f5e253e6', -- bank_account_id
  '6b1e2f42-291b-4a05-8bfc-40b3f1b840d4', -- checked_by
  'Chiến dịch Hoàn Thành - Nước sạch cho vùng lũ',
  'Lắp đặt máy lọc nước RO công nghiệp tại các điểm công cộng.',
  'Hơn 500 hộ dân thiếu nước sinh hoạt sạch.',
  'FINISHED'::"CampaignState",
  NOW() - INTERVAL '20 days',
  NOW() - INTERVAL '19 days 23 hours',
  NOW() - INTERVAL '19 days 20 hours',
  NOW() - INTERVAL '19 days 18 hours', -- Bắt đầu quyên góp cách đây 19 ngày
  NOW() - INTERVAL '10 days',        -- Đóng quyên góp cách đây 10 ngày
  NOW() - INTERVAL '9 days',         -- Đi thi công lắp đặt cách đây 9 ngày
  NOW() - INTERVAL '1 day',          -- Nghiệm thu bàn giao máy hoàn thành cách đây 1 ngày
  NULL,
  NULL,
  NULL,
  1,   -- Hà Nội
  602, -- Phường Đông Ngạc
  '5 điểm trường học và nhà văn hóa'
),

-- 9. Trạng thái: DONATING (Quyên góp đã đóng, chờ bắt đầu phân phát)
(
  'e9999999-9999-9999-9999-999999999999',
  '62255459-5a8b-4ab5-9122-886979faed72',
  '1ca14446-9ac3-4944-bb28-7c13f5e253e6', -- bank_account_id
  '6b1e2f42-291b-4a05-8bfc-40b3f1b840d4', -- checked_by
  'Chiến dịch Quyên Góp Đã Đóng - Chờ Phân Phát',
  'Quyên góp quỹ mua lương thực, mì tôm hỗ trợ khẩn cấp.',
  'Người dân chịu thiệt hại do lũ quét.',
  'DONATING'::"CampaignState",
  NOW() - INTERVAL '5 days',
  NOW() - INTERVAL '4 days 23 hours',
  NOW() - INTERVAL '4 days 20 hours',
  NOW() - INTERVAL '4 days 18 hours', -- Bắt đầu nhận quyên góp cách đây 4 ngày 18 giờ
  NOW() - INTERVAL '1 day',           -- Kết thúc quyên góp cách đây 1 ngày (quá khứ)
  NOW() + INTERVAL '1 day',           -- Bắt đầu phân phát sau 1 ngày (tương lai)
  NOW() + INTERVAL '10 days',          -- Hoàn thành phân phát sau 10 ngày (tương lai)
  NULL,
  NULL,
  NULL,
  1,   -- Hà Nội
  602, -- Phường Đông Ngạc
  'Nhà văn hóa xã Đông Ngạc'
);
