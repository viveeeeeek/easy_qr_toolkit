
import 'dart:typed_data';
import 'package:easy_qr_toolkit/core/enums/qr_type.dart';
import 'package:easy_qr_toolkit/core/extensions/int.dart';
import 'package:easy_qr_toolkit/core/theme/m3_expressive.dart';
import 'package:easy_qr_toolkit/features/history/scan_data_model.dart';
import 'package:easy_qr_toolkit/features/scanner/view/widgets/result_data_section.dart';
import 'package:easy_qr_toolkit/features/scanner/view/widgets/smart_action_buttons.dart';
import 'package:material_ui/material_ui.dart';

class HistoryDetailsSheetContent extends StatelessWidget {
  final ScanDataModel item;
  final Function(Uint8List?, String) onViewQrCode;

  const HistoryDetailsSheetContent({
    super.key,
    required this.item,
    required this.onViewQrCode,
  });

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    return Container(
      decoration: BoxDecoration(
        color: theme.scaffoldBackgroundColor,
        borderRadius: const BorderRadius.vertical(top: Radius.circular(28)),
      ),
      child: SafeArea(
        child: Padding(
          padding: const EdgeInsets.fromLTRB(24, 12, 24, 24),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: [
              // Handle
              Center(
                child: Container(
                  width: 32,
                  height: 4,
                  margin: const EdgeInsets.only(bottom: 24),
                  decoration: BoxDecoration(
                    color: theme.colorScheme.onSurfaceVariant.withValues(alpha: 0.4),
                    borderRadius: BorderRadius.circular(2),
                  ),
                ),
              ),

              // Content
              Flexible(
                child: SingleChildScrollView(
                  physics: const BouncingScrollPhysics(),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.stretch,
                    children: [
                      // Type Badge
                      Center(
                        child: Container(
                          padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 4),
                          decoration: BoxDecoration(
                            color: theme.colorScheme.primary.withValues(alpha: 0.1),
                            borderRadius: BorderRadius.circular(20),
                          ),
                          child: Text(
                            QrType.fromString(item.type).scanLabel,
                            style: TextStyle(
                              color: theme.colorScheme.primary,
                              fontWeight: FontWeight.bold,
                              fontSize: 12,
                              letterSpacing: 1.2,
                            ),
                          ),
                        ),
                      ),
                      const SizedBox(height: 16),

                      ResultDataSection(content: item.content),
                      const SizedBox(height: 24),
                      SmartActionButtons(content: item.content, type: item.type),
                      const SizedBox(height: 24),

                      // View/Download QR Button
                      Center(
                        child: M3EButton.icon(
                          style: M3EButtonStyle.tonal,
                          size: M3EButtonSize.md,
                          onPressed: () => onViewQrCode(item.image, item.content),
                          icon: const Icon(Icons.qr_code_2_rounded),
                          label: const Text('View Original QR Code'),
                        ),
                      ),

                      const SizedBox(height: 24),
                      Center(
                        child: Text(
                          DateTime.fromMillisecondsSinceEpoch(item.date).formattedDateTime,
                          style: TextStyle(
                            color: theme.colorScheme.outline,
                            fontSize: 12,
                          ),
                        ),
                      ),
                    ],
                  ),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
