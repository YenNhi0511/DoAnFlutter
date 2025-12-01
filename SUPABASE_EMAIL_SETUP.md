# Cấu hình Email Templates cho Supabase

## Vấn đề hiện tại

### 1. Link xác nhận email load lâu và không hiển thị

**Nguyên nhân:**

- Template mặc định redirect qua localhost:3000 (không tồn tại)
- Link xác nhận từ Supabase có thể bị expire nhanh
- Cần cấu hình redirect URL về app Flutter

### 2. Email OTP không hiển thị mã

**Nguyên nhân:**

- Template "Magic Link" mặc định chỉ có link, không hiển thị mã OTP
- Cần custom template để hiển thị `{{ .Token }}`

---

## Giải pháp: Cấu hình Email Templates

### Bước 1: Truy cập Supabase Dashboard

1. Đăng nhập: https://app.supabase.com
2. Chọn project: **ymxxmsoshklesexevjsg**
3. Vào: **Authentication** → **Email Templates**

---

### Bước 2: Cấu hình "Magic Link" Template (cho OTP)

Click vào **"Magic Link"** và thay đổi template như sau:

```html
<!DOCTYPE html>
<html lang="vi">
  <head>
    <meta charset="UTF-8" />
    <meta name="viewport" content="width=device-width, initial-scale=1.0" />
    <title>Mã OTP - ProjectFlow</title>
    <style>
      body {
        font-family: -apple-system, BlinkMacSystemFont, "Segoe UI", Roboto,
          "Helvetica Neue", Arial, sans-serif;
        line-height: 1.6;
        color: #333;
        max-width: 600px;
        margin: 0 auto;
        padding: 20px;
        background-color: #f5f5f5;
      }
      .container {
        background-color: #ffffff;
        border-radius: 8px;
        padding: 40px;
        box-shadow: 0 2px 4px rgba(0, 0, 0, 0.1);
      }
      .header {
        text-align: center;
        margin-bottom: 30px;
      }
      .logo {
        font-size: 24px;
        font-weight: bold;
        color: #1e3a5f;
        margin-bottom: 10px;
      }
      .title {
        color: #1e3a5f;
        font-size: 24px;
        font-weight: 600;
        margin-bottom: 20px;
        text-align: center;
      }
      .otp-container {
        background-color: #f0f7ff;
        border: 2px dashed #2196f3;
        border-radius: 8px;
        padding: 30px;
        margin: 30px 0;
        text-align: center;
      }
      .otp-label {
        font-size: 14px;
        color: #666;
        margin-bottom: 10px;
        text-transform: uppercase;
        letter-spacing: 1px;
      }
      .otp-code {
        font-size: 36px;
        font-weight: bold;
        color: #2196f3;
        letter-spacing: 8px;
        font-family: "Courier New", monospace;
      }
      .message {
        color: #555;
        font-size: 16px;
        margin: 20px 0;
        text-align: center;
      }
      .warning {
        background-color: #fff3cd;
        border-left: 4px solid #ffc107;
        padding: 15px;
        margin: 20px 0;
        border-radius: 4px;
      }
      .warning-text {
        color: #856404;
        font-size: 14px;
        margin: 0;
      }
      .footer {
        margin-top: 40px;
        padding-top: 20px;
        border-top: 1px solid #eee;
        text-align: center;
        color: #999;
        font-size: 12px;
      }
      .alternative-link {
        margin-top: 20px;
        padding: 15px;
        background-color: #f8f9fa;
        border-radius: 4px;
        text-align: center;
      }
      .link-button {
        display: inline-block;
        padding: 12px 24px;
        background-color: #2196f3;
        color: #ffffff !important;
        text-decoration: none;
        border-radius: 4px;
        font-weight: 500;
        margin-top: 10px;
      }
    </style>
  </head>
  <body>
    <div class="container">
      <div class="header">
        <div class="logo">📱 ProjectFlow</div>
      </div>

      <h2 class="title">Mã xác thực OTP</h2>

      <p class="message">
        Bạn đã yêu cầu mã OTP để xác thực tài khoản hoặc đặt lại mật khẩu.
      </p>

      <div class="otp-container">
        <div class="otp-label">Mã OTP của bạn</div>
        <div class="otp-code">{{ .Token }}</div>
      </div>

      <div class="warning">
        <p class="warning-text">
          ⏱️ Mã này chỉ có hiệu lực trong <strong>60 giây</strong>.
          <br />
          🔒 Không chia sẻ mã này với bất kỳ ai.
        </p>
      </div>

      <p class="message">
        Nhập mã trên vào ứng dụng để hoàn tất quá trình xác thực.
      </p>

      <div class="alternative-link">
        <p style="margin: 0 0 10px 0; color: #666; font-size: 14px;">
          Hoặc click vào link bên dưới nếu bạn gặp vấn đề:
        </p>
        <a href="{{ .ConfirmationURL }}" class="link-button">
          Xác thực tài khoản
        </a>
      </div>

      <div class="footer">
        <p>
          Nếu bạn không yêu cầu mã này, vui lòng bỏ qua email này.
          <br />
          Email này được gửi từ ProjectFlow App.
        </p>
      </div>
    </div>
  </body>
</html>
```

