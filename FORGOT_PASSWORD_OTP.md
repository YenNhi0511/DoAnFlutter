# Chức năng Quên Mật Khẩu với OTP

## Tổng quan

Chức năng quên mật khẩu sử dụng mã OTP (One-Time Password) được gửi qua email để xác thực người dùng trước khi cho phép đặt lại mật khẩu.

## Luồng hoạt động

### 1. Gửi mã OTP

- Người dùng nhập email đã đăng ký
- Hệ thống gửi mã OTP 6 số đến email
- Mã OTP có hiệu lực trong thời gian giới hạn (mặc định Supabase: 60 giây)

### 2. Xác thực OTP và đặt lại mật khẩu

- Người dùng nhập mã OTP nhận được
- Người dùng nhập mật khẩu mới (tối thiểu 6 ký tự)
- Người dùng xác nhận lại mật khẩu
- Hệ thống xác thực OTP và cập nhật mật khẩu mới

## Các file đã được cập nhật

### 1. Repository Layer

**File:** `lib/data/repositories/auth_repository.dart`

Thêm 2 phương thức mới:

```dart
// Gửi mã OTP đến email
Future<Either<Failure, void>> sendPasswordResetOtp(String email);

// Xác thực OTP và đặt lại mật khẩu
Future<Either<Failure, void>> verifyOtpAndResetPassword(
  String email,
  String token,
  String newPassword
);
```

### 2. Provider Layer

**File:** `lib/providers/auth_provider.dart`

Thêm 2 phương thức vào `AuthNotifier`:

```dart
// Gửi OTP
Future<bool> sendPasswordResetOtp(String email);

// Xác thực và reset password
Future<bool> verifyOtpAndResetPassword(
  String email,
  String token,
  String newPassword
);
```

### 3. UI Layer

**File:** `lib/ui/screens/auth/forgot_password_screen.dart`

Màn hình mới với 2 bước:

- **Bước 1:** Nhập email và gửi OTP
- **Bước 2:** Nhập OTP và mật khẩu mới

### 4. Router

**File:** `lib/core/router/app_router.dart`

Route đã có sẵn:

```dart
GoRoute(
  path: '/forgot-password',
  name: 'forgot-password',
  builder: (context, state) => const ForgotPasswordScreen(),
),
```

## Cách sử dụng

### Từ màn hình đăng nhập:

1. Click vào "Forgot Password?"
2. Nhập email đã đăng ký
3. Click "Gửi mã OTP"
4. Kiểm tra email và nhập mã OTP 6 số
5. Nhập mật khẩu mới và xác nhận
6. Click "Đặt lại mật khẩu"

### Xử lý lỗi:

- ✅ Email không tồn tại: "Email không tồn tại trong hệ thống"
- ✅ Rate limit: "Vui lòng đợi 60 giây trước khi gửi lại"
- ✅ OTP hết hạn: "Mã OTP không hợp lệ hoặc đã hết hạn"
- ✅ Mật khẩu không hợp lệ: "Mật khẩu phải có ít nhất 6 ký tự"

## Cấu hình Supabase

### Email Template (Optional)

Để tùy chỉnh email OTP, vào Supabase Dashboard:

1. Authentication > Email Templates
2. Chọn "Magic Link"
3. Tùy chỉnh template với biến: `{{ .Token }}`

### Rate Limiting

Supabase mặc định giới hạn:

- 1 email/60 giây cho cùng một địa chỉ email
- Có thể điều chỉnh trong Dashboard > Authentication > Rate Limits

## Security Features

1. **OTP Expiration:** Mã OTP tự động hết hạn sau 60 giây
2. **One-time use:** Mỗi mã OTP chỉ sử dụng được 1 lần
3. **Rate limiting:** Ngăn chặn spam và brute force
4. **Email verification:** Chỉ gửi OTP cho email đã đăng ký
5. **Password validation:** Mật khẩu mới phải đủ mạnh (≥6 ký tự)

## Testing

### Test case 1: Gửi OTP thành công

```
Input: email đã đăng ký
Expected: Hiển thị form nhập OTP, email nhận được mã
```

### Test case 2: Email không tồn tại

```
Input: email chưa đăng ký
Expected: Lỗi "Email không tồn tại trong hệ thống"
```

### Test case 3: Rate limit

```
Input: Gửi OTP nhiều lần liên tiếp
Expected: Lỗi "Vui lòng đợi 60 giây trước khi gửi lại"
```

### Test case 4: OTP đúng + mật khẩu mới

```
Input: Mã OTP đúng + mật khẩu ≥6 ký tự
Expected: Đặt lại mật khẩu thành công, quay về màn hình login
```

### Test case 5: OTP sai hoặc hết hạn

```
Input: Mã OTP sai hoặc quá 60 giây
Expected: Lỗi "Mã OTP không hợp lệ hoặc đã hết hạn"
```

## Troubleshooting

### Email không được gửi:

1. Kiểm tra SMTP configuration trong Supabase
2. Kiểm tra spam folder
3. Verify email templates đã được enable

### OTP luôn hết hạn:

1. Kiểm tra timezone của server
2. Đảm bảo thiết bị có thời gian chính xác
3. Thử gửi lại OTP mới

### Rate limit quá thấp:

1. Vào Supabase Dashboard
2. Authentication > Rate Limits
3. Điều chỉnh "Email Send Rate Limit"
