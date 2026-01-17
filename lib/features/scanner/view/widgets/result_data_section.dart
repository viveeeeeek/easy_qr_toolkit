import 'package:easy_qr_toolkit/core/extensions/sizedbox.dart';
import 'package:easy_qr_toolkit/core/utils/wifi_parser.dart';
import 'package:flutter/material.dart';
import 'package:flutter_contacts/flutter_contacts.dart';

class ResultDataSection extends StatelessWidget {
  final String content;

  const ResultDataSection({super.key, required this.content});

  @override
  Widget build(BuildContext context) {
    if (content.contains('BEGIN:VCARD')) {
      try {
        final contact = Contact.fromVCard(content);
        return _buildContactUI(context, contact);
      } catch (e) {
        debugPrint('VCard parsing error: $e');
      }
    }

    final wifi = WifiParser.parse(content);
    if (wifi != null) {
      return _buildWifiUI(context, wifi);
    }

    return Column(
      children: [
        Text(
          content,
          style: const TextStyle(fontSize: 18),
          textAlign: TextAlign.center,
        ),
      ],
    );
  }

  Widget _buildWifiUI(BuildContext context, WifiResult wifi) {
    final colorScheme = Theme.of(context).colorScheme;
    return Column(
      children: [
        CircleAvatar(
          radius: 32,
          backgroundColor: colorScheme.primaryContainer,
          child: Icon(Icons.wifi, size: 32, color: colorScheme.primary),
        ),
        16.h,
        Text(
          wifi.ssid,
          style: const TextStyle(fontSize: 22, fontWeight: FontWeight.bold),
          textAlign: TextAlign.center,
        ),
        8.h,
        Container(
          padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 4),
          decoration: BoxDecoration(
            color: colorScheme.surfaceContainerHighest,
            borderRadius: BorderRadius.circular(8),
            border: Border.all(color: colorScheme.outlineVariant),
          ),
          child: Text(
            'Security: ${wifi.type}',
            style: TextStyle(
              fontSize: 12,
              color: colorScheme.onSurfaceVariant,
              fontWeight: FontWeight.w500,
            ),
          ),
        ),
        24.h,
        _buildInfoRow(context, Icons.lock_outline, wifi.password),
      ],
    );
  }

  Widget _buildContactUI(BuildContext context, Contact contact) {
    final colorScheme = Theme.of(context).colorScheme;
    
    final name = contact.displayName.isNotEmpty ? contact.displayName : null;
    final org = contact.organizations.isNotEmpty ? contact.organizations.first.company : null;
    final phone = contact.phones.isNotEmpty ? contact.phones.first.number : null;
    final email = contact.emails.isNotEmpty ? contact.emails.first.address : null;

    return Column(
      children: [
        CircleAvatar(
          radius: 32,
          backgroundColor: colorScheme.primary,
          child: const Icon(Icons.person, size: 32, color: Colors.white),
        ),
        16.h,
        if (name != null)
          Text(
            name,
            style: const TextStyle(fontSize: 22, fontWeight: FontWeight.bold),
          ),
        if (org != null)
          Text(
            org,
            style: TextStyle(fontSize: 14, color: colorScheme.outline),
          ),
        24.h,
        if (phone != null)
          _buildInfoRow(context, Icons.phone_android, phone),
        if (email != null)
          _buildInfoRow(context, Icons.email, email),
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
