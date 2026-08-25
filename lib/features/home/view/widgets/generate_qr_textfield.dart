import 'dart:async';

import 'package:easy_qr_toolkit/core/services/qr_service.dart';
import 'package:material_ui/material_ui.dart';
import 'package:flutter/services.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:pretty_qr_code/pretty_qr_code.dart';

import '../../generator_provider.dart';

class ModernQRInputCard extends ConsumerStatefulWidget {
  const ModernQRInputCard({
    super.key, 
    this.focusNode,
    this.onTypingStateChanged,
  });

  /// Optional external focus node for route-aware focus management
  final FocusNode? focusNode;
  
  /// Callback when typing state changes (true = has text, false = empty)
  final ValueChanged<bool>? onTypingStateChanged;

  @override
  ConsumerState<ModernQRInputCard> createState() => _ModernQRInputCardState();
}

class _ModernQRInputCardState extends ConsumerState<ModernQRInputCard> {
  final TextEditingController _controller = TextEditingController();
  Timer? _debounceTimer;

  @override
  void initState() {
    super.initState();
    _controller.text = ref.read(generatorProvider).data;
    // Notify parent of initial state
    WidgetsBinding.instance.addPostFrameCallback((_) {
      widget.onTypingStateChanged?.call(_controller.text.isNotEmpty);
    });
  }

  @override
  void dispose() {
    _debounceTimer?.cancel();
    _controller.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final generatorData = ref.watch(generatorProvider);
    final generator = ref.read(generatorProvider.notifier);

    return Column(
      crossAxisAlignment: CrossAxisAlignment.end,
      children: [
        TextField(
          focusNode: widget.focusNode,
          controller: _controller,
          onChanged: (data) => _onTextChanged(data, ref),
          inputFormatters: [
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
            hintText: 'Type to generate QR...',
            hintStyle: TextStyle(
              color: Theme.of(context)
                  .colorScheme
                  .onSurfaceVariant
                  .withValues(alpha:0.5),
            ),
            filled: true,
            fillColor: Theme.of(context)
                .colorScheme
                .surfaceContainerHighest
                .withValues(alpha: 0.3),
            border: OutlineInputBorder(
              borderRadius: BorderRadius.circular(20),
              borderSide: BorderSide.none,
            ),
            contentPadding: const EdgeInsets.all(24),
            suffixIcon: generatorData.data.isNotEmpty
                ? IconButton(
                    icon: const Icon(Icons.clear_rounded),
                    onPressed: () {
                      _controller.clear();
                      generator.reset();
                      // Notify parent that typing stopped
                      widget.onTypingStateChanged?.call(false);
                    },
                    tooltip: 'Clear text',
                  )
                : null,
          ),
        ),
        const SizedBox(height: 12),
        // Hide paste button immediately when user types (check controller, not provider)
        if (_controller.text.isEmpty)
          FilledButton.tonalIcon(
            onPressed: () async {
              final clipboardData =
                  await Clipboard.getData(Clipboard.kTextPlain);
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
      ],
    );
  }

  void _onTextChanged(String data, WidgetRef ref) {
    final generator = ref.read(generatorProvider.notifier);
    
    // Notify parent immediately about typing state
    widget.onTypingStateChanged?.call(data.trim().isNotEmpty);

    if (_debounceTimer?.isActive ?? false) {
      _debounceTimer!.cancel();
    }

    if (data.trim().isEmpty) {
      generator.reset();
      return;
    }

    _debounceTimer = Timer(const Duration(milliseconds: 350), () {
       generator.generateImage(data);
    });
  }
}
