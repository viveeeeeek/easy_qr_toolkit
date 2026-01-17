import 'package:flutter/material.dart';
import 'package:url_launcher/url_launcher.dart';
import 'package:flutter/services.dart';
import 'package:flutter_contacts/flutter_contacts.dart';

class SmartActionButtons extends StatelessWidget {
  final String content;
  final String type;

  const SmartActionButtons({
    super.key,
    required this.content,
    required this.type,
  });

  @override
  Widget build(BuildContext context) {
    final actions = _getSmartActions(context);
    if (actions.isEmpty) return const SizedBox.shrink();

    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 10.0),
      child: Column(
        children: [
          Wrap(
            spacing: 10,
            alignment: WrapAlignment.center,
            children: actions,
          ),
        ],
      ),
    );
  }

  List<Widget> _getSmartActions(BuildContext context) {
    final List<Widget> buttons = [];

    // URL Action
    if (type == 'url' || content.startsWith('http')) {
      buttons.add(
        FilledButton.icon(
          onPressed: () => _launchUrl(content),
          icon: const Icon(Icons.open_in_browser),
          label: const Text('Open Link'),
        ),
      );
    }

    // WiFi Action
    if (type == 'wifi' || content.startsWith('WIFI:')) {
      buttons.add(
        FilledButton.icon(
          onPressed: () {
            Clipboard.setData(ClipboardData(text: content));
            ScaffoldMessenger.of(context).showSnackBar(
              const SnackBar(content: Text('WiFi details copied to clipboard')),
            );
          },
          icon: const Icon(Icons.wifi),
          label: const Text('Copy WiFi Details'),
        ),
      );
    }

    // Geo/Maps Action
    if (type == 'geo' || content.startsWith('geo:')) {
      buttons.add(
        FilledButton.icon(
          onPressed: () => _launchUrl(content),
          icon: const Icon(Icons.map_outlined),
          label: const Text('Open in Maps'),
        ),
      );
    }

    // Contact/vCard Action - The "Smart" part (Using flutter_contacts for direct intent)
    if (type == 'contactInfo' || content.contains('BEGIN:VCARD')) {
      buttons.add(
        FilledButton.icon(
          onPressed: () => _saveContact(context),
          icon: const Icon(Icons.person_add_alt_1),
          label: const Text('Add to Contacts'),
        ),
      );
    }

    return buttons;
  }

  Future<void> _saveContact(BuildContext context) async {
    try {
      // 1. Parse the vCard string into a Contact object
      final contact = Contact.fromVCard(content);
      
      // 2. Open the system's "New Contact" screen pre-filled with this data
      // This doesn't require manifest permissions as it's an external intent
      await FlutterContacts.openExternalInsert(contact);
      
    } catch (e) {
      if (context.mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('Error adding contact: $e')),
        );
      }
    }
  }

  Future<void> _launchUrl(String url) async {
    final Uri uri = Uri.parse(url);
    if (!await launchUrl(uri, mode: LaunchMode.externalApplication)) {
      debugPrint('Could not launch $url');
    }
  }
}
