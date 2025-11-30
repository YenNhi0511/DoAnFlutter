import 'package:supabase_flutter/supabase_flutter.dart';

class SupabaseService {
  static SupabaseClient get client => Supabase.instance.client;
  
  static Future<void> initialize({
    required String url,
    required String anonKey,
  }) async {
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

