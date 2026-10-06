import 'package:bani/l10n/l10n.dart';

// ─────────────────────────────────────────────────────────────────────────────
//  Date + text helpers (no intl locale data needed)
// ─────────────────────────────────────────────────────────────────────────────

const _months = [
  'Januari', 'Februari', 'Maret', 'April', 'Mei', 'Juni',
  'Juli', 'Agustus', 'September', 'Oktober', 'November', 'Desember',
];

const _monthsEn = [
  'January', 'February', 'March', 'April', 'May', 'June',
  'July', 'August', 'September', 'October', 'November', 'December',
];

/// "12 Maret 1972" / "12 March 1972", or "1972" when only the year is known.
String formatDate(DateTime? d, {bool yearOnly = false}) {
  if (d == null) return '';
  if (yearOnly) return '${d.year}';
  final months = isEnglish ? _monthsEn : _months;
  return '${d.day} ${months[d.month - 1]} ${d.year}';
}

const _days = ['Senin', 'Selasa', 'Rabu', 'Kamis', 'Jumat', 'Sabtu', 'Minggu'];
const _daysEn = [
  'Monday', 'Tuesday', 'Wednesday', 'Thursday', 'Friday', 'Saturday', 'Sunday',
];

String _dayName(DateTime d) => (isEnglish ? _daysEn : _days)[d.weekday - 1];

/// "Oktober" / "October".
String monthName(DateTime d) => (isEnglish ? _monthsEn : _months)[d.month - 1];

/// "Okt" / "Oct".
String monthShort(DateTime d) =>
    (isEnglish ? _monthsEn : _months)[d.month - 1].substring(0, 3);

/// "Sabtu, 24 Oktober 2026".
String formatDayDate(DateTime d) => '${_dayName(d)}, ${formatDate(d)}';

/// "Sab, 24 Okt".
String formatShortDay(DateTime d) =>
    '${_dayName(d).substring(0, 3)}, ${d.day} ${monthShort(d)}';

/// "09.00" (Indonesian) / "09:00".
String formatTime(DateTime d) {
  final sep = isEnglish ? ':' : '.';
  return '${d.hour.toString().padLeft(2, '0')}$sep${d.minute.toString().padLeft(2, '0')}';
}

/// Parses legacy strings like "Kediri, 01 Januari 1945" or "1945".
({String? place, DateTime? date, bool yearOnly}) parseLegacyDob(String? raw) {
  if (raw == null || raw.trim().isEmpty) {
    return (place: null, date: null, yearOnly: false);
  }
  var text = raw.trim();
  String? place;
  final comma = text.indexOf(',');
  if (comma > 0) {
    place = text.substring(0, comma).trim();
    text = text.substring(comma + 1).trim();
  }
  final parts = text.split(RegExp(r'\s+'));
  if (parts.length == 3) {
    final day = int.tryParse(parts[0]);
    final month = _months.indexWhere(
            (m) => m.toLowerCase() == parts[1].toLowerCase()) +
        1;
    final year = int.tryParse(parts[2]);
    if (day != null && month > 0 && year != null) {
      return (place: place, date: DateTime(year, month, day), yearOnly: false);
    }
  }
  final year = int.tryParse(parts.last);
  if (year != null) return (place: place, date: DateTime(year), yearOnly: true);
  return (place: place ?? raw, date: null, yearOnly: false);
}

String initialOf(String name) =>
    name.trim().isEmpty ? '?' : name.trim()[0].toUpperCase();

/// Keeps only digits and converts a leading 0 to the Indonesian country code.
String normalizePhone(String raw) {
  var digits = raw.replaceAll(RegExp(r'[^0-9]'), '');
  if (digits.startsWith('0')) digits = '62${digits.substring(1)}';
  return digits;
}

String formatRupiah(int amount) {
  final s = amount.toString();
  final buf = StringBuffer();
  for (var i = 0; i < s.length; i++) {
    if (i > 0 && (s.length - i) % 3 == 0) buf.write('.');
    buf.write(s[i]);
  }
  return 'Rp$buf';
}
