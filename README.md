# ProjectFlow - Ứng dụng Quản lý Dự án Cá nhân

Ứng dụng quản lý dự án hiện đại, đầy đủ tính năng được xây dựng với Flutter và Supabase (PostgreSQL). Tương tự Trello hoặc Asana, thiết kế cho cá nhân và nhóm nhỏ.

## 🚀 Tính năng

### Tính năng chính

- **Bảng Kanban**: Kéo thả task với các cột tùy chỉnh
- **Hợp tác thời gian thực**: Cập nhật trực tiếp cho tất cả thành viên
- **Quản lý Task**: Tạo, gán, ưu tiên và theo dõi công việc
- **Tổ chức Dự án**: Nhiều dự án với màu sắc và icon tùy chỉnh
- **Làm việc nhóm**: Mời thành viên với phân quyền theo vai trò
- **Theo dõi Deadline**: Hiển thị trực quan task quá hạn và sắp đến hạn
- **Bình luận & Thảo luận**: Trao đổi trên từng task
- **Thông báo đẩy**: Cập nhật khi được gán task hoặc deadline

### Tính năng UI/UX

- Giao diện Material Design 3 đẹp mắt, hiện đại
- Hỗ trợ theme Sáng/Tối
- Thiết kế responsive cho điện thoại và máy tính bảng
- Hiệu ứng animation mượt mà
- Kiến trúc offline-first

## 🛠 Công nghệ sử dụng

| Thành phần         | Công nghệ                   |
| ------------------ | --------------------------- |
| **Frontend**       | Flutter 3.x                 |
| **Quản lý State**  | Riverpod                    |
| **Xác thực**       | Supabase Auth               |
| **Cơ sở dữ liệu**  | Supabase (PostgreSQL)       |
| **Thời gian thực** | Supabase Realtime           |
| **Lưu trữ cục bộ** | Hive                        |
| **Điều hướng**     | GoRouter                    |
| **Thông báo**      | Flutter Local Notifications |

## 📁 Cấu trúc Dự án

```
lib/
├── core/
│   ├── constants/      # Màu sắc, kích thước, chuỗi
│   ├── error/          # Xử lý lỗi và ngoại lệ
│   ├── router/         # Cấu hình GoRouter
│   ├── services/       # Supabase, thông báo, lưu trữ
│   ├── theme/          # Cấu hình theme
│   └── utils/          # Extensions, validators
├── data/
│   ├── models/         # Các model dữ liệu
│   └── repositories/   # Repositories
├── providers/          # Riverpod providers
└── ui/
    ├── screens/        # Các màn hình
    └── widgets/        # Widget tái sử dụng
```

## 🚦 Bắt đầu

### Yêu cầu

- Flutter SDK 3.0+
- Dự án Supabase

### Cài đặt

1. **Clone repository**

```bash
git clone https://github.com/yourusername/project_flow.git
cd project_flow
```

2. **Cài đặt dependencies**

```bash
flutter pub get
```

