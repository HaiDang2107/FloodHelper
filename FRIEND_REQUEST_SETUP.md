# Friend Request Feature - Setup Guide

Tính năng kết bạn đã được implement hoàn chỉnh với push notifications qua Firebase.

## ✅ Đã Hoàn Thành

### Backend (NestJS)
- ✅ Prisma schema: Thêm `fcmToken` vào User model
- ✅ Migration: `20260302072050_add_fcm_token`
- ✅ Firebase Admin SDK: Push notifications
- ✅ Friend Service: CRUD operations cho friend requests
- ✅ Friend Controller: REST API endpoints
- ✅ Integration: FirebaseModule + FriendModule trong AppModule

### Frontend (Flutter)
- ✅ Data layer: Models, Repositories (MVVM)
- ✅ ViewModel: FriendViewModel với Riverpod
- ✅ UI: AddFriendWidget + PendingWidget
- ✅ Firebase Messaging: Foreground + background handlers
- ✅ Real-time updates: Nhận notification khi có lời mời

---

## 🔧 Bạn Cần Làm

### 1. Firebase Setup (BẮT BUỘC)

#### a) Tạo Firebase Project
1. Truy cập [Firebase Console](https://console.firebase.google.com)
2. Tạo project mới hoặc chọn project `floodhelper-374c0`
3. Bật **Cloud Messaging** trong Settings

#### b) Thêm Android App vào Firebase
1. Trong Firebase Console → Project Settings → Add app → Android
2. Android package name: `com.example.antiflood`
3. Tải file `google-services.json`
4. Copy file vào: `frontend/android/app/google-services.json`

**Quan trọng:** File `google-services.json` là BẮT BUỘC để Firebase hoạt động trên Android.

---

## 📁 Cấu Trúc Đã Thêm

### Backend
```
backend/
├── floodhelper-374c0-firebase-adminsdk-fbsvc-5f8beff8a6.json  (✅ Đã có)
├── src/
│   ├── common/enum/
│   │   └── friendRequestState.enum.ts                         (✅ NEW)
│   ├── firebase/
│   │   ├── firebase.service.ts                                (✅ NEW)
│   │   └── firebase.module.ts                                 (✅ NEW)
│   └── friend/
│       ├── dto/
│       │   ├── send-friend-request.dto.ts                     (✅ NEW)
│       │   └── index.ts                                       (✅ NEW)
│       ├── friend.controller.ts                               (✅ NEW)
│       ├── friend.service.ts                                  (✅ NEW)
│       └── friend.module.ts                                   (✅ Updated)
└── prisma/schema/user.prisma                                  (✅ Updated: +fcmToken)
```

### Frontend
```
frontend/
├── lib/
│   ├── data/
│   │   ├── models/
│   │   │   └── friend_request_model.dart                      (✅ NEW)
│   │   ├── repositories/
│   │   │   ├── friend_repository.dart                         (✅ NEW)
│   │   │   └── real/real_friend_repository.dart               (✅ NEW)
│   │   └── services/
│   │       └── firebase_messaging_service.dart                (✅ NEW)
│   └── ui/home/
│       ├── view_models/
│       │   ├── friend_view_model.dart                         (✅ NEW)
│       │   └── friend_view_model.g.dart                       (✅ NEW)
│       ├── views/home_screen.dart                             (✅ Updated: +Firebase)
│       └── widgets/_add_friend_sheet/
│           ├── add_friend_widget.dart                         (✅ Updated: +API)
│           └── pending_widget.dart                            (✅ Updated: +API)
├── android/
│   ├── app/
│   │   ├── build.gradle.kts                                   (✅ Updated: +google-services)
│   │   └── google-services.json                               (❌ CẦN THÊM)
│   └── settings.gradle.kts                                    (✅ Updated)
└── pubspec.yaml                                               (✅ Updated: +firebase deps)
```

---

## 🚀 API Endpoints

### Backend REST API (Tất cả cần JWT token)

| Method | Endpoint | Mô tả |
|--------|----------|-------|
| POST | `/friend/request` | Gửi lời mời kết bạn |
| GET | `/friend/requests/sent` | Lấy danh sách đã gửi |
| GET | `/friend/requests/received` | Lấy danh sách nhận được |
| PATCH | `/friend/request/:id/accept` | Chấp nhận lời mời |
| PATCH | `/friend/request/:id/reject` | Từ chối lời mời |
| DELETE | `/friend/request/:id` | Hủy lời mời đã gửi |
| PATCH | `/friend/fcm-token` | Cập nhật FCM token |

### Request Body Examples

**POST /friend/request**
```json
{
  "receiverId": "uuid-string",
  "note": "Optional note"
}
```

**PATCH /friend/fcm-token**
```json
{
  "fcmToken": "firebase-token-string"
}
```

---

## 🔔 Push Notification Flow

### Khi Gửi Lời Mời
1. User A nhập ID của User B → nhấn "Send"
2. Frontend gọi `POST /friend/request`
3. Backend:
   - Lưu FriendMakingRequest vào DB
   - Gửi push notification đến FCM token của User B
4. User B nhận notification (foreground/background)
5. Nếu User B đang mở app: Danh sách "Received Requests" tự động reload

### Khi Chấp Nhận
1. User B nhấn "Accept"
2. Frontend gọi `PATCH /friend/request/:id/accept`
3. Backend:
   - Update state = ACCEPTED
   - Tạo Friendship
   - Gửi notification đến User A
4. User A nhận thông báo đã được chấp nhận

---

## 🧪 Testing

### 1. Khởi động Backend
```bash
cd backend
npm run start:dev
```

### 2. Khởi động Frontend
```bash
cd frontend
flutter run
```

### 3. Test Flow
1. **Đăng nhập 2 tài khoản** trên 2 thiết bị (hoặc emulator + device)
2. **User A:**
   - Mở màn hình Friends
   - Nhập ID của User B
   - Nhấn "Send"
   - Kiểm tra "Sent Requests" có hiển thị
3. **User B:**
   - Nhận notification
   - Kiểm tra "Received Requests" có hiển thị
   - Nhấn "Accept"
4. **User A:** Nhận notification "accepted"

---

## 📝 Environment Variables

### Backend `.env`
```env
# Existing variables...
DATABASE_URL="..."
REDIS_HOST="..."

# Firebase Admin SDK path (relative to backend/)
# File đã được copy vào: backend/floodhelper-374c0-firebase-adminsdk-fbsvc-5f8beff8a6.json
```

---

## 🐛 Troubleshooting

### Backend

**Error: Firebase Admin not initialized**
- Kiểm tra file `floodhelper-374c0-firebase-adminsdk-fbsvc-5f8beff8a6.json` có trong `backend/`
- Restart backend server

**Error: fcmToken field not found**
- Chạy: `npx prisma generate`
- Restart backend

### Frontend

**Error: Firebase not initialized**
- Kiểm tra file `google-services.json` trong `android/app/`
- Chạy: `flutter clean && flutter pub get`

**Không nhận được notification**
- Kiểm tra FCM token đã được gửi lên backend chưa (xem logs)
- Kiểm tra Firebase console: Cloud Messaging có enabled
- Kiểm tra AndroidManifest.xml có permission INTERNET

**Error: MissingPluginException**
- Restart app (stop + run lại)
- `flutter clean && flutter pub get`

---

## 📚 Tài Liệu Tham Khảo

- [Firebase Admin SDK - Node.js](https://firebase.google.com/docs/admin/setup)
- [Firebase Cloud Messaging - Flutter](https://firebase.google.com/docs/cloud-messaging/flutter/client)
- [Prisma Schema Reference](https://www.prisma.io/docs/reference/api-reference/prisma-schema-reference)

---

## ✨ Tính Năng Chính

✅ Gửi lời mời kết bạn qua User ID  
✅ Nhận danh sách lời mời (sent/received)  
✅ Chấp nhận/Từ chối lời mời  
✅ Hủy lời mời đã gửi  
✅ Push notification real-time  
✅ Auto-reload UI khi nhận notification  
✅ Loading states & error handling  

---

**Chúc bạn code vui vẻ! 🎉**
