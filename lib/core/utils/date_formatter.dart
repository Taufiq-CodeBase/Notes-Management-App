import 'package:intl/intl.dart';

class DateFormatter {
  const DateFormatter._();

  static String relative(DateTime when) {
    final now = DateTime.now();
    final diff = now.difference(when);
    if (diff.inSeconds < 60) return 'just now';
    if (diff.inMinutes < 60) return '${diff.inMinutes}m ago';
    if (diff.inHours < 24) return '${diff.inHours}h ago';
    if (diff.inDays < 7) return '${diff.inDays}d ago';
    return DateFormat('MMM d, y').format(when);
  }
}