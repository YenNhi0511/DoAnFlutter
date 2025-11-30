// Template push script (deprecated) for server-side push sending
// and demonstrates how you might integrate with various push providers
// (OneSignal, Firebase Admin, etc.). This script is provider-agnostic and
// includes examples in comments. Replace the provider call with your own.

require('dotenv').config();
const { createClient } = require('@supabase/supabase-js');
const argv = require('yargs/yargs')(process.argv.slice(2)).argv;

const SUPABASE_URL = process.env.SUPABASE_URL;
const SUPABASE_SERVICE_KEY = process.env.SUPABASE_SERVICE_KEY;

if (!SUPABASE_URL || !SUPABASE_SERVICE_KEY) {
  console.error('Please set SUPABASE_URL and SUPABASE_SERVICE_KEY in .env');
  process.exit(1);
}

// Template for sending push notifications has been deprecated because the
// `user_devices` table is no longer included in this project. If you need
// server-side push functionality, implement a provider-specific approach
// using direct provider servers (OneSignal, Firebase Admin, etc.).
//
// Steps to implement if re-enabled:
// - Choose a push provider.
// - Implement token storage mechanism (e.g., a provider-specific device table).
// - Implement server script using the provider's REST API or SDK.
//
// NOTE: This script intentionally does not query `user_devices`.

async function sendWithProvider(tokens, title, body, data = {}) {
  // Example: send via OneSignal REST API
  // const axios = require('axios');
  // const ONE_SIGNAL_APP_ID = process.env.ONE_SIGNAL_APP_ID;
  // const ONE_SIGNAL_REST_KEY = process.env.ONE_SIGNAL_REST_KEY;
  // const payload = { app_id: ONE_SIGNAL_APP_ID, include_player_ids: tokens, headings: { en: title }, contents: { en: body }, data };
  // await axios.post('https://onesignal.com/api/v1/notifications', payload, { headers: { 'Authorization': `Basic ${ONE_SIGNAL_REST_KEY}`, 'Content-Type': 'application/json' } });

  // Example: send via Firebase Admin (if you want server-only Firebase):
  // const admin = require('firebase-admin');
  // if (!admin.apps.length) admin.initializeApp({ credential: admin.credential.cert(JSON.parse(process.env.FIREBASE_SERVICE_ACCOUNT_JSON)) });
  // const message = { notification: { title, body }, tokens };
  // const response = await admin.messaging().sendMulticast(message);
  // Handle response.errors etc.

  // TEMP: Currently just log tokens for manual verification.
  console.log('Tokens to send to:', tokens.length);
  tokens.forEach((t) => console.log('  -', t));
}

async function main() {
  console.error('Deprecated: `user_devices` table has been removed. This script is a template only.');
  console.error('If you want server-based push, implement your own provider flow and direct token storage accordingly.');
  process.exit(1);
}

main().catch(e => console.error(e));
