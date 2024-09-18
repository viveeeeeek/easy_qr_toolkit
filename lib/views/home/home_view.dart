import 'dart:developer';

import 'package:easy_qr_toolkit/core/extensions/color_extension.dart';
import 'package:easy_qr_toolkit/core/extensions/sizedbox.dart';
import 'package:easy_qr_toolkit/core/services/database_service.dart';
import 'package:easy_qr_toolkit/core/utils/custom_snackbar.dart';
import 'package:easy_qr_toolkit/providers/qr_data_provider.dart';
import 'package:easy_qr_toolkit/view_models/home_viewmodel.dart';
import 'package:easy_qr_toolkit/views/qr_scan/qr_scan_view.dart';
import 'package:flutter/material.dart';
import 'package:pretty_qr_code/pretty_qr_code.dart';
import 'package:provider/provider.dart';
import 'package:share_plus/share_plus.dart';

import 'widgets/widgets.dart';

class HomeView extends StatefulWidget {
  const HomeView({super.key});

  @override
  _HomeViewState createState() => _HomeViewState();
}

class _HomeViewState extends State<HomeView> {
  final homeViewModel = HomeViewModel();
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
                // Show QR Code if generated
                _buildQrCodeView(context, homeViewModel)
              ],
            ),
          ),
        ));
  }
}

_buildQrCodeView(BuildContext context, HomeViewModel homeViewModel) {
  return Consumer<QrDataProvider>(
    builder: (context, qrDataProvider, child) {
      if (qrDataProvider.generatedQrCode.isNotEmpty &&
          qrDataProvider.qrImageObject != null) {
        return Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Center(
              child: Container(
                height: MediaQuery.of(context).size.width * 0.8,
                width: MediaQuery.of(context).size.width * 0.65,
                decoration: BoxDecoration(
                  borderRadius: BorderRadius.circular(16),
                  color: context.primaryContainer.withOpacity(0.5),
                ),
                child: Column(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    Center(
                      child: SizedBox(
                        height: MediaQuery.of(context).size.width * 0.48,
                        child: PrettyQrView(
                          qrImage: qrDataProvider.qrImageObject!,
                          decoration: PrettyQrDecoration(
                            shape: PrettyQrSmoothSymbol(
                                color: context.onPrimaryContainer,
                                roundFactor: BorderSide.strokeAlignCenter),
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
                    onPressed: () => homeViewModel
                            .saveQrToGallery(qrDataProvider.generatedQrImage!)
                            .whenComplete(() {
                          if (context.mounted)
                            showSnackBar(
                              context: context,
                              message: 'QR Code saved to gallery',
                            );
                        }),
                    icon: Icon(
                      Icons.download_rounded,
                      color: context.onPrimaryContainer,
                    )),
                IconButton(
                    onPressed: () => homeViewModel
                        .shareImageAsBytes(qrDataProvider.generatedQrImage!),
                    icon: Icon(
                      Icons.share_rounded,
                      color: context.onPrimaryContainer,
                    )),
                50.w
              ],
            )
          ],
        );
      } else {
        return const SizedBox();
      }
    },
  );
}

/// Builds the floating action button.
_buildFloatingActionButton(BuildContext context) {
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

/// Builds the app bar.
_buildAppBar(BuildContext context) {
  return AppBar(
    // leading:
    //     IconButton(onPressed: () {}, icon: const Icon(Icons.settings)),
    // title: const Text("Easy QR Toolkit"),
    actions: [
      IconButton(
          onPressed: () {
            Navigator.pushNamed(context, '/scan_history');
          },
          icon: const Icon(Icons.history)),
      IconButton(
          onPressed: () {
            // simple dialog giving credits to the developer
            showDialog(
                context: context,
                builder: (context) {
                  return AlertDialog(
                      title: const Text('About'),
                      content:
                          Column(mainAxisSize: MainAxisSize.min, children: [
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
                      ]));
                });
          },
          icon: const Icon(Icons.more_vert_rounded))
    ],
  );
}
