import 'package:easy_qr_toolkit/core/extensions/color_extension.dart';
import 'package:easy_qr_toolkit/core/extensions/sizedbox.dart';
import 'package:easy_qr_toolkit/core/services/qr_service.dart';
import 'package:easy_qr_toolkit/core/theme/m3_expressive.dart';
import 'package:easy_qr_toolkit/core/utils/custom_snackbar.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:material_ui/material_ui.dart';
import 'package:pretty_qr_code/pretty_qr_code.dart';

import '../../generator_provider.dart';
import 'qr_customization_sheet.dart';

class GeneratedQRCard extends ConsumerStatefulWidget {
  const GeneratedQRCard({super.key, this.isCompact = false});

  final bool isCompact;

  @override
  ConsumerState<GeneratedQRCard> createState() => _GeneratedQRCardState();
}

class _GeneratedQRCardState extends ConsumerState<GeneratedQRCard> {
  bool _isSaving = false;
  bool _isSharing = false;

  @override
  Widget build(BuildContext context) {
    // Use selectors to minimize rebuilds - only rebuild when these specific fields change
    final qrImageObject =
        ref.watch(generatorProvider.select((s) => s.qrImageObject));
    final data = ref.watch(generatorProvider.select((s) => s.data));
    final shape = ref.watch(generatorProvider.select((s) => s.shape));
    final qrColor = ref.watch(generatorProvider.select((s) => s.qrColor));
    final logo = ref.watch(generatorProvider.select((s) => s.logo));
    final logoScale = ref.watch(generatorProvider.select((s) => s.logoScale));
    final qrService = ref.watch(qrServiceProvider);

    final isCompact = widget.isCompact;

    if (data.isEmpty) {
      return const SizedBox.shrink();
    }

    return RepaintBoundary(
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          M3ECard(
            variant: M3ECardVariant.elevated,
            color: Colors.white,
            elevation: 3,
            padding: EdgeInsets.all(isCompact ? 16 : 24),
            borderRadius: BorderRadius.circular(28),
            child: Column(
              children: [
                AnimatedContainer(
                  duration: const Duration(milliseconds: 300),
                  curve: Curves.easeOutCubic,
                  width: isCompact ? 120 : 220,
                  height: isCompact ? 120 : 220,
                  child: RepaintBoundary(
                    child: qrImageObject != null
                        ? PrettyQrView(
                            qrImage: qrImageObject,
                            decoration: qrService.getDecoration(
                              shape,
                              qrColor,
                              logo,
                              logoScale,
                            ),
                          )
                        : Center(
                            child: Padding(
                              padding: const EdgeInsets.all(16.0),
                              child: Column(
                                mainAxisAlignment: MainAxisAlignment.center,
                                children: [
                                  Icon(
                                    Icons.warning_amber_rounded,
                                    size: 36,
                                    color: Theme.of(context).colorScheme.error,
                                  ),
                                  const SizedBox(height: 8),
                                  Text(
                                    'Input too long for QR',
                                    textAlign: TextAlign.center,
                                    style: Theme.of(context)
                                        .textTheme
                                        .bodySmall
                                        ?.copyWith(
                                          color: Theme.of(context)
                                              .colorScheme
                                              .error,
                                        ),
                                  ),
                                ],
                              ),
                            ),
                          ),
                  ),
                ),
              ],
            ),
          ),
          SizedBox(height: isCompact ? 16 : 24),
          FittedBox(
            fit: BoxFit.scaleDown,
            child: Row(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                M3EButton.icon(
                  style: M3EButtonStyle.filled,
                  size: isCompact ? M3EButtonSize.sm : M3EButtonSize.md,
                  onPressed: (qrImageObject == null || _isSaving)
                      ? null
                      : _handleSave,
                  icon: _isSaving
                      ? const SizedBox(
                          width: 16,
                          height: 16,
                          child: CircularProgressIndicator(
                            strokeWidth: 2,
                            color: Colors.white,
                          ),
                        )
                      : const Icon(Icons.download_rounded, size: 20),
                  label: Text(_isSaving ? 'Saving...' : 'Save'),
                ),
                const SizedBox(width: 8),
                M3EButton.icon(
                  style: M3EButtonStyle.tonal,
                  size: isCompact ? M3EButtonSize.sm : M3EButtonSize.md,
                  onPressed: qrImageObject == null
                      ? null
                      : () => _showCustomizationSheet(context),
                  icon: const Icon(Icons.tune_rounded, size: 20),
                  label: const Text('Customize'),
                ),
                const SizedBox(width: 8),
                M3EIconButton(
                  variant: M3EIconButtonVariant.tonal,
                  size: isCompact ? M3EIconButtonSize.sm : M3EIconButtonSize.md,
                  onPressed: (qrImageObject == null || _isSharing)
                      ? null
                      : _handleShare,
                  icon: _isSharing
                      ? SizedBox(
                          width: 16,
                          height: 16,
                          child: CircularProgressIndicator(
                            strokeWidth: 2,
                            color: context.primary,
                          ),
                        )
                      : const Icon(Icons.share_rounded),
                  tooltip: 'Share QR Code',
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Future<void> _handleSave() async {
    // Dismiss keyboard
    FocusManager.instance.primaryFocus?.unfocus();
    
    setState(() => _isSaving = true);
    try {
      final exportImage = await ref
          .read(generatorProvider.notifier)
          .ensureExportImage();
      if (exportImage != null && mounted) {
        final success = await ref
            .read(qrServiceProvider)
            .saveToGallery(exportImage);
        if (success && mounted) {
          showSnackBar(
            context: context,
            message: 'QR Code saved to gallery',
          );
        }
      }
    } finally {
      if (mounted) {
        setState(() => _isSaving = false);
      }
    }
  }

  Future<void> _handleShare() async {
    if (_isSharing) return;
    setState(() => _isSharing = true);
    try {
      final exportImage = await ref
          .read(generatorProvider.notifier)
          .ensureExportImage();
      if (exportImage != null) {
        ref
            .read(qrServiceProvider)
            .shareImage(
              exportImage,
              caption: 'Generated with Easy QR Toolkit\nhttps://play.google.com/store/apps/details?id=com.billionants.easy_qr_toolkit',
            );
      }
    } finally {
      if (mounted) {
        setState(() => _isSharing = false);
      }
    }
  }

  Future<void> _showCustomizationSheet(BuildContext context) async {
    FocusManager.instance.primaryFocus?.unfocus();
    await showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      showDragHandle: true,
      backgroundColor: Theme.of(context).scaffoldBackgroundColor,
      builder: (context) => const QrCustomizationSheet(),
    );
  }
}
