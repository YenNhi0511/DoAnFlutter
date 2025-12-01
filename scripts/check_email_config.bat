@echo off
echo ================================================
echo KIEM TRA CAU HINH SUPABASE EMAIL
echo ================================================
echo.

REM Doc bien moi truong
for /f "tokens=1,2 delims==" %%a in (.env) do (
    if "%%a"=="SUPABASE_URL" set SUPABASE_URL=%%b
    if "%%a"=="SUPABASE_ANON_KEY" set SUPABASE_ANON_KEY=%%b
)

echo 1. Thong tin Supabase:
echo    URL: %SUPABASE_URL%
echo    Key: %SUPABASE_ANON_KEY:~0,30%...
echo.

echo 2. Kiem tra ket noi Supabase...
curl -s -o nul -w "   HTTP Status: %%{http_code}\n" ^
    -H "apikey: %SUPABASE_ANON_KEY%" ^
    -H "Authorization: Bearer %SUPABASE_ANON_KEY%" ^
    "%SUPABASE_URL%/rest/v1/?select=id&limit=1"

echo.
echo 3. Huong dan cau hinh Email Templates:
echo.
echo    Buoc 1: Truy cap Supabase Dashboard
echo    https://app.supabase.com
echo.
echo    Buoc 2: Chon project cua ban
echo    Project: ymxxmsoshklesexevjsg
echo.
echo    Buoc 3: Vao Authentication ^> Email Templates
echo.
echo    Buoc 4: Sua template "Magic Link":
echo    - Them {{ .Token }} de hien thi ma OTP
echo    - Xem file SUPABASE_EMAIL_SETUP.md de lay template day du
echo.
echo    Buoc 5: Tat email confirmation (tam thoi):
echo    - Vao Authentication ^> Providers ^> Email
echo    - Tat "Confirm email"
echo.
echo 4. Test chuc nang:
echo    flutter run
echo    - Thu dang ky: Nen vao luon khong can xac nhan
echo    - Thu quen mat khau: Nen nhan duoc ma OTP 6 so
echo.
echo ================================================
echo Doc them chi tiet: SUPABASE_EMAIL_SETUP.md
echo ================================================
pause
