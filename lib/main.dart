import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_dotenv/flutter_dotenv.dart';
// Firebase removed: we no longer use firebase_core nor firebase_messaging
import 'core/router/app_router.dart';
import 'core/theme/app_theme.dart';
import 'core/services/local_storage_service.dart';
import 'core/services/notification_service.dart';
import 'core/services/supabase_service.dart';
import 'providers/theme_provider.dart';
import 'providers/auth_provider.dart';

void main() async {
  WidgetsFlutterBinding.ensureInitialized();

  // Set preferred orientations
  await SystemChrome.setPreferredOrientations([
    DeviceOrientation.portraitUp,
    DeviceOrientation.portraitDown,
    DeviceOrientation.landscapeLeft,
    DeviceOrientation.landscapeRight,
  ]);

  // Firebase removed: using Supabase Auth (Postgres) for authentication
  // No Firebase initialization or FCM setup - Supabase is the primary backend.
  // Load environment variables from .env (if present)
  try {
    await dotenv.load(fileName: '.env');
  } catch (e) {
    // If the .env isn't accessible in the packaged app, print a helpful warning
    // and continue using any fallback values (or dart-define). This prevents
    // the app from crashing at startup when .env is missing.
    // For production builds, prefer using --dart-define or secure secrets.
    print(
        '⚠️ .env not found at runtime (packaged app). If you rely on .env, add it to assets or use --dart-define.');
  }

  // Quick validation / debug prints (will not show full secrets)
  final loadedUrl = dotenv.env['SUPABASE_URL'];
  final loadedAnon = dotenv.env['SUPABASE_ANON_KEY'];

  if (loadedUrl == null || loadedUrl.isEmpty) {
    print(
        '⚠️ SUPABASE_URL not found in .env. Make sure .env is in project root and contains SUPABASE_URL.');
  } else {
    print('✅ SUPABASE_URL read: $loadedUrl');
  }

  if (loadedAnon == null || loadedAnon.isEmpty) {
    print(
        '⚠️ SUPABASE_ANON_KEY not found in .env. Make sure .env is in project root and contains SUPABASE_ANON_KEY.');
  } else {
    final prefix =
        loadedAnon.length > 8 ? loadedAnon.substring(0, 8) : loadedAnon;
    print('✅ SUPABASE_ANON_KEY prefix: $prefix...');
    if (!loadedAnon.startsWith('eyJ')) {
      print(
          '⚠️ The ANON key does not look like a valid JWT (does not start with eyJ). Double-check the key on Supabase > Settings > API Keys.');
    }
  }

  // Initialize Supabase using environment variables
  await SupabaseService.initialize(
    url: dotenv.env['SUPABASE_URL'] ?? 'YOUR_SUPABASE_URL',
    anonKey: dotenv.env['SUPABASE_ANON_KEY'] ?? 'YOUR_SUPABASE_ANON_KEY',
  );

  // Initialize Local Storage
  await LocalStorageService.initialize();

  // Initialize Local Notifications
  await NotificationService.initialize();
  await NotificationService.requestPermissions();
  // Push notification token registration has been removed.

  runApp(
    const ProviderScope(
      child: ProjectFlowApp(),
    ),
  );
}

// Firebase background handlers removed.

class ProjectFlowApp extends ConsumerWidget {
  const ProjectFlowApp({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final router = ref.watch(routerProvider);
    final themeMode = ref.watch(themeProvider);
    // No Firebase push registration in this build.

    return MaterialApp.router(
      title: 'ProjectFlow',
      debugShowCheckedModeBanner: false,
      theme: AppTheme.lightTheme,
      darkTheme: AppTheme.darkTheme,
      themeMode: themeMode,
      routerConfig: router,
    );
  }
}
