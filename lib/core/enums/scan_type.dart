
import 'package:flutter/material.dart';

enum ScanType {
  url,
  wifi,
  contactInfo,
  geo,
  text,
  other;

  static ScanType fromString(String value) {
    return ScanType.values.firstWhere(
      (e) => e.name.toLowerCase() == value.toLowerCase(),
      orElse: () => ScanType.other,
    );
  }

  String get label {
    switch (this) {
      case ScanType.url:
        return 'WEBSITE LINK';
      case ScanType.wifi:
        return 'WIFI NETWORK';
      case ScanType.contactInfo:
        return 'CONTACT CARD';
      case ScanType.geo:
        return 'LOCATION';
      case ScanType.text:
        return 'PLAIN TEXT';
      case ScanType.other:
        return 'SCANNED DATA';
    }
  }

  IconData get icon {
    switch (this) {
      case ScanType.url:
        return Icons.link;
      case ScanType.wifi:
        return Icons.wifi;
      case ScanType.contactInfo:
        return Icons.person_outline;
      case ScanType.geo:
        return Icons.map_outlined;
      case ScanType.text:
        return Icons.text_fields;
      case ScanType.other:
        return Icons.qr_code;
    }
  }

  String get displayName {
    switch (this) {
      case ScanType.url:
        return 'URL';
      case ScanType.wifi:
        return 'WiFi';
      case ScanType.contactInfo:
        return 'ContactInfo';
      case ScanType.geo:
        return 'Location';
      case ScanType.text:
        return 'Text';
      case ScanType.other:
        return 'Other';
    }
  }
}
