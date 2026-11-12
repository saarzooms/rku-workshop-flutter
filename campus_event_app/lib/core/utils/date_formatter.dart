import 'package:intl/intl.dart';

class DateFormatter {
  DateFormatter._();

  static String formatDateTime(String? raw) {
    if (raw == null || raw.isEmpty) return 'TBD';
    final parsed = DateTime.tryParse(raw.replaceAll(' ', 'T'));
    if (parsed == null) return raw;
    return DateFormat('EEE, dd MMM yyyy • hh:mm a').format(parsed);
  }

  static String formatShortDate(String? raw) {
    if (raw == null || raw.isEmpty) return 'TBD';
    final parsed = DateTime.tryParse(raw.replaceAll(' ', 'T'));
    if (parsed == null) return raw;
    return DateFormat('dd MMM, hh:mm a').format(parsed);
  }
}
