import 'package:intl/intl.dart';

class DateUtilsApp {
  static const List<String> thaiDaysShort = ['จ.', 'อ.', 'พ.', 'พฤ.', 'ศ.', 'ส.', 'อา.'];
  static const List<String> thaiDaysFull = [
    'วันจันทร์',
    'วันอังคาร',
    'วันพุธ',
    'วันพฤหัสบดี',
    'วันศุกร์',
    'วันเสาร์',
    'วันอาทิตย์',
  ];
  static const List<String> thaiMonthsShort = [
    'ม.ค.',
    'ก.พ.',
    'มี.ค.',
    'เม.ย.',
    'พ.ค.',
    'มิ.ย.',
    'ก.ค.',
    'ส.ค.',
    'ก.ย.',
    'ต.ค.',
    'พ.ย.',
    'ธ.ค.',
  ];
  static const List<String> thaiMonthsFull = [
    'มกราคม',
    'กุมภาพันธ์',
    'มีนาคม',
    'เมษายน',
    'พฤษภาคม',
    'มิถุนายน',
    'กรกฎาคม',
    'สิงหาคม',
    'กันยายน',
    'ตุลาคม',
    'พฤศจิกายน',
    'ธันวาคม',
  ];

  static String formatThaiDayShort(DateTime date) => thaiDaysShort[date.weekday - 1];
  static String formatThaiMonthShort(DateTime date) => thaiMonthsShort[date.month - 1];
  static String formatThaiMonthFull(DateTime date) => thaiMonthsFull[date.month - 1];

  static String formatThaiDateFull(DateTime date) {
    final dayName = thaiDaysFull[date.weekday - 1];
    final monthName = thaiMonthsFull[date.month - 1];
    final bYear = date.year + 543;
    return '$dayNameที่ ${date.day} $monthName $bYear';
  }

  static String formatThaiDateMedium(DateTime date) {
    final dayShort = thaiDaysShort[date.weekday - 1];
    final monthShort = thaiMonthsShort[date.month - 1];
    final bYear = date.year + 543;
    return '$dayShort ${date.day} $monthShort $bYear';
  }

  static String formatThaiDateShort(DateTime date) {
    final monthShort = thaiMonthsShort[date.month - 1];
    final bYear = date.year + 543;
    return '${date.day} $monthShort $bYear';
  }

  static String formatDate(DateTime date) {
    return DateFormat('dd/MM/yyyy').format(date);
  }

  static String formatDateTime(DateTime date) {
    return DateFormat('dd/MM/yyyy HH:mm').format(date);
  }

  static String formatTime(DateTime date) {
    return DateFormat('HH:mm').format(date);
  }

  static DateTime combineDateAndTime(DateTime date, String time) {
    final parts = time.split(':');
    final hour = int.parse(parts[0]);
    final minute = int.parse(parts[1]);
    return DateTime(date.year, date.month, date.day, hour, minute);
  }

  static bool isSameDay(DateTime a, DateTime b) {
    return a.year == b.year && a.month == b.month && a.day == b.day;
  }

  static bool isDateInPast(DateTime date) {
    final now = DateTime.now();
    final today = DateTime(now.year, now.month, now.day);
    final target = DateTime(date.year, date.month, date.day);
    return target.isBefore(today);
  }

  /// Checks if a booking date and time is in the past compared to current time.
  /// An optional [bufferMinutes] (e.g. 15 mins) ensures restaurants have prep time.
  static bool isBookingTimeInPast(DateTime date, String time, {int bufferMinutes = 0}) {
    final now = DateTime.now();
    final today = DateTime(now.year, now.month, now.day);
    final targetDate = DateTime(date.year, date.month, date.day);

    if (targetDate.isBefore(today)) {
      return true;
    }

    if (targetDate.isAfter(today)) {
      return false;
    }

    final parts = time.split(':');
    final hour = int.tryParse(parts[0]) ?? 0;
    final minute = int.tryParse(parts[1]) ?? 0;
    final targetDateTime = DateTime(now.year, now.month, now.day, hour, minute);

    return targetDateTime.isBefore(now.add(Duration(minutes: bufferMinutes)));
  }
}
