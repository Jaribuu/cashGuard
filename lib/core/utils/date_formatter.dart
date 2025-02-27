import 'package:intl/intl.dart';

class DateFormatter {
  // Private constructor to prevent instantiation
  DateFormatter._();

  static final DateFormat _shortDateFormat = DateFormat('MM/dd/yyyy');
  static final DateFormat _fullDateFormat = DateFormat('EEEE, MMMM d, yyyy');
  static final DateFormat _monthYearFormat = DateFormat('MMMM yyyy');
  static final DateFormat _timeFormat = DateFormat('h:mm a');
  static final DateFormat _dateTimeFormat = DateFormat('MM/dd/yyyy h:mm a');

  // Format date to short date (MM/DD/YYYY)
  static String toShortDate(DateTime date) {
    return _shortDateFormat.format(date);
  }

  // Format date to full date (Monday, January 1, 2023)
  static String toFullDate(DateTime date) {
    return _fullDateFormat.format(date);
  }

  // Format date to month and year (January 2023)
  static String toMonthYear(DateTime date) {
    return _monthYearFormat.format(date);
  }

  // Format time (1:30 PM)
  static String toTime(DateTime dateTime) {
    return _timeFormat.format(dateTime);
  }

  // Format date and time (MM/DD/YYYY 1:30 PM)
  static String toDateTime(DateTime dateTime) {
    return _dateTimeFormat.format(dateTime);
  }

  // Get start date of month
  static DateTime getStartOfMonth(DateTime date) {
    return DateTime(date.year, date.month, 1);
  }

  // Get end date of month
  static DateTime getEndOfMonth(DateTime date) {
    return DateTime(date.year, date.month + 1, 0);
  }

  // Check if a date is today
  static bool isToday(DateTime date) {
    final now = DateTime.now();
    return date.year == now.year && date.month == now.month && date.day == now.day;
  }

  // Get a list of months for dropdown
  static List<String> getMonthsList() {
    List<String> months = [];
    final now = DateTime.now();
    for (int i = 0; i < 12; i++) {
      final date = DateTime(now.year, i + 1);
      months.add(DateFormat('MMMM').format(date));
    }
    return months;
  }
}