import 'package:easy_qr_toolkit/core/extensions/color_extension.dart';
import 'package:easy_qr_toolkit/core/extensions/sizedbox.dart';
import 'package:easy_qr_toolkit/core/services/qr_service.dart';
import 'package:easy_qr_toolkit/core/utils/custom_snackbar.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:pretty_qr_code/pretty_qr_code.dart';

import '../../generator_provider.dart';

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
    final qrImageObject = ref.watch(generatorProvider.select((s) => s.qrImageObject));
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
          AnimatedContainer(
            duration: const Duration(milliseconds: 300),
            curve: Curves.easeInOut,
            padding: EdgeInsets.all(isCompact ? 16 : 24),
            decoration: BoxDecoration(
              color: Colors.white,
              borderRadius: BorderRadius.circular(24),
              boxShadow: [
                BoxShadow(
                  color: Colors.black.withValues(alpha:0.08),
                  blurRadius: 12,
                  offset: const Offset(0, 8),
                ),
              ],
            ),
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
                        : PrettyQrView.data(
                            data: data,
                            decoration: qrService.getDecoration(
                              shape,
                              qrColor,
                              logo,
                              logoScale,
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
            child: Row(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                FilledButton.icon(
                  onPressed: _isSaving ? null : _handleSave,
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
                  onPressed: _isSharing ? null : _handleShare,
                  icon: _isSharing
                      ? SizedBox(
                          width: 16,
                          height: 16,
                          child: CircularProgressIndicator(
                            strokeWidth: 2,
                            color: context.primary,
                          ),
                        )
                      : const Icon(Icons.share_rounded, size: 20),
                  label: Text(_isSharing ? 'Preparing...' : 'Share'),
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
}
