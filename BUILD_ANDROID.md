# Hướng dẫn Build và Test Android APK

## Cách 1: Chạy trực tiếp trên thiết bị/emulator (Nhanh nhất)

### Bước 1: Kết nối thiết bị
```bash
# Kiểm tra thiết bị đã kết nối
flutter devices

# Nếu chưa có thiết bị, mở Android Emulator từ Android Studio
# Hoặc kết nối điện thoại qua USB và bật USB Debugging
```

### Bước 2: Chạy app
```bash
# Chạy trên thiết bị đã kết nối
flutter run

# Hoặc chỉ định thiết bị cụ thể
flutter run -d <device-id>
```

## Cách 2: Build APK để cài đặt thủ công

### Build APK Debug (để test)
```bash
flutter build apk --debug
```

APK sẽ được tạo tại: `build/app/outputs/flutter-apk/app-debug.apk`

### Build APK Release (để phân phối)
```bash
flutter build apk --release
```

APK sẽ được tạo tại: `build/app/outputs/flutter-apk/app-release.apk`

### Cài đặt APK
1. Copy file APK vào điện thoại
2. Mở file APK trên điện thoại
3. Cho phép "Install from Unknown Sources" nếu được hỏi
4. Cài đặt và chạy

## Cách 3: Build App Bundle (AAB) cho Google Play Store
```bash
flutter build appbundle --release
```

File sẽ được tạo tại: `build/app/outputs/bundle/release/app-release.aab`

## Lưu ý quan trọng

### 1. Cấu hình Supabase cho Magic Link
- Vào Supabase Dashboard → Authentication → URL Configuration
- Thêm Redirect URL: `com.projectflow.project_flow://login-callback`
- Lưu settings

### 2. File .env
- Đảm bảo file `.env` có đầy đủ:
  ```
  SUPABASE_URL=https://your-project.supabase.co
  SUPABASE_ANON_KEY=your-anon-key
  ```

### 3. Kiểm tra trước khi build
```bash
# Kiểm tra lỗi
flutter analyze

# Kiểm tra dependencies
flutter pub get
```

## Troubleshooting

### Lỗi: "No devices found"
- Kiểm tra USB Debugging đã bật trên điện thoại
- Chạy `adb devices` để xem danh sách thiết bị
- Khởi động lại adb: `adb kill-server && adb start-server`

### Lỗi: "Gradle build failed"
- Xóa cache: `flutter clean`
- Xóa build folder: `rm -rf build/` (Linux/Mac) hoặc `rmdir /s build` (Windows)
- Chạy lại: `flutter pub get && flutter run`

### Magic Link không hoạt động
- Kiểm tra deep link đã được cấu hình trong AndroidManifest.xml
- Kiểm tra redirect URL trong Supabase Dashboard
- Test trên máy thật (emulator có thể không hỗ trợ deep link tốt)

