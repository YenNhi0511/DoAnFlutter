# 🚨 FIX NGAY: Email OTP không hiển thị mã

## ❌ Vấn đề hiện tại

1. **Link xác nhận load lâu** → Redirect qua localhost:3000 (không tồn tại)
2. **Email OTP không có mã** → Template chỉ có link, không có `{{ .Token }}`

## ✅ Giải pháp (5 phút)

### Bước 1: Truy cập Supabase Dashboard

🔗 Link: https://app.supabase.com/project/ymxxmsoshklesexevjsg

Hoặc:

1. Vào https://app.supabase.com
2. Chọn project: **ymxxmsoshklesexevjsg**

---

### Bước 2: Tắt Email Confirmation (QUAN TRỌNG!)

📍 Vào: **Authentication** → **Providers** → **Email**

Kéo xuống tìm:

```
☑️ Confirm email
```

➡️ **Bỏ tick** (TẮT đi)

➡️ Click **Save**

✅ **Kết quả:** Người dùng đăng ký xong vào luôn, không cần xác nhận email

---

### Bước 3: Sửa Email Template "Magic Link"

📍 Vào: **Authentication** → **Email Templates** → **Magic Link**

#### Click "Edit" và thay đổi Subject:

```
Mã OTP - ProjectFlow
```

#### Thay đổi Message Body (copy toàn bộ):

```html
<h2>Mã OTP của bạn</h2>
<p>Bạn đã yêu cầu mã OTP để xác thực.</p>

<div
  style="background-color: #f0f7ff; border: 2px dashed #2196F3; border-radius: 8px; padding: 30px; margin: 30px 0; text-align: center;"
>
  <p style="font-size: 14px; color: #666; margin-bottom: 10px;">
    MÃ OTP CỦA BẠN
  </p>
  <p
    style="font-size: 48px; font-weight: bold; color: #2196F3; letter-spacing: 10px; font-family: monospace; margin: 0;"
  >
    {{ .Token }}
  </p>
</div>

<div
  style="background-color: #fff3cd; border-left: 4px solid #ffc107; padding: 15px; margin: 20px 0;"
>
  <p style="color: #856404; margin: 0;">
    ⏱️ Mã này chỉ có hiệu lực trong <strong>60 giây</strong>
    <br />
    🔒 Không chia sẻ mã này với bất kỳ ai
  </p>
</div>

<p>Nhập mã trên vào ứng dụng để hoàn tất xác thực.</p>

<p
  style="margin-top: 30px; padding-top: 20px; border-top: 1px solid #eee; color: #999; font-size: 12px;"
>
  Nếu bạn không yêu cầu mã này, vui lòng bỏ qua email này.
</p>
```

➡️ Click **Save**

---

### Bước 4: Kiểm tra lại

#### Test 1: Đăng ký (không cần xác nhận)

```bash
flutter run
```

- Đăng ký tài khoản mới
- ✅ Vào luôn không cần check email

#### Test 2: Quên mật khẩu (có mã OTP)

- Click "Forgot Password?"
- Nhập email
- Check email
- ✅ Thấy mã OTP 6 số to và rõ ràng

---

## 📋 Checklist

Làm theo thứ tự:

- [ ] Bước 1: Truy cập Supabase Dashboard
- [ ] Bước 2: Tắt "Confirm email" (Authentication → Providers → Email)
- [ ] Bước 3: Sửa template "Magic Link" (thêm `{{ .Token }}`)
- [ ] Bước 4: Save và test lại

---

---

## ⚙️ Cấu hình Redirect URLs (Optional - nếu cần deep link)

📍 Vào: **Authentication** → **URL Configuration**

1. **Site URL:** Để mặc định
2. **Redirect URLs:** Thêm (từng dòng):
   ```
   https://ymxxmsoshklesexevjsg.supabase.co/**
   http://localhost:3000/**
   projectflow://auth/callback
   ```

**Lưu ý:** Bước này không bắt buộc nếu bạn chỉ dùng mã OTP.

---

## 🔧 Nếu vẫn không được

### Email không nhận được:

1. Kiểm tra **Spam folder**
2. Chờ 1-2 phút (đôi khi Supabase gửi chậm)
3. Gửi lại OTP

### Email vẫn không có mã:

1. Đảm bảo đã **Save** template
2. Clear cache trình duyệt
3. Logout/Login lại Supabase Dashboard
4. Thử lại

### Link vẫn redirect localhost:3000:

➡️ **IGNORE** link, chỉ dùng mã OTP

---

## 📱 Screenshot mẫu

### Trước khi sửa:

```
Email nhận được:
┌────────────────────────┐
│ Follow this link:      │
│ [Confirm your mail]    │  ← Chỉ có link
└────────────────────────┘
```

### Sau khi sửa:

```
Email nhận được:
┌────────────────────────┐
│ MÃ OTP CỦA BẠN        │
│                        │
│      123456           │  ← Mã OTP to và rõ
│                        │
│ ⏱️ Có hiệu lực 60s    │
└────────────────────────┘
```

---

## 📞 Cần hỗ trợ?

Xem thêm file: **SUPABASE_EMAIL_SETUP.md** (hướng dẫn chi tiết hơn)

Hoặc chạy script kiểm tra:

```bash
cd scripts
check_email_config.bat
```
