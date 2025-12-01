-- =============================================
-- Script xóa sạch TẤT CẢ dữ liệu ProjectFlow
-- =============================================
-- CẢNH BÁO: Script này sẽ xóa TẤT CẢ dữ liệu!
-- Chỉ chạy khi bạn muốn reset hoàn toàn database
-- =============================================

-- Bước 1: Xóa tất cả dữ liệu trong các bảng (theo thứ tự để tránh lỗi foreign key)
-- Xóa từ bảng con trước, sau đó đến bảng cha

-- Xóa Activities
DELETE FROM activities;

-- Xóa Comments
DELETE FROM comments;

-- Xóa Tasks
DELETE FROM tasks;

-- Xóa Board Columns
DELETE FROM board_columns;

-- Xóa Boards
DELETE FROM boards;

-- Xóa Labels
DELETE FROM labels;

-- Xóa Project Members
DELETE FROM project_members;

-- Xóa Projects
DELETE FROM projects;

-- Xóa Notifications
DELETE FROM notifications;

-- Xóa Users (bảng custom)
DELETE FROM users;

-- Bước 2: Xóa TẤT CẢ users trong auth.users (bảng authentication của Supabase)
-- LƯU Ý: Chỉ có thể xóa trong Supabase Dashboard hoặc dùng service_role key
-- Script này cần chạy với quyền admin

-- Xóa tất cả users trong auth schema
-- (Chạy trong Supabase SQL Editor với quyền admin)
DELETE FROM auth.users;

-- Hoặc nếu muốn xóa theo email cụ thể:
-- DELETE FROM auth.users WHERE email = 'your-email@example.com';

-- Bước 3: Reset sequences (nếu có)
-- ALTER SEQUENCE IF EXISTS users_id_seq RESTART WITH 1;

-- =============================================
-- XÁC NHẬN: Kiểm tra xem đã xóa sạch chưa
-- =============================================

-- Kiểm tra số lượng records còn lại
SELECT 'users' as table_name, COUNT(*) as count FROM users
UNION ALL
SELECT 'projects', COUNT(*) FROM projects
UNION ALL
SELECT 'tasks', COUNT(*) FROM tasks
UNION ALL
SELECT 'boards', COUNT(*) FROM boards
UNION ALL
SELECT 'comments', COUNT(*) FROM comments
UNION ALL
SELECT 'notifications', COUNT(*) FROM notifications
UNION ALL
SELECT 'activities', COUNT(*) FROM activities;

-- Kiểm tra auth.users (cần quyền admin)
-- SELECT COUNT(*) as auth_users_count FROM auth.users;