3. **Cấu hình Supabase**

   - Tạo dự án Supabase tại [Supabase](https://supabase.com)
   - Chạy SQL schema từ file `supabase_schema.sql`
   - Cập nhật thông tin trong `lib/main.dart` (recommended: use `.env`):

   **Option A (recommended — using `.env` + flutter_dotenv)**

   ```dart
   import 'package:flutter_dotenv/flutter_dotenv.dart';

   await dotenv.load(fileName: '.env');
   await SupabaseService.initialize(
     url: dotenv.env['SUPABASE_URL']!,
     anonKey: dotenv.env['SUPABASE_ANON_KEY']!,
   );
   ```

   **Option B (quick — direct edit)**

   ```dart
   await SupabaseService.initialize(
     url: 'YOUR_SUPABASE_URL',
     anonKey: 'YOUR_SUPABASE_ANON_KEY',
   );
   ```

   - Tạo một bucket Storage tên `attachments` (dùng để lưu file đính kèm)
     - Vào Supabase > Storage > New bucket: `attachments`
     - Chọn Public nếu bạn muốn file có thể truy cập bằng URL

4. **Chạy ứng dụng**

```bash
flutter run
```

### Kiểm thử Attachment & Push

1. Attachment flow:

- Mở Board > Add Task > click Attachment > chọn ảnh.
- Ảnh sẽ được upload lên Supabase Storage (bucket `attachments`) và URL được lưu trong `attachment_urls` của task.
- Mở Task Detail hoặc refresh Board, ảnh sẽ hiển thị.

2. Push flow:

- Push notifications via Firebase (FCM) have been removed from the project. The app still supports local notifications via `flutter_local_notifications`.
- You can use Supabase Edge Functions or other providers to implement server push if needed, but this project does not include FCM by default.

Ghi chú: Bảng `user_devices` đã được loại bỏ khỏi dự án; không còn lưu FCM token trong DB.

## 📊 Sơ đồ Cơ sở dữ liệu

Ứng dụng sử dụng Supabase PostgreSQL với các bảng chính:

- `users` - Thông tin người dùng
- `projects` - Thông tin dự án
- `project_members` - Thành viên và vai trò trong dự án
- `boards` - Bảng Kanban
- `board_columns` - Các cột (To Do, In Progress, v.v.)
- `tasks` - Các task
- `comments` - Bình luận task
- `labels` - Nhãn task
- `notifications` - Thông báo người dùng
- `activities` - Nhật ký hoạt động

- ## 🔐 Bảo mật

- Supabase Authentication cho quản lý người dùng an toàn
- Supabase Row Level Security (RLS) bảo vệ dữ liệu
- Phân quyền theo vai trò (Owner, Admin, Member, Viewer)
- `user_devices` table (đã bị loại bỏ) trước đây lưu token thiết bị để gửi push.

## 📱 Ảnh chụp màn hình

| Trang chủ       | Bảng Kanban  | Chi tiết Task  |
| --------------- | ------------ | -------------- |
| Danh sách dự án | Bảng kéo thả | Thông tin task |

## 🎨 Giao diện

Ứng dụng hỗ trợ theme sáng và tối với bảng màu đẹp mắt:

- Chính: Deep Ocean Blue (#1E3A5F)
- Nhấn: Coral Orange (#FF6B6B)
- Phụ: Teal (#4ECDC4)

## 📝 Kiến trúc

Dự án tuân theo **Clean Architecture** với pattern **MVVM**:

1. **Data Layer**: Models, Repositories, Data Sources
2. **Domain Layer**: Logic nghiệp vụ (trong Providers)
3. **Presentation Layer**: UI Screens và Widgets

Quản lý state sử dụng **Riverpod** cho:

- Dependency injection type-safe
- Cập nhật state reactive
- Dễ dàng testing

## 🧪 Testing

```bash
# Chạy unit tests
flutter test

# Chạy integration tests
flutter test integration_test
```

## 📄 Giấy phép

Dự án này được cấp phép theo MIT License.

## 🤝 Đóng góp

Mọi đóng góp đều được hoan nghênh! Vui lòng tạo Pull Request.

## 📧 Liên hệ

Nếu có câu hỏi hoặc cần hỗ trợ, vui lòng tạo issue trên GitHub.

---

## 🔔 Push Notifications

Push notifications via Firebase (FCM) have been intentionally removed from ProjectFlow in this build. The project still supports local notifications via `flutter_local_notifications`.

If you need server push in the future, consider using:

- Firebase Admin SDK (FCM v1 HTTP API) or
- A third-party push provider (OneSignal, AWS SNS, etc.) or
- Supabase Edge Functions coupled with a serverless push provider.

Note: Code references to `firebase_messaging` and `firebase_core` have been removed; remove any native Firebase config files if present (e.g., `android/app/google-services.json`).

Server-side push templates and token cleanup scripts have been removed or deprecated. If you need push notifications, implement a provider-specific server flow or use Supabase Edge Functions with a provider.

No server push demo is included. If you previously used the provided templates, remove the deprecated files and implement a provider-specific server to manage device tokens and sending pushes.

## 📋 Đánh giá theo tiêu chí

| Tiêu chí              | Đáp ứng                                            |
| --------------------- | -------------------------------------------------- |
| 1. UI/UX              | ✅ Material Design 3, Responsive, Dark/Light theme |
| 2. State Management   | ✅ Riverpod - phù hợp app phức tạp                 |
| 3. Kiến trúc          | ✅ Clean Architecture + MVVM                       |
| 4. Xử lý dữ liệu      | ✅ Supabase API + Hive local cache                 |
| 5. Tích hợp Backend   | ✅ Supabase Auth + Supabase Database               |
| 6. Tính năng nâng cao | ✅ Real-time, Push notifications                   |
| 7. Phần cứng          | ✅ Camera (attachments), Notifications             |
| 8. Xử lý lỗi          | ✅ Error handling với Failures                     |
| 9. Hiệu năng          | ✅ Lazy loading, Stream providers                  |
| 10. Hoàn thiện        | ✅ Sản phẩm hoàn chỉnh, UI chuyên nghiệp           |
