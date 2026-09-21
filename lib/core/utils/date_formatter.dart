import 'package:intl/intl.dart';

/// Utilities for human-friendly date and time formatting
class DateFormatter {
  DateFormatter._();

  static String formatNoteDate(DateTime dateTime) {
    final now = DateTime.now();
    final difference = now.difference(dateTime);

    if (difference.inSeconds < 60) {
      return 'Just now';
    } else if (difference.inMinutes < 60) {
      return '${difference.inMinutes}m ago';
    } else if (difference.inHours < 24 && dateTime.day == now.day) {
      return DateFormat('h:mm a').format(dateTime);
    } else if (difference.inDays < 7) {
      return DateFormat('EEE, h:mm a').format(dateTime);
    } else if (dateTime.year == now.year) {
      return DateFormat('MMM d').format(dateTime);
    } else {
      return DateFormat('MMM d, yyyy').format(dateTime);
    }
  }

  static String formatFullDate(DateTime dateTime) {
    return DateFormat('MMMM d, yyyy • h:mm a').format(dateTime);
  }

  static String formatShortDate(DateTime dateTime) {
    return DateFormat('MMM d, yyyy').format(dateTime);
  }
}
