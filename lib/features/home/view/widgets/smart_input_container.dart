import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../../../core/enums/qr_type.dart';
import 'forms/form_widgets.dart';
import 'generate_qr_textfield.dart';

class SmartInputContainer extends ConsumerWidget {
  const SmartInputContainer({
    super.key,
    required this.selectedType,
    this.focusNode,
    this.onTypingStateChanged,
  });

  final QrType selectedType;
  final FocusNode? focusNode;
  final ValueChanged<bool>? onTypingStateChanged;

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    return _buildInputCard(selectedType);
  }

  Widget _buildInputCard(QrType type) {
    // Unique keys ensure state is reset/rebuilt when switching types
    switch (type) {
      case QrType.text:
        return ModernQRInputCard(
          key: const ValueKey('text_input'),
          focusNode: focusNode,
          onTypingStateChanged: onTypingStateChanged,
        );
      case QrType.wifi:
        return WifiQrFormWidget(
          key: const ValueKey('wifi_input'),
          focusNode: focusNode,
          onTypingStateChanged: onTypingStateChanged,
        );
      case QrType.contact:
        return ContactQrFormWidget(
          key: const ValueKey('contact_input'),
          focusNode: focusNode,
          onTypingStateChanged: onTypingStateChanged,
        );
      // For non-generatable types (url, geo, other), fall back to text input
      default:
        return ModernQRInputCard(
          key: const ValueKey('text_input'),
          focusNode: focusNode,
          onTypingStateChanged: onTypingStateChanged,
        );
    }
  }
}
