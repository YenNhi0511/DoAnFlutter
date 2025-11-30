/// Supabase Configuration
/// 
/// Replace these values with your actual Supabase project credentials.
/// You can find these in your Supabase project settings:
/// https://app.supabase.com/project/_/settings/api
/// 
/// IMPORTANT: Never commit real credentials to version control.
/// Use environment variables or a .env file for production.
class SupabaseConfig {
  /// Your Supabase project URL
  /// Example: https://xyzcompany.supabase.co
  static const String url = 'YOUR_SUPABASE_URL';
  
  /// Your Supabase anonymous/public key
  /// This is safe to use in client-side code
  static const String anonKey = 'YOUR_SUPABASE_ANON_KEY';
}