**Lưu ý quan trọng:**

- Biến `{{ .Token }}` sẽ hiển thị mã OTP 6 số
- Biến `{{ .ConfirmationURL }}` là link backup nếu cần

---

### Bước 3: Cấu hình "Confirm signup" Template

Click vào **"Confirm signup"** và thay đổi:

```html
<!DOCTYPE html>
<html lang="vi">
  <head>
    <meta charset="UTF-8" />
    <meta name="viewport" content="width=device-width, initial-scale=1.0" />
    <title>Xác nhận đăng ký - ProjectFlow</title>
    <style>
      body {
        font-family: -apple-system, BlinkMacSystemFont, "Segoe UI", Roboto,
          "Helvetica Neue", Arial, sans-serif;
        line-height: 1.6;
        color: #333;
        max-width: 600px;
        margin: 0 auto;
        padding: 20px;
        background-color: #f5f5f5;
      }
      .container {
        background-color: #ffffff;
        border-radius: 8px;
        padding: 40px;
        box-shadow: 0 2px 4px rgba(0, 0, 0, 0.1);
      }
      .header {
        text-align: center;
        margin-bottom: 30px;
      }
      .logo {
        font-size: 24px;
        font-weight: bold;
        color: #1e3a5f;
        margin-bottom: 10px;
      }
      .title {
        color: #1e3a5f;
        font-size: 24px;
        font-weight: 600;
        margin-bottom: 20px;
        text-align: center;
      }
      .message {
        color: #555;
        font-size: 16px;
        margin: 20px 0;
        line-height: 1.8;
      }
      .button-container {
        text-align: center;
        margin: 40px 0;
      }
      .confirm-button {
        display: inline-block;
        padding: 16px 40px;
        background-color: #2196f3;
        color: #ffffff !important;
        text-decoration: none;
        border-radius: 6px;
        font-weight: 600;
        font-size: 16px;
        box-shadow: 0 2px 4px rgba(33, 150, 243, 0.3);
      }
      .confirm-button:hover {
        background-color: #1976d2;
      }
      .otp-section {
        background-color: #f0f7ff;
        border-radius: 8px;
        padding: 20px;
        margin: 30px 0;
        text-align: center;
      }
      .otp-label {
        font-size: 14px;
        color: #666;
        margin-bottom: 10px;
      }
      .otp-code {
        font-size: 32px;
        font-weight: bold;
        color: #2196f3;
        letter-spacing: 6px;
        font-family: "Courier New", monospace;
      }
      .warning {
        background-color: #fff3cd;
        border-left: 4px solid #ffc107;
        padding: 15px;
        margin: 20px 0;
        border-radius: 4px;
        font-size: 14px;
        color: #856404;
      }
      .footer {
        margin-top: 40px;
        padding-top: 20px;
        border-top: 1px solid #eee;
        text-align: center;
        color: #999;
        font-size: 12px;
      }
    </style>
  </head>
  <body>
    <div class="container">
      <div class="header">
        <div class="logo">📱 ProjectFlow</div>
      </div>

      <h2 class="title">Chào mừng đến với ProjectFlow! 🎉</h2>

      <p class="message">
        Cảm ơn bạn đã đăng ký tài khoản. Để hoàn tất quá trình đăng ký, vui lòng
        xác nhận địa chỉ email của bạn.
      </p>

      <div class="otp-section">
        <div class="otp-label">Mã xác nhận của bạn:</div>
        <div class="otp-code">{{ .Token }}</div>
      </div>

      <p
        class="message"
        style="text-align: center; font-size: 14px; color: #666;"
      >
        Nhập mã trên vào ứng dụng hoặc click nút bên dưới
      </p>

      <div class="button-container">
        <a href="{{ .ConfirmationURL }}" class="confirm-button">
          ✓ Xác nhận email
        </a>
      </div>

      <div class="warning">
        ⏱️ Link này sẽ hết hạn sau <strong>60 giây</strong>
        <br />
        🔒 Không chia sẻ link hoặc mã này với bất kỳ ai
      </div>

      <p class="message">
        Sau khi xác nhận, bạn có thể đăng nhập và bắt đầu sử dụng ProjectFlow để
        quản lý dự án của mình.
      </p>

      <div class="footer">
        <p>
          Nếu bạn không tạo tài khoản này, vui lòng bỏ qua email này.
          <br />
          Email này được gửi tự động từ ProjectFlow App.
        </p>
      </div>
    </div>
  </body>
</html>
```

