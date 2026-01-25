import 'dart:async';

import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../../generator_provider.dart';

class ContactQrFormWidget extends ConsumerStatefulWidget {
  const ContactQrFormWidget({
    super.key,
    this.focusNode,
    this.onTypingStateChanged,
  });

  final FocusNode? focusNode;
  final ValueChanged<bool>? onTypingStateChanged;

  @override
  ConsumerState<ContactQrFormWidget> createState() => _ContactQrInputCardState();
}

class _ContactQrInputCardState extends ConsumerState<ContactQrFormWidget> {
  final TextEditingController _nameController = TextEditingController();
  final TextEditingController _phoneController = TextEditingController();
  final TextEditingController _emailController = TextEditingController();
  final TextEditingController _orgController = TextEditingController();

  Timer? _debounceTimer;

  @override
  void dispose() {
    _debounceTimer?.cancel();
    _nameController.dispose();
    _phoneController.dispose();
    _emailController.dispose();
    _orgController.dispose();
    super.dispose();
  }

  void _generate() {
    if (_debounceTimer?.isActive ?? false) _debounceTimer!.cancel();

    _debounceTimer = Timer(const Duration(milliseconds: 350), () {
      final name = _nameController.text.trim();
      final phone = _phoneController.text.trim();
      final email = _emailController.text.trim();
      final org = _orgController.text.trim();
      
      if (name.isEmpty && phone.isEmpty && email.isEmpty && org.isEmpty) {
        ref.read(generatorProvider.notifier).reset();
        widget.onTypingStateChanged?.call(false);
        return;
      }

      final buffer = StringBuffer();
      buffer.writeln('BEGIN:VCARD');
      buffer.writeln('VERSION:3.0');
      
      if (name.isNotEmpty) {
        buffer.writeln('FN:$name');
        // Simple N implementation: Last;First;;;
        final parts = name.split(' ');
        if (parts.length > 1) {
          final last = parts.last;
          final first = parts.sublist(0, parts.length - 1).join(' ');
          buffer.writeln('N:$last;$first;;;');
        } else {
          buffer.writeln('N:$name;;;;;');// Fallback
        }
      }
      
      if (phone.isNotEmpty) buffer.writeln('TEL:$phone');
      if (email.isNotEmpty) buffer.writeln('EMAIL:$email');
      if (org.isNotEmpty) buffer.writeln('ORG:$org');
      
      buffer.writeln('END:VCARD');

      ref.read(generatorProvider.notifier).generateImage(buffer.toString());
      widget.onTypingStateChanged?.call(true);
    });
  }

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.stretch,
      children: [
        TextField(
          focusNode: widget.focusNode,
          controller: _nameController,
          onChanged: (_) => _generate(),
          decoration: _inputDecoration(context, 'Full Name', Icons.person_outline),
        ),
        const SizedBox(height: 12),
        TextField(
          controller: _phoneController,
          onChanged: (_) => _generate(),
          keyboardType: TextInputType.phone,
          decoration: _inputDecoration(context, 'Phone Number', Icons.phone_outlined),
        ),
        const SizedBox(height: 12),
        TextField(
          controller: _emailController,
          onChanged: (_) => _generate(),
          keyboardType: TextInputType.emailAddress,
          decoration: _inputDecoration(context, 'Email', Icons.email_outlined),
        ),
        const SizedBox(height: 12),
        TextField(
          controller: _orgController,
          onChanged: (_) => _generate(),
          decoration: _inputDecoration(context, 'Company / Organization', Icons.business_rounded),
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
