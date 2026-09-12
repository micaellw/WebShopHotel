import 'package:intl/intl.dart';

class FormatterUtils {
  static String formatCurrency(double amount) {
    return NumberFormat.currency(
      locale: 'th_TH',
      symbol: '฿',
      decimalDigits: 2,
    ).format(amount);
  }

  static String capitalize(String s) {
    if (s.isEmpty) return s;
    return s[0].toUpperCase() + s.substring(1);
  }
}
