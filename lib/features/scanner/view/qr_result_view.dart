import 'package:easy_qr_toolkit/core/enums/scan_type.dart';
import 'package:easy_qr_toolkit/features/scanner/provider/scanner_provider.dart';

import 'package:easy_qr_toolkit/features/scanner/view/widgets/result_data_section.dart';
import 'package:easy_qr_toolkit/features/scanner/view/widgets/result_action_buttons.dart';
import 'package:easy_qr_toolkit/features/scanner/view/widgets/smart_action_buttons.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import 'package:easy_qr_toolkit/features/scanner/view/qr_scan_view.dart';
import '../../../core/extensions/sizedbox.dart';

class QRResultView extends ConsumerWidget {
  const QRResultView({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final state = ref.watch(scannerProvider);
    final colorScheme = Theme.of(context).colorScheme;

    return Scaffold(
      appBar: AppBar(
        title: const Text('Scan Result'),
        centerTitle: true,
      ),
      body: SafeArea(
        child: Padding(
          padding: const EdgeInsets.symmetric(horizontal: 24.0, vertical: 40),
          child: Column(
            children: [
              const Spacer(),

              // The Main Result Card
              Container(
                width: double.infinity,
                padding: const EdgeInsets.all(20),
                decoration: BoxDecoration(
                  color: colorScheme.surfaceContainerHighest.withOpacity(0.5),
                  borderRadius: BorderRadius.circular(28),
                  border: Border.all(
                    color: colorScheme.outlineVariant.withOpacity(0.5),
                  ),
                ),
                child: Column(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    // A badge showing the type
                    Container(
                      padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 4),
                      decoration: BoxDecoration(
                        color: colorScheme.primary.withOpacity(0.1),
                        borderRadius: BorderRadius.circular(20),
                      ),
                      child: Text(
                        ScanType.fromString(state.scannedType).label,
                        style: TextStyle(
                          color: colorScheme.primary,
                          fontWeight: FontWeight.bold,
                          fontSize: 12,
                          letterSpacing: 1.2,
                        ),
                      ),
                    ),
                    10.h,
                    // The Data Section
                    ResultDataSection(content: state.scannedData),
                    
                    // Primary Smart Actions (Large, interactive)
                    SmartActionButtons(
                      content: state.scannedData,
                      type: state.scannedType,
                    ),
                    


                    // Utility Actions (Copy/Share)
                    const Divider(height: 32),
                    ResultActionButtons(
                      content: state.scannedData,
                      onScanAgain: () {
                        Navigator.pushReplacement(
                          context,
                          MaterialPageRoute(
                              builder: (context) => const QRScanView()),
                        );
                      },
                    ),
                  ],
                ),
              ),

              const Spacer(),
            ],
          ),
        ),
      ),
    );
  }
}
