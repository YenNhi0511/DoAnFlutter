#!/usr/bin/env bash
# Usage: SUPABASE_URL=https://xyz.supabase.co SUPABASE_ANON_KEY=ey... ./scripts/check_supabase_key.sh
set -e
if [ -z "$SUPABASE_URL" ] || [ -z "$SUPABASE_ANON_KEY" ]; then
  echo "Please set SUPABASE_URL and SUPABASE_ANON_KEY environment variables"
  echo "Example: SUPABASE_URL=https://xyz.supabase.co SUPABASE_ANON_KEY=ey... ./scripts/check_supabase_key.sh"
  exit 1
fi

# Attempt to fetch /rest/v1/ (a read-only endpoint) to verify the anon key
STATUS=$(curl -s -o /dev/null -w "%{http_code}" -H "apikey: $SUPABASE_ANON_KEY" -H "Authorization: Bearer $SUPABASE_ANON_KEY" "$SUPABASE_URL/rest/v1/?select=id&limit=1")
if [ "$STATUS" == "200" ]; then
  echo "SUCCESS: Anon key is valid and allowed to read the Rest API (HTTP 200)"
elif [ "$STATUS" == "401" ]; then
  echo "ERROR: Received HTTP 401 Unauthorized — likely an invalid anon key or the project requires different auth settings"
else
  echo "Received HTTP status code: $STATUS — check your anon key, URL and the table policies (RLS)."
fi
