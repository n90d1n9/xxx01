import 'package:intl/intl.dart';

class DateTimeFormatters {
  // Common date formats
  static final commentTimestamp = DateFormat('MMM dd, yyyy HH:mm');
  static final fullDateTime = DateFormat('MMMM dd, yyyy HH:mm:ss');
  static final shortDate = DateFormat('MM/dd/yyyy');
  static final mediumDate = DateFormat('MMM dd, yyyy');
  static final longDate = DateFormat('MMMM dd, yyyy');
  static final timeOnly = DateFormat('HH:mm:ss');
  static final dayAndTime = DateFormat('E, MMM dd HH:mm');

  // Format specific components
  static final monthAndDay = DateFormat('MMM dd');
  static final yearAndMonth = DateFormat('MMMM yyyy');
  static final weekdayShort = DateFormat('E');
  static final weekdayLong = DateFormat('EEEE');

  // Custom formatters for special cases
  static String formatRelativeTime(DateTime timestamp) {
    final now = DateTime.now();
    final difference = now.difference(timestamp);

    if (difference.inSeconds < 60) {
      return 'Just now';
    } else if (difference.inMinutes < 60) {
      return '${difference.inMinutes}m ago';
    } else if (difference.inHours < 24) {
      return '${difference.inHours}h ago';
    } else if (difference.inDays < 7) {
      return '${difference.inDays}d ago';
    } else {
      return commentTimestamp.format(timestamp);
    }
  }

  static String formatTaskDuration(DateTime start, DateTime end) {
    final difference = end.difference(start);
    
    if (difference.inDays > 0) {
      return '${difference.inDays}d ${difference.inHours % 24}h';
    } else if (difference.inHours > 0) {
      return '${difference.inHours}h ${difference.inMinutes % 60}m';
    } else {
      return '${difference.inMinutes}m';
    }
  }

  // Localized date formatting
  static String formatLocalizedDate(DateTime date, String locale) {
    return DateFormat.yMMMMd(locale).format(date);
  }

  // Format with custom pattern
  static String formatCustomPattern(DateTime date, String pattern) {
    return DateFormat(pattern).format(date);
  }
}

// Example usage extension
extension DateTimeFormatting on DateTime {
  String toCommentFormat() => DateTimeFormatters.commentTimestamp.format(this);
  
  String toFullFormat() => DateTimeFormatters.fullDateTime.format(this);
  
  String toShortDate() => DateTimeFormatters.shortDate.format(this);
  
  String toRelativeTime() => DateTimeFormatters.formatRelativeTime(this);
  
  String toDurationString(DateTime endDate) => 
      DateTimeFormatters.formatTaskDuration(this, endDate);
}

// Usage examples class
class DateFormattingExamples {
  void demonstrateFormatting() {
    final now = DateTime.now();
    final comment = DateTime(2024, 3, 15, 14, 30);
    
    // Comment timestamp format (original request)
    print('Comment: ${DateFormat('MMM dd, yyyy HH:mm').format(comment)}');
    // Output: Comment: Mar 15, 2024 14:30
    
    // Using the formatter class
    print('Using formatter: ${DateTimeFormatters.commentTimestamp.format(comment)}');
    // Output: Using formatter: Mar 15, 2024 14:30
    
    // Using extension
    print('Using extension: ${comment.toCommentFormat()}');
    // Output: Using extension: Mar 15, 2024 14:30
    
    // Relative time example
    print('Relative time: ${DateTimeFormatters.formatRelativeTime(comment)}');
    // Output depends on current time, e.g.: Relative time: 2d ago
    
    // Duration example
    final endDate = comment.add(Duration(days: 2, hours: 3));
    print('Duration: ${DateTimeFormatters.formatTaskDuration(comment, endDate)}');
    // Output: Duration: 2d 3h
    
    // Localized example
    print('Localized (es): ${DateTimeFormatters.formatLocalizedDate(comment, 'es')}');
    // Output: 15 de marzo de 2024
    
    // Custom pattern
    print('Custom: ${DateTimeFormatters.formatCustomPattern(comment, 'EEEE, MMMM d, y')}');
    // Output: Friday, March 15, 2024
  }
}