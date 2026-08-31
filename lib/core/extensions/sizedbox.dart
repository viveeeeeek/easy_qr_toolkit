import 'package:material_ui/material_ui.dart';

extension spacer on int {
  SizedBox get h => SizedBox(height: toDouble());
  SizedBox get w => SizedBox(width: toDouble());
}
