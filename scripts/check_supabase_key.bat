@echo off
REM Usage: set SUPABASE_URL=https://xyz.supabase.co && set SUPABASE_ANON_KEY=ey... && scripts\check_supabase_key.bat
IF "%SUPABASE_URL%"=="" (
  echo Please set SUPABASE_URL and SUPABASE_ANON_KEY environment variables
  echo Example: set SUPABASE_URL=https://xyz.supabase.co && set SUPABASE_ANON_KEY=ey... && scripts\check_supabase_key.bat
  exit /b 1
)
IF "%SUPABASE_ANON_KEY%"=="" (
  echo Please set SUPABASE_URL and SUPABASE_ANON_KEY environment variables
  exit /b 1
)

curl -s -o nul -w "%%{http_code}" -H "apikey: %SUPABASE_ANON_KEY%" -H "Authorization: Bearer %SUPABASE_ANON_KEY%" "%SUPABASE_URL%/rest/v1/?select=id&limit=1" > tmp.status
set /p STATUS=<tmp.status
if "%STATUS%"=="200" (
  echo SUCCESS: Anon key is valid and allowed to read the Rest API (HTTP 200)
) else if "%STATUS%"=="401" (
  echo ERROR: Received HTTP 401 Unauthorized — likely an invalid anon key or the project requires different auth settings
) else (
  echo Received HTTP status code: %STATUS% — check your anon key, URL and the table policies (RLS).
)
del tmp.status
