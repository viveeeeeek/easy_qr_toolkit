import 'package:easy_qr_toolkit/features/scanner/scanner_provider.dart';
import 'package:easy_qr_toolkit/features/scanner/view/widgets/result_image_card.dart';
import 'package:easy_qr_toolkit/features/scanner/view/widgets/result_data_section.dart';
import 'package:easy_qr_toolkit/features/scanner/view/widgets/result_action_buttons.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

class QRResultWidget extends ConsumerWidget {
  const QRResultWidget({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final state = ref.watch(scannerProvider);

    return Padding(
      padding: const EdgeInsets.all(25.0),
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          if (state.scannedImage != null)
            ResultImageCard(imageBytes: state.scannedImage!),
          
          ResultDataSection(content: state.scannedData),
          
          ResultActionButtons(
            content: state.scannedData,
            onScanAgain: () => ref.read(scannerProvider.notifier).reset(),
          ),
        ],
      ),
    );
  }
}
