-- =============================================
-- Script xóa users trong auth.users (Authentication)
-- =============================================
-- QUAN TRỌNG: Script này cần chạy với SERVICE_ROLE key
-- hoặc trong Supabase Dashboard với quyền admin
-- =============================================

-- Xóa TẤT CẢ users trong auth.users
DELETE FROM auth.users;

-- Hoặc xóa theo email cụ thể:
-- DELETE FROM auth.users WHERE email = 'your-email@example.com';

-- Hoặc xóa nhiều emails:
-- DELETE FROM auth.users WHERE email IN (
--   'email1@example.com',
--   'email2@example.com',
--   'email3@example.com',
--   'email4@example.com'
-- );

-- Kiểm tra kết quả
SELECT COUNT(*) as remaining_users FROM auth.users;

