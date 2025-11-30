import 'package:supabase_flutter/supabase_flutter.dart';

class SupabaseService {
  static SupabaseClient get client => Supabase.instance.client;
  static String? baseUrl;
  static String? anonKeyPreview;

  static Future<void> initialize({
    required String url,
    required String anonKey,
  }) async {
    baseUrl = url;
    // Store a preview of the anon key for safe dev logging
    anonKeyPreview =
        anonKey.length > 30 ? '${anonKey.substring(0, 30)}...' : anonKey;
    await Supabase.initialize(
      url: url,
      anonKey: anonKey,
      authOptions: const FlutterAuthClientOptions(
        authFlowType: AuthFlowType.pkce,
      ),
      realtimeClientOptions: const RealtimeClientOptions(
        logLevel: RealtimeLogLevel.info,
      ),
    );
  }

  // Tables
  static const String usersTable = 'users';
  static const String projectsTable = 'projects';
  static const String projectMembersTable = 'project_members';
  static const String boardsTable = 'boards';
  static const String columnsTable = 'board_columns';
  static const String tasksTable = 'tasks';
  static const String commentsTable = 'comments';
  static const String labelsTable = 'labels';
  static const String notificationsTable = 'notifications';
  static const String activitiesTable = 'activities';
}
