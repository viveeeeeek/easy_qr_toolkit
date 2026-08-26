import 'dart:io';
import 'package:android_intent_plus/android_intent.dart';
import 'package:android_intent_plus/flag.dart';
import 'package:easy_qr_toolkit/core/enums/qr_type.dart';
import 'package:easy_qr_toolkit/core/theme/m3_expressive.dart';
import 'package:easy_qr_toolkit/core/utils/wifi_parser.dart';
import 'package:flutter/services.dart';
import 'package:flutter_contacts/flutter_contacts.dart';
import 'package:material_ui/material_ui.dart';
import 'package:url_launcher/url_launcher.dart';

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
            runSpacing: 10,
            alignment: WrapAlignment.center,
            children: actions,
          ),
        ],
      ),
    );
  }

  List<Widget> _getSmartActions(BuildContext context) {
    final List<Widget> buttons = [];
    final scanType = QrType.fromString(type);

    // URL Action
    if (scanType == QrType.url || content.startsWith('http')) {
      buttons.add(
        M3EButton.icon(
          style: M3EButtonStyle.filled,
          size: M3EButtonSize.md,
          onPressed: () => _launchUrl(content),
          icon: const Icon(Icons.open_in_browser_rounded),
          label: const Text('Open Link'),
        ),
      );
    }

    // WiFi Action
    if (scanType == QrType.wifi || content.startsWith('WIFI:')) {
      buttons.add(
        M3EButton.icon(
          style: M3EButtonStyle.filled,
          size: M3EButtonSize.md,
          onPressed: () => _handleWifiConnect(context),
          icon: const Icon(Icons.wifi_find_rounded),
          label: const Text('Connect to Network'),
        ),
      );
    }

    // Geo/Maps Action
    if (scanType == QrType.geo || content.startsWith('geo:')) {
      buttons.add(
        M3EButton.icon(
          style: M3EButtonStyle.filled,
          size: M3EButtonSize.md,
          onPressed: () => _launchUrl(content),
          icon: const Icon(Icons.map_rounded),
          label: const Text('Open in Maps'),
        ),
      );
    }

    // Contact/vCard Action
    if (scanType == QrType.contact || content.contains('BEGIN:VCARD')) {
      buttons.add(
        M3EButton.icon(
          style: M3EButtonStyle.filled,
          size: M3EButtonSize.md,
          onPressed: () => _saveContact(context),
          icon: const Icon(Icons.person_add_alt_1_rounded),
          label: const Text('Add to Contacts'),
        ),
      );
    }

    return buttons;
  }

  Future<void> _handleWifiConnect(BuildContext context) async {
    final wifi = WifiParser.parse(content);
    if (wifi != null && wifi.password.isNotEmpty) {
      await Clipboard.setData(ClipboardData(text: wifi.password));
      if (context.mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(
            content: Text('Password copied! Opening WiFi Settings...'),
            behavior: SnackBarBehavior.floating,
          ),
        );
      }
    }

    if (Platform.isAndroid) {
      const intent = AndroidIntent(
        action: 'android.settings.WIFI_SETTINGS',
        flags: [Flag.FLAG_ACTIVITY_NEW_TASK],
      );
      await intent.launch();
    } else if (Platform.isIOS) {
       final url = Uri.parse('App-Prefs:root=WIFI');
       if (await canLaunchUrl(url)) {
         await launchUrl(url);
       } else {
         // Fallback usually just opens settings
         await launchUrl(Uri.parse('app-settings:'));
       }
    }
  }

  Future<void> _saveContact(BuildContext context) async {
    try {
      final contact = Contact.fromVCard(content);
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
    if (!await launchUrl(uri)) {
      debugPrint('Could not launch $url');
    }
  }
}
