import 'package:intl/intl.dart';

extension DateExtension on int {
  DateTime get toDateTime =>
      DateTime.fromMillisecondsSinceEpoch(this).toLocal();
}

extension DateTimeFormatExtension on DateTime {
  String get formattedDateTime => DateFormat.yMMMd().add_jm().format(this);
}
