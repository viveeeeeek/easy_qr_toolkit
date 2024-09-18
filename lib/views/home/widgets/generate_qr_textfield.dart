import 'dart:ui';

import 'package:easy_qr_toolkit/providers/qr_data_provider.dart';
import 'package:flutter/material.dart';
import 'package:pretty_qr_code/pretty_qr_code.dart';
import 'package:provider/provider.dart';

class QRTextInputWidget extends StatefulWidget {
  const QRTextInputWidget({
    super.key,
  });

  @override
  State<QRTextInputWidget> createState() => _QRTextInputWidgetState();
}

class _QRTextInputWidgetState extends State<QRTextInputWidget> {
  final TextEditingController _controller = TextEditingController();
  @override
  Widget build(BuildContext context) {
    return Consumer<QrDataProvider>(
      builder: (context, qrDataProvider, child) {
        return TextField(
          controller: _controller,
          onChanged: (data) async {
            qrDataProvider.setGeneratedQrValue(data);
            if (qrDataProvider.generatedQrCode.isNotEmpty) {
              final qrCode = QrCode.fromData(
                data: qrDataProvider.generatedQrCode,
                errorCorrectLevel: QrErrorCorrectLevel.H,
              );
              final qrImage = QrImage(qrCode);
              final qrImageAsBytes = await qrImage.toImageAsBytes(
                size: 512,
                format: ImageByteFormat.png,
                decoration: const PrettyQrDecoration(
                  shape: PrettyQrSmoothSymbol(
                      color: Colors.white,
                      roundFactor: BorderSide.strokeAlignCenter),
                ),
              );
              qrDataProvider.setQrImageObject(qrImage);
              qrDataProvider
                  .setGeneratedQrImage(qrImageAsBytes!.buffer.asUint8List());
            }
          },
          minLines: 1, // Minimum number of visible lines
          maxLines: null, // Makes it expandable
          keyboardType: TextInputType.multiline, // Allows multiline input
          decoration: InputDecoration(
            suffixIcon: qrDataProvider.generatedQrCode.isNotEmpty
                ? IconButton(
                    onPressed: () {
                      _controller.clear();
                      qrDataProvider.setGeneratedQrValue('');
                    },
                    icon: const Icon(Icons.clear),
                  )
                : null,

            focusedBorder: OutlineInputBorder(
              borderSide: BorderSide(
                  width: 2, color: Theme.of(context).colorScheme.primary),
            ),
            enabledBorder: OutlineInputBorder(
              borderSide: BorderSide(color: Theme.of(context).disabledColor),
            ),
            labelText: 'Enter text', // This will be the floating label
            floatingLabelStyle: const TextStyle(fontWeight: FontWeight.bold),
            floatingLabelBehavior:
                FloatingLabelBehavior.auto, // This will make the label float
          ),
        );
      },
    );
  }
}
