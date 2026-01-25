import 'package:flutter/material.dart';
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
    return SingleChildScrollView(
      scrollDirection: Axis.horizontal,
      physics: const BouncingScrollPhysics(),
      child: Row(
        children: QrType.values.map((type) {
          final isSelected = type == selectedType;
          return Padding(
            padding: const EdgeInsets.only(right: 8.0),
            child: ChoiceChip(
              showCheckmark: false,
              avatar: Icon(
                _getIconForType(type),
                size: 18,
                color: isSelected 
                  ? Theme.of(context).colorScheme.onSecondaryContainer
                  : Theme.of(context).colorScheme.onSurfaceVariant,
              ),
              label: Text(type.label),
              selected: isSelected,
              onSelected: (selected) {
                if (selected) {
                  onTypeChanged(type);
                }
              },
              side: BorderSide.none,
              // Material 3 style is default for ChoiceChip usually, 
              // but we can enforce some nice colors if needed.
              backgroundColor: Theme.of(context).colorScheme.surfaceContainerHighest.withValues(alpha: 0.3),
              selectedColor: Theme.of(context).colorScheme.secondaryContainer,
              labelStyle: TextStyle(
                color: isSelected 
                    ? Theme.of(context).colorScheme.onSecondaryContainer
                    : Theme.of(context).colorScheme.onSurfaceVariant,
                fontWeight: isSelected ? FontWeight.bold : FontWeight.normal,
              ),
              padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
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
    }
  }
}
