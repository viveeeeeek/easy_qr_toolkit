import 'package:easy_qr_toolkit/core/theme/m3_expressive.dart';
import 'package:material_ui/material_ui.dart';
import '../../../../core/enums/qr_type.dart';

class QrTypeSelector extends StatelessWidget {
  const QrTypeSelector({
    super.key,
    required this.selectedType,
    required this.onTypeChanged,
  });

  final QrType selectedType;
  final ValueChanged<QrType> onTypeChanged;

  @override
  Widget build(BuildContext context) {
    // Only show types that have generation forms
    final generatableTypes =
        QrType.values.where((type) => type.isGeneratable).toList();

    return SingleChildScrollView(
      scrollDirection: Axis.horizontal,
      physics: const BouncingScrollPhysics(),
      child: Row(
        children: generatableTypes.map((type) {
          final isSelected = type == selectedType;
          return Padding(
            padding: const EdgeInsets.only(right: 8.0),
            child: M3EChip(
              label: type.label,
              type: M3EChipType.filter,
              selected: isSelected,
              leading: Icon(_getIconForType(type), size: 18),
              onPressed: () => onTypeChanged(type),
            ),
          );
        }).toList(),
      ),
    );
  }

  IconData _getIconForType(QrType type) {
    switch (type) {
      case QrType.text:
        return Icons.text_fields_rounded;
      case QrType.wifi:
        return Icons.wifi_rounded;
      case QrType.contact:
        return Icons.person_rounded;
      // Default for non-generatable types (shouldn't be reached due to filter)
      default:
        return Icons.qr_code_rounded;
    }
  }
}
