import '../models/activity.dart';

class NotificationService {
  // Simplified notification service - no external dependencies
  
  static Future<void> init() async {
    // Initialization placeholder
  }

  static Future<void> scheduleActivityNotifications(
      List<Activity> activities) async {
    // Notification scheduling placeholder
    // Can be implemented later with a simpler approach
  }

  static Future<void> showInstant(String title, String body) async {
    // Instant notification placeholder
  }

  static Future<void> cancelAll() async {
    // Cancel all notifications placeholder
  }
}

class TimeOfDay {
  final int hour;
  final int minute;

  TimeOfDay({required this.hour, required this.minute});
}