---

### Bước 4: Cấu hình Redirect URLs

Vào **Authentication** → **URL Configuration**:

1. **Site URL:** Để mặc định hoặc nhập: `https://ymxxmsoshklesexevjsg.supabase.co`

2. **Redirect URLs:** Thêm các URL sau (mỗi URL một dòng):
   ```
   https://ymxxmsoshklesexevjsg.supabase.co/**
   http://localhost:3000/**
   projectflow://auth/callback
   ```

---

### Bước 5: Tắt Email Confirmation (Khuyến nghị cho development)

Nếu bạn muốn người dùng đăng ký xong vào luôn không cần xác nhận email:

1. Vào **Authentication** → **Providers** → **Email**
2. Tìm **"Confirm email"**
3. **TẮT** tùy chọn này

**Lưu ý:** Chỉ nên tắt khi đang development. Production nên bật lại.

---

## Kiểm tra Email Template

### Test gửi OTP:

1. Vào app → Forgot Password
2. Nhập email → Gửi OTP
3. Kiểm tra email → Sẽ thấy:
   ```
   Mã OTP của bạn
   ┌─────────┐
   │ 123456 │
   └─────────┘
   ```

### Test xác nhận đăng ký:

1. Đăng ký tài khoản mới
2. Kiểm tra email
3. Sẽ thấy mã OTP và nút "Xác nhận email"

---

## Xử lý vấn đề Link load lâu

### Nguyên nhân:

- Supabase redirect qua `localhost:3000` (không tồn tại)
- App Flutter không handle deep link

### Giải pháp 1: Dùng mã OTP thay vì link

✅ **Đã implement:** Người dùng nhập mã OTP trực tiếp vào app

### Giải pháp 2: Setup Deep Links (Nâng cao)

#### Android (`android/app/src/main/AndroidManifest.xml`):

```xml
<intent-filter android:autoVerify="true">
    <action android:name="android.intent.action.VIEW" />
    <category android:name="android.intent.category.DEFAULT" />
    <category android:name="android.intent.category.BROWSABLE" />
    <data android:scheme="projectflow" />
    <data android:host="auth" />
</intent-filter>
```

#### iOS (`ios/Runner/Info.plist`):

```xml
<key>CFBundleURLTypes</key>
<array>
    <dict>
        <key>CFBundleURLSchemes</key>
        <array>
            <string>projectflow</string>
        </array>
    </dict>
</array>
```

#### Cập nhật Supabase redirect URL:

```
projectflow://auth/callback
```

---

## Tóm tắt các bước cần làm NGAY

### ✅ Ưu tiên cao (Làm ngay):

1. **Vào Supabase Dashboard**

   - Authentication → Email Templates → Magic Link
   - Copy template mới (có `{{ .Token }}`)
   - Save

2. **Tắt Email Confirmation** (tạm thời)

   - Authentication → Providers → Email
   - Tắt "Confirm email"
   - Save

3. **Test lại:**
   - Đăng ký tài khoản mới → Vào luôn (không cần xác nhận)
   - Forgot Password → Nhận email có mã OTP rõ ràng

### 📋 Làm sau (Optional):

4. Setup Deep Links cho production
5. Bật lại Email Confirmation khi deploy
6. Custom SMTP (nếu muốn dùng email riêng)

---

## Kiểm tra sau khi cấu hình

Chạy các lệnh test:

```bash
# Test 1: Đăng ký
flutter run
# → Đăng ký → Vào luôn (nếu đã tắt email confirmation)

# Test 2: Quên mật khẩu
# → Forgot Password → Nhập email
# → Kiểm tra email → Thấy mã OTP 6 số rõ ràng

# Test 3: Nhập OTP
# → Copy mã → Paste vào app → Đặt mật khẩu mới
```

---

## Lỗi thường gặp

### 1. Email không nhận được:

- ✓ Kiểm tra spam folder
- ✓ Verify email template đã save
- ✓ Check SMTP settings trong Supabase

### 2. Link vẫn load lâu:

- ✓ Ignore link, chỉ dùng mã OTP
- ✓ Hoặc setup deep links

### 3. OTP hết hạn nhanh:

- ✓ Default 60s, không thể thay đổi
- ✓ Gửi lại OTP nếu cần

---

## Support

Nếu gặp vấn đề, kiểm tra:

1. Supabase logs: Dashboard → Logs → API
2. Flutter logs: `flutter logs`
3. Email delivery: Supabase → Authentication → Rate Limits
