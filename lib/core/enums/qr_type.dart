import 'package:material_ui/material_ui.dart';

/// Unified enum for both QR generation and scanning
enum QrType {
  text,
  wifi,
  contact,
  url,
  geo,
  other;

  static QrType fromString(String value) {
    return QrType.values.firstWhere(
      (e) => e.name.toLowerCase() == value.toLowerCase(),
      orElse: () => QrType.other,
    );
  }

  /// Label for generation UI (chips)
  String get label {
    switch (this) {
      case QrType.text:
        return 'Text';
      case QrType.wifi:
        return 'WiFi';
      case QrType.contact:
        return 'Contact';
      case QrType.url:
        return 'URL';
      case QrType.geo:
        return 'Location';
      case QrType.other:
        return 'Other';
    }
  }

  /// Whether this type has a generation form in the UI
  bool get isGeneratable {
    return this == QrType.text || 
           this == QrType.wifi || 
           this == QrType.contact;
  }

  /// Display label for scanned items (ALL CAPS)
  String get scanLabel {
    switch (this) {
      case QrType.url:
        return 'WEBSITE LINK';
      case QrType.wifi:
        return 'WIFI NETWORK';
      case QrType.contact:
        return 'CONTACT CARD';
      case QrType.geo:
        return 'LOCATION';
      case QrType.text:
        return 'PLAIN TEXT';
      case QrType.other:
        return 'SCANNED DATA';
    }
  }

  /// Icon for the type
  IconData get icon {
    switch (this) {
      case QrType.url:
        return Icons.link;
      case QrType.wifi:
        return Icons.wifi;
      case QrType.contact:
        return Icons.person_outline;
      case QrType.geo:
        return Icons.location_on;
      case QrType.text:
        return Icons.text_fields;
      case QrType.other:
        return Icons.qr_code;
    }
  }

  /// Display name for UI
  String get displayName {
    switch (this) {
      case QrType.url:
        return 'URL';
      case QrType.wifi:
        return 'WiFi';
      case QrType.contact:
        return 'Contact';
      case QrType.geo:
        return 'Location';
      case QrType.text:
        return 'Text';
      case QrType.other:
        return 'Other';
    }
  }
}
