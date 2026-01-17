import 'dart:ui';

import 'package:easy_qr_toolkit/core/services/qr_service.dart';
import 'package:easy_qr_toolkit/features/generator/generator_provider.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:pretty_qr_code/pretty_qr_code.dart';

class ModernQRInputCard extends ConsumerStatefulWidget {
  const ModernQRInputCard({super.key});

  @override
  ConsumerState<ModernQRInputCard> createState() => _ModernQRInputCardState();
}

class _ModernQRInputCardState extends ConsumerState<ModernQRInputCard> {
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

    return Column(
      crossAxisAlignment: CrossAxisAlignment.end,
      children: [
        TextField(
          controller: _controller,
          onChanged: (data) => _onTextChanged(data, ref),
          inputFormatters: [
            // Prevent entering newlines to keep input simple
            FilteringTextInputFormatter.deny(RegExp(r'\n')),
          ],
          textInputAction: TextInputAction.done,
          minLines: 4,
          maxLines: null,
          keyboardType: TextInputType.text,
          style: Theme.of(context).textTheme.bodyLarge?.copyWith(
            height: 1.5,
          ),
          decoration: InputDecoration(
            hintText: 'What would you like to share?',
            hintStyle: TextStyle(
              color: Theme.of(context).colorScheme.onSurfaceVariant.withOpacity(0.7),
            ),
            filled: true,
            fillColor: Theme.of(context).colorScheme.surfaceContainerHighest.withValues(alpha: 0.3),
            border: OutlineInputBorder(
              borderRadius: BorderRadius.circular(20),
              borderSide: BorderSide.none,
            ),
            contentPadding: const EdgeInsets.all(24),
          ),
        ),
        const SizedBox(height: 12),
        if (generatorData.data.isEmpty)
          FilledButton.tonalIcon(
            onPressed: () async {
              final clipboardData = await Clipboard.getData(Clipboard.kTextPlain);
              if (clipboardData != null &&
                  clipboardData.text != null &&
                  clipboardData.text!.isNotEmpty) {
                _controller.text = clipboardData.text!;
                _onTextChanged(clipboardData.text!, ref);
              }
            },
            icon: const Icon(Icons.paste_rounded, size: 18),
            label: const Text('Paste from Clipboard'),
            style: FilledButton.styleFrom(
              padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 12),
            ),
          ),
        if (generatorData.data.isNotEmpty)
          TextButton.icon(
            onPressed: () {
              _controller.clear();
              generator.reset();
            },
            icon: const Icon(Icons.clear_rounded, size: 18),
            label: const Text('Clear text'),
            style: TextButton.styleFrom(
              foregroundColor: Theme.of(context).colorScheme.error,
              padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 12),
            ),
          ),
      ],
    );
  }

  Future<void> _onTextChanged(String data, WidgetRef ref) async {
    final generator = ref.read(generatorProvider.notifier);
    final qrService = ref.read(qrServiceProvider);

    if (data.trim().isEmpty) {
      generator.reset();
      return;
    }

    final qrImageObject = qrService.generateQrImageObject(data);

    generator.updateState(
      data: data,
      qrImageObject: qrImageObject,
    );

    final qrImageAsBytes = await qrImageObject.toImageAsBytes(
      size: 512,
      format: ImageByteFormat.png,
      decoration: const PrettyQrDecoration(
        shape: PrettyQrSmoothSymbol(
          color: Colors.black,
          roundFactor: BorderSide.strokeAlignCenter,
        ),
      ),
    );

    if (qrImageAsBytes == null) return;

    final paddedQrBytes = await qrService.generatePaddedQrImage(
      qrImageAsBytes.buffer.asUint8List(),
    );

    // Check if the input has changed while we were generating the image
    // This prevents race conditions where an old generation finishes after the text has been cleared or changed
    if (!mounted || _controller.text != data) return;

    if (paddedQrBytes != null) {
      generator.updateState(
        data: data,
        qrImageObject: qrImageObject,
        generatedQrImage: paddedQrBytes,
      );
    }
  }
}
