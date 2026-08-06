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

    if (content.startsWith('http')) {
      if (content.contains('google.com/maps') ||
          content.contains('maps.google.com') ||
          content.contains('goo.gl/maps')) {
        return _buildLocationUI(context, content);
      }
      return _buildUrlUI(context, content);
    }

    if (content.startsWith('geo:')) {
      return _buildLocationUI(context, content);
    }

    return _buildTextUI(context, content);
  }

  Widget _buildWifiUI(BuildContext context, WifiResult wifi) {
    final colorScheme = Theme.of(context).colorScheme;
    return Column(
      children: [
        _buildIconHeader(context, Icons.wifi),
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

    final name =
        contact.displayName.isNotEmpty ? contact.displayName : 'Contact';
    final org = contact.organizations.isNotEmpty
        ? contact.organizations.first.company
        : null;
    final phone =
        contact.phones.isNotEmpty ? contact.phones.first.number : null;
    final email =
        contact.emails.isNotEmpty ? contact.emails.first.address : null;

    return Column(
      children: [
        _buildIconHeader(context, Icons.person),
        16.h,
        Text(
          name,
          style: const TextStyle(fontSize: 22, fontWeight: FontWeight.bold),
          textAlign: TextAlign.center,
        ),
        if (org != null)
          Text(
            org,
            style: TextStyle(fontSize: 14, color: colorScheme.outline),
          ),
        24.h,
        if (phone != null) _buildInfoRow(context, Icons.phone_android, phone),
        if (email != null) _buildInfoRow(context, Icons.email, email),
      ],
    );
  }

  Widget _buildUrlUI(BuildContext context, String url) {
    return Column(
      children: [
        _buildIconHeader(context, Icons.link),
        16.h,
        _buildScrollableTextContent(
          context,
          url,
          const TextStyle(fontSize: 18, fontWeight: FontWeight.w500),
        ),
      ],
    );
  }

  Widget _buildLocationUI(BuildContext context, String location) {
    return Column(
      children: [
        _buildIconHeader(context, Icons.location_on),
        16.h,
        _buildScrollableTextContent(
          context,
          location,
          const TextStyle(fontSize: 18, fontWeight: FontWeight.w500),
        ),
      ],
    );
  }

  Widget _buildTextUI(BuildContext context, String text) {
    return Column(
      children: [
        _buildIconHeader(context, Icons.text_fields),
        16.h,
        _buildScrollableTextContent(
          context,
          text,
          const TextStyle(fontSize: 18),
        ),
      ],
    );
  }

  Widget _buildScrollableTextContent(
    BuildContext context,
    String text,
    TextStyle style,
  ) {
    final colorScheme = Theme.of(context).colorScheme;
    final scrollController = ScrollController();
    final isLong = text.length > 80 || text.contains('\n');

    return Column(
      children: [
        ConstrainedBox(
          constraints: const BoxConstraints(maxHeight: 180),
          child: Scrollbar(
            controller: scrollController,
            thumbVisibility: isLong,
            radius: const Radius.circular(8),
            child: SingleChildScrollView(
              controller: scrollController,
              physics: const BouncingScrollPhysics(),
              child: Padding(
                padding: const EdgeInsets.symmetric(horizontal: 16.0),
                child: Text(
                  text,
                  style: style,
                  textAlign: TextAlign.center,
                ),
              ),
            ),
          ),
        ),
        if (isLong) ...[
          8.h,
          Row(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Icon(
                Icons.unfold_more,
                size: 14,
                color: colorScheme.primary.withValues(alpha: 0.7),
              ),
              4.w,
              Text(
                'Scroll for more',
                style: TextStyle(
                  fontSize: 11,
                  color: colorScheme.primary.withValues(alpha: 0.7),
                  fontWeight: FontWeight.w600,
                  letterSpacing: 0.3,
                ),
              ),
            ],
          ),
        ],
      ],
    );
  }

  Widget _buildIconHeader(BuildContext context, IconData icon) {
    final colorScheme = Theme.of(context).colorScheme;
    return CircleAvatar(
      radius: 32,
      backgroundColor: colorScheme.primaryContainer,
      child: Icon(icon, size: 32, color: colorScheme.primary),
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
