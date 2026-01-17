import 'dart:ui';

import 'package:easy_qr_toolkit/core/services/qr_service.dart';
import 'package:easy_qr_toolkit/features/generator/generator_provider.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:pretty_qr_code/pretty_qr_code.dart';

class QRTextInputWidget extends ConsumerStatefulWidget {
  const QRTextInputWidget({super.key});

  @override
  ConsumerState<QRTextInputWidget> createState() => _QRTextInputWidgetState();
}

class _QRTextInputWidgetState extends ConsumerState<QRTextInputWidget> {
  final TextEditingController _controller = TextEditingController();

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final generatorData = ref.watch(generatorProvider);
    final generator = ref.read(generatorProvider.notifier);
    final qrService = ref.read(qrServiceProvider);

    return TextField(
      controller: _controller,
      onChanged: (data) async {
        if (data.isEmpty) {
          generator.reset();
          return;
        }

        final qrImageObject = qrService.generateQrImageObject(data);

        // Update state with text and object first
        generator.updateState(
          data: data,
          qrImageObject: qrImageObject,
        );

        // Then generate bytes for sharing/saving
        final qrImageAsBytes = await qrImageObject.toImageAsBytes(
          size: 512,
          format: ImageByteFormat.png,
          decoration: const PrettyQrDecoration(
            shape: PrettyQrSmoothSymbol(
              color: Colors.white,
              roundFactor: BorderSide.strokeAlignCenter,
            ),
          ),
        );

        if (qrImageAsBytes != null) {
          generator.updateState(
            data: data,
            qrImageObject: qrImageObject,
            generatedQrImage: qrImageAsBytes.buffer.asUint8List(),
          );
        }
      },
      minLines: 1,
      maxLines: null,
      keyboardType: TextInputType.multiline,
      decoration: InputDecoration(
        suffixIcon: generatorData.data.isNotEmpty
            ? IconButton(
                onPressed: () {
                  _controller.clear();
                  generator.reset();
                },
                icon: const Icon(Icons.clear),
              )
            : null,
        focusedBorder: OutlineInputBorder(
          borderSide: BorderSide(
            width: 2,
            color: Theme.of(context).colorScheme.primary,
          ),
        ),
        enabledBorder: OutlineInputBorder(
          borderSide: BorderSide(color: Theme.of(context).disabledColor),
        ),
        labelText: 'Enter text',
        floatingLabelStyle: const TextStyle(fontWeight: FontWeight.bold),
        floatingLabelBehavior: FloatingLabelBehavior.auto,
      ),
    );
  }
}
