import 'dart:io';
import 'package:uuid/uuid.dart';
import 'package:supabase_flutter/supabase_flutter.dart';
import 'supabase_service.dart';

class StorageService {
  static final _client = SupabaseService.client;
  static const String _bucket = 'attachments';

  static Future<String> uploadAttachment(File file) async {
    final uuid = const Uuid().v4();
    final ext = file.path.split('.').last;
    final path = 'attachments/$uuid.$ext';

    try {
      final bytes = await file.readAsBytes();
      await _client.storage.from(_bucket).uploadBinary(path, bytes);
      final publicUrl = _client.storage.from(_bucket).getPublicUrl(path);
      return publicUrl;
    } catch (e) {
      rethrow;
    }
  }
}
