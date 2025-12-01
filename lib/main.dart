import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_dotenv/flutter_dotenv.dart';
// Thêm thư viện này để sửa lỗi LocaleDataException
import 'package:intl/date_symbol_data_local.dart';

import 'core/router/app_router.dart';
import 'core/theme/app_theme.dart';
import 'core/services/local_storage_service.dart';
import 'core/services/notification_service.dart';
import 'core/services/supabase_service.dart';
import 'core/services/offline_queue_service.dart';
import 'core/widgets/error_boundary.dart';
import 'providers/theme_provider.dart';

void main() async {
  WidgetsFlutterBinding.ensureInitialized();

  // Set preferred orientations
  await SystemChrome.setPreferredOrientations([
    DeviceOrientation.portraitUp,
    DeviceOrientation.portraitDown,
    DeviceOrientation.landscapeLeft,
    DeviceOrientation.landscapeRight,
  ]);

  // Load environment variables
  try {
    await dotenv.load(fileName: '.env');
  } catch (e) {
    print(
        '⚠️ .env not found at runtime (packaged app). If you rely on .env, add it to assets or use --dart-define.');
  }

  // --- DEBUG PRINTS ---
  final loadedUrl = dotenv.env['SUPABASE_URL'];
  final loadedAnon = dotenv.env['SUPABASE_ANON_KEY'];

  if (loadedUrl == null || loadedUrl.isEmpty) {
    print(
        '⚠️ SUPABASE_URL not found in .env. Make sure .env is in project root and contains SUPABASE_URL.');
  } else {
    print('✅ SUPABASE_URL read: $loadedUrl');
  }

  if (loadedAnon == null || loadedAnon.isEmpty) {
    print('⚠️ SUPABASE_ANON_KEY not found in .env.');
  } else {
    final prefix =
        loadedAnon.length > 8 ? loadedAnon.substring(0, 8) : loadedAnon;
    print('✅ SUPABASE_ANON_KEY prefix: $prefix...');
  }
  // --------------------

  // Initialize Supabase using environment variables
  await SupabaseService.initialize(
    url: dotenv.env['SUPABASE_URL'] ?? 'YOUR_SUPABASE_URL',
    anonKey: dotenv.env['SUPABASE_ANON_KEY'] ?? 'YOUR_SUPABASE_ANON_KEY',
  );

  // Initialize Local Storage
  await LocalStorageService.initialize();

  // Initialize Offline Queue
  await OfflineQueueService.initialize();

  // Initialize Local Notifications
  await NotificationService.initialize();
  await NotificationService.requestPermissions();

  // --- SỬA LỖI LOCALE TẠI ĐÂY ---
  // Khởi tạo dữ liệu định dạng ngày tháng cho tiếng Việt (hoặc ngôn ngữ bạn dùng)
  // Nếu bạn dùng tiếng Anh, thay 'vi' bằng 'en_US' hoặc để null để khởi tạo tất cả.
  await initializeDateFormatting('vi_VN', null);
  // ------------------------------

  runApp(
    ProviderScope(
      child: ErrorBoundary(
        child: const ProjectFlowApp(),
      ),
    ),
  );
}

class ProjectFlowApp extends ConsumerWidget {
  const ProjectFlowApp({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final router = ref.watch(routerProvider);
    final themeMode = ref.watch(themeProvider);

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
