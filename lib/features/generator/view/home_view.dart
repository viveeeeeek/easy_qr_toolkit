import 'package:easy_qr_toolkit/core/constants/app_constants.dart';
import 'package:easy_qr_toolkit/core/extensions/color_extension.dart';
import 'package:easy_qr_toolkit/core/extensions/sizedbox.dart';
import 'package:easy_qr_toolkit/core/utils/custom_snackbar.dart';
import 'package:easy_qr_toolkit/features/generator/generator_provider.dart';
import 'package:easy_qr_toolkit/features/scanner/view/qr_scan_view.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:pretty_qr_code/pretty_qr_code.dart';

import '../../../core/services/qr_service.dart';
import 'package:easy_qr_toolkit/features/settings/view/theme_settings_bottom_sheet.dart';
import 'widgets/generate_qr_textfield.dart';

class HomeView extends ConsumerStatefulWidget {
  const HomeView({super.key});

  @override
  ConsumerState<HomeView> createState() => _HomeViewState();
}

class _HomeViewState extends ConsumerState<HomeView> {
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: _buildAppBar(context),
      floatingActionButton: _buildFloatingActionButton(context),
      body: SingleChildScrollView(
        child: Padding(
          padding: const EdgeInsets.all(20.0),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              const Text(
                'Generate QR',
                style: TextStyle(fontSize: 28),
              ),
              30.h,
              const QRTextInputWidget(),
              50.h,
              _buildQrCodeView(context, ref),
            ],
          ),
        ),
      ),
    );
  }
}

Widget _buildQrCodeView(BuildContext context, WidgetRef ref) {
  final generatorState = ref.watch(generatorProvider);
  ref.read(generatorProvider.notifier);

  if (generatorState.data.isNotEmpty && generatorState.qrImageObject != null) {
    return Column(
      mainAxisSize: MainAxisSize.min,
      children: [
        Center(
          child: Container(
            height: MediaQuery.of(context).size.width * 0.8,
            width: MediaQuery.of(context).size.width * 0.65,
            decoration: BoxDecoration(
              borderRadius: BorderRadius.circular(16),
              color: context.primaryContainer.withValues(alpha: 0.5),
            ),
            child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                Center(
                  child: SizedBox(
                    height: MediaQuery.of(context).size.width * 0.48,
                    child: PrettyQrView(
                      qrImage: generatorState.qrImageObject!,
                      decoration: PrettyQrDecoration(
                        shape: PrettyQrSmoothSymbol(
                          color: context.onPrimaryContainer,
                          roundFactor: BorderSide.strokeAlignCenter,
                        ),
                      ),
                    ),
                  ),
                ),
              ],
            ),
          ),
        ),
        Row(
          mainAxisAlignment: MainAxisAlignment.end,
          children: [
            IconButton(
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
              icon: Icon(
                Icons.download_rounded,
                color: context.onPrimaryContainer,
              ),
            ),
            IconButton(
              onPressed: () {
                if (generatorState.generatedQrImage != null) {
                  ref
                      .read(qrServiceProvider)
                      .shareImage(generatorState.generatedQrImage!);
                }
              },
              icon: Icon(
                Icons.share_rounded,
                color: context.onPrimaryContainer,
              ),
            ),
            50.w
          ],
        )
      ],
    );
  } else {
    return const SizedBox();
  }
}

Widget _buildFloatingActionButton(BuildContext context) {
  return FloatingActionButton(
    onPressed: () {
      Navigator.push(
        context,
        MaterialPageRoute(
          builder: (context) => const QRScanView(),
        ),
      );
    },
    child: const Icon(Icons.qr_code_scanner_rounded),
  );
}

PreferredSizeWidget _buildAppBar(BuildContext context) {
  return AppBar(
    actions: [
      IconButton(
        onPressed: () {
          showModalBottomSheet(
            context: context,
            showDragHandle: true,
            isScrollControlled: true,
            builder: (context) => const ThemeSettingsBottomSheet(),
          );
        },
        icon: const Icon(Icons.palette_outlined),
      ),
      IconButton(
        onPressed: () {
          Navigator.pushNamed(context, AppRoutes.history);
        },
        icon: const Icon(Icons.history),
      ),
      IconButton(
        onPressed: () {
          showDialog(
            context: context,
            builder: (context) {
              return AlertDialog(
                title: const Text('About'),
                content: Column(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    CircleAvatar(
                      radius: 25,
                      backgroundColor: context.primary,
                      child: Icon(
                        Icons.person_2_outlined,
                        color: context.onPrimary,
                        size: 25,
                      ),
                    ),
                    20.h,
                    const Text('Made with <3 by VivekS.'),
                  ],
                ),
              );
            },
          );
        },
        icon: const Icon(Icons.more_vert_rounded),
      )
    ],
  );
}
