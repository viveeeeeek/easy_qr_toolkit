import 'package:easy_qr_toolkit/core/extensions/sizedbox.dart';
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
        // Fallback to text if parsing fails
        debugPrint('VCard parsing error: $e');
      }
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

  Widget _buildContactUI(BuildContext context, Contact contact) {
    final colorScheme = Theme.of(context).colorScheme;
    
    final name = contact.displayName.isNotEmpty ? contact.displayName : null;
    final org = contact.organizations.isNotEmpty ? contact.organizations.first.company : null;
    final phone = contact.phones.isNotEmpty ? contact.phones.first.number : null;
    final email = contact.emails.isNotEmpty ? contact.emails.first.address : null;

    return Column(
      children: [
        20.h,
        CircleAvatar(
          radius: 40,
          backgroundColor: colorScheme.primary,
          child: const Icon(Icons.person, size: 40, color: Colors.white),
        ),
        16.h,
        if (name != null)
          Text(
            name,
            style: const TextStyle(fontSize: 24, fontWeight: FontWeight.bold),
          ),
        if (org != null)
          Text(
            org,
            style: TextStyle(fontSize: 16, color: colorScheme.outline),
          ),
        24.h,
        if (phone != null)
          _buildInfoRow(context, Icons.phone_android, phone),
        if (email != null)
          _buildInfoRow(context, Icons.email, email),
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
