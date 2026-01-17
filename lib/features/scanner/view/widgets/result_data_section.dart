import 'package:easy_qr_toolkit/core/extensions/sizedbox.dart';
import 'package:easy_qr_toolkit/core/utils/vcard_parser.dart';
import 'package:flutter/material.dart';

class ResultDataSection extends StatelessWidget {
  final String content;

  const ResultDataSection({super.key, required this.content});

  @override
  Widget build(BuildContext context) {
    if (content.contains('BEGIN:VCARD')) {
      final contact = VCardParser.parse(content);
      return _buildContactUI(context, contact);
    }

    return Column(
      children: [
        33.h,
        Text(
          content,
          style: const TextStyle(fontSize: 20),
          textAlign: TextAlign.center,
        ),
        20.h,
        const Divider(
          indent: 25,
          endIndent: 25,
        ),
      ],
    );
  }

  Widget _buildContactUI(BuildContext context, VCardData contact) {
    final colorScheme = Theme.of(context).colorScheme;

    return Column(
      children: [
        20.h,
        CircleAvatar(
          radius: 40,
          backgroundColor: colorScheme.primary,
          child: const Icon(Icons.person, size: 40, color: Colors.white),
        ),
        16.h,
        if (contact.fullName != null && contact.fullName!.isNotEmpty)
          Text(
            contact.fullName!,
            style: const TextStyle(fontSize: 24, fontWeight: FontWeight.bold),
          ),
        if (contact.organization != null && contact.organization!.isNotEmpty)
          Text(
            contact.organization!,
            style: TextStyle(fontSize: 16, color: colorScheme.outline),
          ),
        24.h,
        // Only show if data is actually there
        if (contact.phone != null && contact.phone!.isNotEmpty)
          _buildInfoRow(context, Icons.phone_android, contact.phone!),
        if (contact.email != null && contact.email!.isNotEmpty)
          _buildInfoRow(context, Icons.email, contact.email!),
        20.h,
        const Divider(indent: 25, endIndent: 25),
      ],
    );
  }

  Widget _buildInfoRow(BuildContext context, IconData icon, String text) {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 40, vertical: 8),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Icon(icon, size: 20, color: Theme.of(context).colorScheme.primary),
          12.w,
          Expanded(
            child: Text(
              text,
              style: const TextStyle(fontSize: 16),
              textAlign: TextAlign.start,
            ),
          ),
        ],
      ),
    );
  }
}
