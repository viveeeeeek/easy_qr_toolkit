import 'package:easy_qr_toolkit/core/extensions/color_extension.dart';
import 'package:easy_qr_toolkit/core/extensions/sizedbox.dart';
import 'package:easy_qr_toolkit/core/services/qr_service.dart';
import 'package:easy_qr_toolkit/core/utils/custom_snackbar.dart';
import 'package:easy_qr_toolkit/features/generator/generator_provider.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:pretty_qr_code/pretty_qr_code.dart';

class GeneratedQRCard extends ConsumerWidget {
  const GeneratedQRCard({super.key, this.isCompact = false});

  final bool isCompact;

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final generatorState = ref.watch(generatorProvider);
    final qrService = ref.watch(qrServiceProvider);

    if (generatorState.data.isEmpty) {
      return const SizedBox.shrink();
    }

    return Column(
      mainAxisSize: MainAxisSize.min,
      children: [
        AnimatedContainer(
          duration: const Duration(milliseconds: 300),
          curve: Curves.easeInOut,
          padding: EdgeInsets.all(isCompact ? 16 : 24),
          decoration: BoxDecoration(
            color: Colors.white,
            borderRadius: BorderRadius.circular(24),
            boxShadow: [
              BoxShadow(
                color: Colors.black.withOpacity(0.1),
                blurRadius: 20,
                offset: const Offset(0, 10),
              ),
            ],
          ),
          child: Column(
            children: [
              AnimatedSize(
                duration: const Duration(milliseconds: 300),
                curve: Curves.easeInOut,
                child: SizedBox(
                  width: isCompact ? 120 : 220,
                  height: isCompact ? 120 : 220,
                  child: PrettyQrView.data(
                    data: generatorState.data,
                    decoration: qrService.getDecoration(
                      generatorState.shape,
                      generatorState.qrColor,
                      generatorState.logo,
                    ),
                  ),
                ),
              ),
            ],
          ),
        ),
        SizedBox(height: isCompact ? 16 : 24),
        AnimatedContainer(
          duration: const Duration(milliseconds: 300),
          height: isCompact ? 40 : 56,
          // Shrink button height slightly or just keep regular
          child: Row(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              FilledButton.icon(
                onPressed: () async {
                  if (generatorState.generatedQrImage != null) {
                    final success = await ref
                        .read(qrServiceProvider)
                        .saveToGallery(generatorState.generatedQrImage!);
                    if (success && context.mounted) {
                      showSnackBar(
                        context: context,
                        message: 'QR Code saved to gallery',
                      );
                    }
                  }
                },
                icon: const Icon(Icons.download_rounded, size: 20),
                label: const Text('Save'),
                style: FilledButton.styleFrom(
                  padding: EdgeInsets.symmetric(
                      horizontal: isCompact ? 16 : 24,
                      vertical: isCompact ? 0 : 16),
                  visualDensity: isCompact
                      ? VisualDensity.compact
                      : VisualDensity.standard,
                ),
              ),
              const SizedBox(width: 16),
              FilledButton.tonalIcon(
                onPressed: () {
                  if (generatorState.generatedQrImage != null) {
                    ref
                        .read(qrServiceProvider)
                        .shareImage(generatorState.generatedQrImage!);
                  }
                },
                icon: const Icon(Icons.share_rounded, size: 20),
                label: const Text('Share'),
                style: FilledButton.styleFrom(
                  padding: EdgeInsets.symmetric(
                      horizontal: isCompact ? 16 : 24,
                      vertical: isCompact ? 0 : 16),
                  visualDensity: isCompact
                      ? VisualDensity.compact
                      : VisualDensity.standard,
                ),
              ),
            ],
          ),
        )
      ],
    );
  }
}
