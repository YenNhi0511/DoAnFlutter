-- =============================================
-- Script xóa user chưa xác nhận email
-- =============================================

-- Bước 1: Kiểm tra các user chưa xác nhận
SELECT
    ID,
    EMAIL,
    CREATED_AT,
    EMAIL_CONFIRMED_AT,
    CASE
        WHEN EMAIL_CONFIRMED_AT IS NULL THEN
            '❌ Chưa xác nhận'
        ELSE
            '✅ Đã xác nhận'
    END                AS STATUS
FROM
    AUTH.USERS
ORDER BY
    CREATED_AT DESC;

-- Bước 2: Xóa TẤT CẢ user chưa xác nhận (cẩn thận!)
-- Uncomment dòng dưới để chạy
-- DELETE FROM auth.users WHERE email_confirmed_at IS NULL;

-- Bước 3: Xóa user CỤ THỂ (an toàn hơn)
-- Thay 'your-email@example.com' bằng email của bạn
-- DELETE FROM auth.users
-- WHERE email = 'your-email@example.com'
-- AND email_confirmed_at IS NULL;

-- Bước 4: Kiểm tra lại sau khi xóa
SELECT
    COUNT(*) AS TOTAL_USERS,
    COUNT(
        CASE
            WHEN EMAIL_CONFIRMED_AT IS NULL THEN
                1
        END) AS PENDING_USERS,
    COUNT(
        CASE
            WHEN EMAIL_CONFIRMED_AT IS NOT NULL THEN
                1
        END) AS CONFIRMED_USERS
FROM
    AUTH.USERS;