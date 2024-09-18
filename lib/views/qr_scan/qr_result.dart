import 'package:easy_qr_toolkit/core/extensions/sizedbox.dart';
import 'package:easy_qr_toolkit/providers/qr_data_provider.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:provider/provider.dart';
import 'package:share_plus/share_plus.dart';

class QRResult extends StatelessWidget {
  const QRResult({
    super.key,
  });

  @override
  Widget build(BuildContext context) {
    return Consumer<QrDataProvider>(
      builder: (context, qrDataProvider, child) {
        return Padding(
          padding: const EdgeInsets.all(25.0),
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              ClipRRect(
                borderRadius: BorderRadius.circular(15),
                child: SizedBox(
                  width: 200,
                  height: 200,
                  child: Image(
                    image: MemoryImage(qrDataProvider.qrImage!),
                    fit: BoxFit.cover,
                  ),
                ),
              ),
              50.h,
              Text(
                qrDataProvider.scannedQRData,
                style: const TextStyle(fontSize: 20),
              ),
              20.h,
              const Divider(
                indent: 25,
                endIndent: 25,
              ),
              Row(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  IconButton(
                    icon: const Icon(Icons.copy),
                    onPressed: () async {
                      // Copy the scanned QR data to the clipboard
                      Clipboard.setData(
                          ClipboardData(text: qrDataProvider.scannedQRData));
                    },
                  ),
                  const SizedBox(width: 10),
                  IconButton(
                    icon: const Icon(Icons.share),
                    onPressed: () {
                      // Share the scanned QR data
                      Share.share(qrDataProvider.scannedQRData);
                    },
                  ),
                ],
              ),
              const SizedBox(
                height: 20,
              ),
              FilledButton(
                onPressed: () {
                  final QrDataProvider qrDataProvider =
                      Provider.of<QrDataProvider>(context, listen: false);
                  qrDataProvider.setScannedQrValue('');
                },
                child: const Text('Scan Again'),
              ),
            ],
          ),
        );
      },
    );
  }
}
