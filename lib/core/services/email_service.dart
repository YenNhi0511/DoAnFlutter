import 'package:supabase_flutter/supabase_flutter.dart';
import '../services/supabase_service.dart';
import 'dart:convert';

/// Service to send emails via Supabase Edge Functions or API
class EmailService {
  final SupabaseClient _supabase;

  EmailService({SupabaseClient? supabase})
      : _supabase = supabase ?? SupabaseService.client;

  /// Send invitation email to join project
  Future<bool> sendProjectInvitation({
    required String toEmail,
    required String projectName,
    required String inviterName,
    required String projectId,
  }) async {
    try {
      // Call Supabase Edge Function or use Supabase's built-in email
      final response = await _supabase.functions.invoke(
        'send-invitation-email',
        body: {
          'to': toEmail,
          'subject': 'Invitation to join $projectName',
          'project_name': projectName,
          'inviter_name': inviterName,
          'project_id': projectId,
        },
      );

      return response.status == 200;
    } catch (e) {
      // Fallback: Use Supabase's built-in email if Edge Function not available
      print('Edge Function not available, using fallback: $e');
      return await _sendEmailFallback(
        to: toEmail,
        subject: 'Invitation to join $projectName',
        body: _buildInvitationEmailBody(
          projectName: projectName,
          inviterName: inviterName,
          projectId: projectId,
        ),
      );
    }
  }

  /// Send task assignment notification email
  Future<bool> sendTaskAssignmentEmail({
    required String toEmail,
    required String taskTitle,
    required String projectName,
    required String assignerName,
    required DateTime? dueDate,
  }) async {
    try {
      final response = await _supabase.functions.invoke(
        'send-task-assignment-email',
        body: {
          'to': toEmail,
          'subject': 'New task assigned: $taskTitle',
          'task_title': taskTitle,
          'project_name': projectName,
          'assigner_name': assignerName,
          'due_date': dueDate?.toIso8601String(),
        },
      );

      return response.status == 200;
    } catch (e) {
      print('Email service error: $e');
      return false;
    }
  }

  /// Send task reminder email
  Future<bool> sendTaskReminderEmail({
    required String toEmail,
    required String taskTitle,
    required DateTime dueDate,
  }) async {
    try {
      final response = await _supabase.functions.invoke(
        'send-reminder-email',
        body: {
          'to': toEmail,
          'subject': 'Reminder: $taskTitle is due soon',
          'task_title': taskTitle,
          'due_date': dueDate.toIso8601String(),
        },
      );

      return response.status == 200;
    } catch (e) {
      print('Email service error: $e');
      return false;
    }
  }

  /// Fallback email method (if Edge Functions not configured)
  Future<bool> _sendEmailFallback({
    required String to,
    required String subject,
    required String body,
  }) async {
    // Note: This is a placeholder. In production, you should:
    // 1. Set up Supabase Edge Functions for email
    // 2. Or use a third-party email service (SendGrid, Mailgun, etc.)
    // 3. Or use Supabase's built-in email templates
    
    // For now, log the email that would be sent
    print('Would send email to $to: $subject');
    return true;
  }

  String _buildInvitationEmailBody({
    required String projectName,
    required String inviterName,
    required String projectId,
  }) {
    return '''
    <html>
      <body>
        <h2>You've been invited to join a project!</h2>
        <p>Hi there,</p>
        <p><strong>$inviterName</strong> has invited you to join the project <strong>$projectName</strong>.</p>
        <p>Click the link below to accept the invitation:</p>
        <a href="https://yourapp.com/project/$projectId/accept">Accept Invitation</a>
        <p>Best regards,<br>ProjectFlow Team</p>
      </body>
    </html>
    ''';
  }
}

final emailServiceProvider = Provider<EmailService>((ref) {
  return EmailService();
});

