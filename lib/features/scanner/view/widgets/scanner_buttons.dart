import 'package:easy_qr_toolkit/core/theme/m3_expressive.dart';
import 'package:material_ui/material_ui.dart';
import 'package:mobile_scanner/mobile_scanner.dart';

/// Scan Gallery Image Button
class ScanGalleryImgButton extends StatelessWidget {
  const ScanGalleryImgButton(
      {required this.controller, super.key, required this.onBarcodeFound});

  final MobileScannerController controller;
  final void Function() onBarcodeFound;

  @override
  Widget build(BuildContext context) {
    return M3EIconButton(
      variant: M3EIconButtonVariant.tonal,
      icon: const Icon(Icons.image_rounded),
      tooltip: 'Scan Image',
      onPressed: onBarcodeFound,
    );
  }
}

/// Toggle Flashlight Button
///
/// Uses [ValueListenableBuilder] to listen directly to the ephemeral camera
/// [MobileScannerController] notifications. This isolates flashlight state
/// rebuilds to this widget alone without triggering broader tree rebuilds
/// or duplicating camera platform channel events in global Riverpod state.
class ToggleFlashlightButton extends StatelessWidget {
  const ToggleFlashlightButton({required this.controller, super.key});

  final MobileScannerController controller;

  @override
  Widget build(BuildContext context) {
    return ValueListenableBuilder<MobileScannerState>(
      valueListenable: controller,
      builder: (context, state, child) {
        final isTorchOn = state.torchState == TorchState.on;

        return M3EIconButton(
          variant: isTorchOn
              ? M3EIconButtonVariant.filled
              : M3EIconButtonVariant.tonal,
          icon: Icon(
            isTorchOn ? Icons.flash_on_rounded : Icons.flash_off_rounded,
          ),
          tooltip: isTorchOn ? 'Turn Flash Off' : 'Turn Flash On',
          onPressed: () async {
            try {
              await controller.toggleTorch();
            } catch (_) {}
          },
        );
      },
    );
  }
}
