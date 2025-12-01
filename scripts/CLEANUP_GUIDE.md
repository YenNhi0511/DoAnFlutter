# Hướng dẫn Xóa Sạch Dữ Liệu ProjectFlow

## Vấn đề
Khi bạn xóa user trong bảng `users` nhưng vẫn không thể tạo lại tài khoản với cùng email, đó là vì:
- Tài khoản vẫn còn trong bảng `auth.users` (bảng authentication của Supabase)
- Supabase không cho phép tạo lại tài khoản với email đã tồn tại trong `auth.users`

## Giải pháp

### Cách 1: Xóa qua Supabase Dashboard (Dễ nhất) ⭐

1. **Vào Supabase Dashboard**
   - Truy cập: https://app.supabase.com
   - Chọn project của bạn

2. **Xóa users trong Authentication**
   - Vào **Authentication** → **Users**
   - Chọn các user cần xóa
   - Click **Delete** hoặc **Delete selected**

3. **Xóa dữ liệu trong Database**
   - Vào **SQL Editor**
   - Chạy script `cleanup_all_data.sql` (chỉ phần xóa bảng custom, bỏ qua phần xóa auth.users)

### Cách 2: Xóa bằng SQL Script

#### Bước 1: Xóa dữ liệu trong các bảng custom
1. Vào Supabase Dashboard → **SQL Editor**
2. Chạy script `cleanup_all_data.sql` (chỉ phần xóa bảng custom)

#### Bước 2: Xóa users trong auth.users
**QUAN TRỌNG**: Cần quyền admin hoặc SERVICE_ROLE key

**Option A: Qua Dashboard**
1. Vào **Authentication** → **Users**
2. Xóa thủ công từng user

**Option B: Qua SQL Editor (cần quyền admin)**
1. Vào **SQL Editor**
2. Chạy script `delete_auth_users.sql`

**Option C: Dùng Service Role Key (từ code)**
```dart
// Chỉ dùng trong script tạm thời, KHÔNG commit vào code
final supabase = SupabaseClient(
  'YOUR_SUPABASE_URL',
  'YOUR_SERVICE_ROLE_KEY', // Dùng SERVICE_ROLE_KEY, không phải ANON_KEY
);

// Xóa user
await supabase.auth.admin.deleteUser('user-id');
```

### Cách 3: Xóa theo email cụ thể

Nếu chỉ muốn xóa một vài email cụ thể:

```sql
-- Xóa trong auth.users
DELETE FROM auth.users WHERE email = 'your-email@example.com';

-- Xóa trong bảng users custom
DELETE FROM users WHERE email = 'your-email@example.com';
```

## Scripts có sẵn

1. **`cleanup_all_data.sql`**: Xóa tất cả dữ liệu trong các bảng custom
2. **`delete_auth_users.sql`**: Xóa users trong auth.users
3. **`CLEANUP_GUIDE.md`**: File hướng dẫn này

## Lưu ý quan trọng

⚠️ **CẢNH BÁO**:
- Xóa dữ liệu là **KHÔNG THỂ HOÀN TÁC**
- Backup dữ liệu trước khi xóa (nếu cần)
- Chỉ xóa khi đang trong giai đoạn development/test

✅ **Sau khi xóa**:
- Bạn có thể tạo lại tài khoản với cùng email
- Tất cả dữ liệu sẽ được reset về trạng thái ban đầu
- Cấu trúc bảng vẫn được giữ nguyên

## Kiểm tra sau khi xóa

Chạy query này để kiểm tra:

```sql
-- Kiểm tra bảng custom
SELECT 'users' as table_name, COUNT(*) as count FROM users
UNION ALL
SELECT 'projects', COUNT(*) FROM projects
UNION ALL
SELECT 'tasks', COUNT(*) FROM tasks;

-- Kiểm tra auth.users (cần quyền admin)
SELECT COUNT(*) as auth_users_count FROM auth.users;
```

Tất cả nên trả về `0`.

