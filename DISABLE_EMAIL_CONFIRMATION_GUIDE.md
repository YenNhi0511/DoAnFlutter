# 🎯 HƯỚNG DẪN TỪNG BƯỚC: Tắt Email Confirmation

## 📸 Có ảnh minh họa từng bước

---

## Bước 1: Truy cập Supabase Dashboard

### Link trực tiếp:

🔗 https://app.supabase.com/project/ymxxmsoshklesexevjsg/auth/providers

Hoặc:

1. Vào https://app.supabase.com
2. Click vào project: **ymxxmsoshklesexevjsg**
3. Menu bên trái → **Authentication** (biểu tượng 🔐)
4. Click tab **Providers**

---

## Bước 2: Tìm phần Email Provider

Kéo xuống trang, tìm phần:

```
┌─────────────────────────────────────┐
│  Email                         ✓   │
│  --------------------------------   │
│  ☑️ Enable email provider          │
│  ☑️ Confirm email          ← ĐÂY!  │
│  ☐ Secure email change             │
│  ...                                │
└─────────────────────────────────────┘
```

---

## Bước 3: Tắt "Confirm email"

### TRƯỚC KHI TẮT:

```
☑️ Confirm email    ← Đang BẬT (có dấu ✓)
```

### Click vào checkbox:

```
☐ Confirm email     ← Đã TẮT (không có dấu ✓)
```

---

## Bước 4: Lưu thay đổi

Kéo xuống cuối trang, click:

```
┌──────────────────┐
│  💾 Save         │
└──────────────────┘
```

Đợi thông báo: **"Successfully updated auth config"** ✅

---

## Bước 5: Xóa user đang pending

### Option A: Xóa qua Dashboard (Dễ)

1. Vào: **Authentication** → **Users**

   🔗 https://app.supabase.com/project/ymxxmsoshklesexevjsg/auth/users

2. Tìm email của bạn trong danh sách

3. Nhìn cột **"Confirmed"**:

   ```
   Email               | Confirmed | Actions
   ────────────────────┼───────────┼─────────
   you@email.com       | ❌        | ⋮
   ```

4. Click 3 chấm **⋮** → **Delete User**

5. Confirm: **"Yes, delete user"**

### Option B: Xóa qua SQL Editor (Nhanh)

1. Vào: **SQL Editor**

   🔗 https://app.supabase.com/project/ymxxmsoshklesexevjsg/sql/new

2. Copy và paste script này:

```sql
-- Xem user chưa xác nhận
SELECT id, email, email_confirmed_at
FROM auth.users
WHERE email_confirmed_at IS NULL;
```

3. Click **Run** ▶️

4. Nếu thấy email của bạn, chạy lệnh xóa:

```sql
-- Thay 'your@email.com' bằng email của bạn
DELETE FROM auth.users
WHERE email = 'your@email.com'
AND email_confirmed_at IS NULL;
```

5. Click **Run** ▶️

6. Thấy: **"1 row deleted"** ✅

---

## Bước 6: Test lại

### Mở app Flutter:

```bash
cd D:\DoAnFlutter
flutter run
```

### Đăng ký lại:

1. Click **"Sign Up"**
2. Nhập:
   - Email: `your@email.com`
   - Password: `123456` (hoặc mật khẩu của bạn)
   - Name: `Tên bạn`
3. Click **"Sign Up"**

### Kết quả mong đợi:

```
✅ Đăng ký thành công!
✅ Tự động đăng nhập
✅ Vào màn hình Home ngay lập tức
❌ KHÔNG cần check email
❌ KHÔNG cần click link xác nhận
```

---

## ✅ Checklist hoàn thành

- [ ] Vào Supabase Dashboard → Providers
- [ ] Tìm "Confirm email"
- [ ] Tắt checkbox (bỏ tick)
- [ ] Save
- [ ] Xóa user pending (Dashboard hoặc SQL)
- [ ] Test đăng ký lại
- [ ] Vào app thành công ✅

---

## 🎯 Kết quả sau khi hoàn thành

### TRƯỚC (có Email Confirmation):

```
1. Đăng ký
2. Thông báo: "Check email to confirm"
3. Mở email
4. Click link xác nhận
5. Link load mãi (localhost:3000) ❌
6. Không vào được app ❌
```

### SAU (tắt Email Confirmation):

```
1. Đăng ký
2. Vào luôn ✅
3. Bắt đầu dùng app ✅
```

---

## 🔧 Troubleshooting

### Lỗi: Vẫn bảo "Email not confirmed"

➡️ **Giải pháp:** Xóa user pending và đăng ký lại

### Lỗi: Email already registered

➡️ **Giải pháp:** Dùng email khác hoặc xóa user cũ qua SQL

### Lỗi: Cannot delete user

➡️ **Giải pháp:** Chạy SQL:

```sql
DELETE FROM auth.users WHERE email = 'your@email.com';
```

---

## 💡 Khi nào BẬT lại Email Confirmation?

### Tắt khi:

- ✅ Đang development/testing
- ✅ Muốn test nhanh
- ✅ Demo app cho người khác

### Bật khi:

- ✅ Deploy production
- ✅ Cần verify email thật
- ✅ Chống spam/fake account

### Cách BẬT lại:

1. Vào Providers → Email
2. **Tick** vào "Confirm email"
3. Save
4. Setup redirect URL đúng
5. Test kỹ trước khi deploy

---

## 📞 Cần trợ giúp?

Nếu làm theo vẫn không được:

1. **Check logs:** Supabase Dashboard → Logs
2. **Check app logs:** `flutter logs`
3. **Verify config:** Chạy `scripts/check_email_config.bat`
4. **Xem chi tiết:** File `FIX_CONFIRM_EMAIL_LINK.md`

---

## 🎉 Hoàn tất!

Sau khi làm xong, bạn sẽ:

- ✅ Đăng ký vào luôn không cần xác nhận email
- ✅ Test app nhanh hơn
- ✅ Không còn bị stuck ở link localhost:3000

Happy coding! 🚀
