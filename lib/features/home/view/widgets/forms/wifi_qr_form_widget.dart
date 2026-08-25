import 'dart:async';

import 'package:material_ui/material_ui.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../../generator_provider.dart';

class WifiQrFormWidget extends ConsumerStatefulWidget {
  const WifiQrFormWidget({
    super.key,
    this.focusNode,
    this.onTypingStateChanged,
  });

  final FocusNode? focusNode;
  final ValueChanged<bool>? onTypingStateChanged;

  @override
  ConsumerState<WifiQrFormWidget> createState() => _WifiQrInputCardState();
}

class _WifiQrInputCardState extends ConsumerState<WifiQrFormWidget> {
  final TextEditingController _ssidController = TextEditingController();
  final TextEditingController _passwordController = TextEditingController();
  String _encryption = 'WPA'; // WPA, WEP, nopass
  bool _isHidden = false;

  Timer? _debounceTimer;

  @override
  void dispose() {
    _debounceTimer?.cancel();
    _ssidController.dispose();
    _passwordController.dispose();
    super.dispose();
  }

  void _generate() {
    if (_debounceTimer?.isActive ?? false) _debounceTimer!.cancel();

    _debounceTimer = Timer(const Duration(milliseconds: 350), () {
      final ssid = _ssidController.text.trim();
      final password = _passwordController.text;
      
      if (ssid.isEmpty) {
        ref.read(generatorProvider.notifier).reset();
        widget.onTypingStateChanged?.call(false);
        return;
      }

      // Format: WIFI:S:MyNet;T:WPA;P:1234;H:false;;
      // H: is hidden
      final buffer = StringBuffer('WIFI:');
      buffer.write('S:$ssid;');
      buffer.write('T:$_encryption;');
      if (password.isNotEmpty) {
        buffer.write('P:$password;');
      }
      buffer.write('H:$_isHidden;;');

      ref.read(generatorProvider.notifier).generateImage(buffer.toString());
      widget.onTypingStateChanged?.call(true);
    });
  }

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.stretch,
      children: [
        // SSID Input
        TextField(
          focusNode: widget.focusNode,
          controller: _ssidController,
          onChanged: (_) => _generate(),
          decoration: _inputDecoration(context, 'Network Name (SSID)', Icons.wifi),
        ),
        const SizedBox(height: 12),
        
        // Password Input
        TextField(
          controller: _passwordController,
          onChanged: (_) => _generate(),
          obscureText: true,
          decoration: _inputDecoration(context, 'Password', Icons.lock_outline),
        ),
        const SizedBox(height: 12),

        // Encryption and Hidden Row
        Row(
          children: [
            Expanded(
              child: Container(
                padding: const EdgeInsets.symmetric(horizontal: 16),
                decoration: BoxDecoration(
                  color: Theme.of(context).colorScheme.surfaceContainerHighest.withValues(alpha: 0.3),
                  borderRadius: BorderRadius.circular(16),
                ),
                child: DropdownButtonHideUnderline(
                  child: DropdownButton<String>(
                    value: _encryption,
                    icon: const Icon(Icons.arrow_drop_down_rounded),
                    items: const [
                       DropdownMenuItem(value: 'WPA', child: Text('WPA/WPA2')),
                       DropdownMenuItem(value: 'WEP', child: Text('WEP')),
                       DropdownMenuItem(value: 'nopass', child: Text('None')),
                    ],
                    onChanged: (val) {
                      if (val != null) {
                        setState(() => _encryption = val);
                        _generate();
                      }
                    },
                  ),
                ),
              ),
            ),
            const SizedBox(width: 12),
            Tooltip(
              message: 'Enable if the Wi-Fi network SSID is hidden (non-broadcasting)',
              child: FilterChip(
                showCheckmark: false,
                avatar: Icon(
                  _isHidden ? Icons.visibility_off_rounded : Icons.visibility_rounded,
                  size: 16,
                ),
                label: const Text('Hidden'),
                selected: _isHidden,
                onSelected: (val) {
                  setState(() => _isHidden = val);
                  _generate();
                },
              ),
            ),
          ],
        ),
      ],
    );
  }

  InputDecoration _inputDecoration(BuildContext context, String hint, IconData icon) {
    return InputDecoration(
      hintText: hint,
      prefixIcon: Icon(icon, size: 20, color: Theme.of(context).colorScheme.onSurfaceVariant),
      hintStyle: TextStyle(
        color: Theme.of(context).colorScheme.onSurfaceVariant.withValues(alpha: 0.5),
      ),
      filled: true,
      fillColor: Theme.of(context).colorScheme.surfaceContainerHighest.withValues(alpha: 0.3),
      border: OutlineInputBorder(
        borderRadius: BorderRadius.circular(20),
        borderSide: BorderSide.none,
      ),
      contentPadding: const EdgeInsets.all(20),
    );
  }
}
