import 'package:easy_qr_toolkit/core/constants/app_constants.dart';
import 'package:easy_qr_toolkit/core/theme/m3_expressive.dart';
import 'package:easy_qr_toolkit/features/scanner/view/widgets/scanner_buttons.dart';
import 'package:material_ui/material_ui.dart';
import 'package:mobile_scanner/mobile_scanner.dart';

class ScannerAppBar extends StatelessWidget implements PreferredSizeWidget {
  final MobileScannerController controller;
  final VoidCallback onGalleryTap;

  const ScannerAppBar({
    super.key,
    required this.controller,
    required this.onGalleryTap,
  });

  @override
  Widget build(BuildContext context) {
    return AppBar(
      backgroundColor: Colors.transparent,
      elevation: 0,
      title: const Text("Scan QR Code"),
      actions: [
        ToggleFlashlightButton(controller: controller),
        const SizedBox(width: 4),
        ScanGalleryImgButton(
          controller: controller,
          onBarcodeFound: onGalleryTap,
        ),
        const SizedBox(width: 12),
      ],
      leading: Padding(
        padding: const EdgeInsets.only(left: 8.0),
        child: M3EIconButton(
          variant: M3EIconButtonVariant.tonal,
          onPressed: () {
            if (Navigator.canPop(context)) {
              Navigator.pop(context);
            } else {
              Navigator.pushReplacementNamed(context, AppRoutes.home);
            }
          },
          icon: const Icon(Icons.close_rounded),
          tooltip: 'Close',
        ),
      ),
    );
  }

  @override
  Size get preferredSize => const Size.fromHeight(kToolbarHeight);
}
