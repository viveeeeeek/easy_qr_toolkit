class VCardData {
  final String? fullName;
  final String? phone;
  final String? email;
  final String? organization;

  VCardData({
    this.fullName,
    this.phone,
    this.email,
    this.organization,
  });

  bool get isEmpty =>
      fullName == null && phone == null && email == null && organization == null;
}

class VCardParser {
  static VCardData parse(String data) {
    if (!data.contains('BEGIN:VCARD')) {
      return VCardData();
    }

    String? fullName;
    String? phone;
    String? email;
    String? organization;

    final lines = data.split('\n');
    for (var line in lines) {
      if (line.startsWith('FN:')) {
        fullName = line.substring(3).trim();
      } else if (line.startsWith('TEL')) {
        // Handle TEL;TYPE=CELL:123 or TEL:123
        final parts = line.split(':');
        if (parts.length > 1) {
          phone = parts[1].trim();
        }
      } else if (line.startsWith('EMAIL')) {
        final parts = line.split(':');
        if (parts.length > 1) {
          email = parts[1].trim();
        }
      } else if (line.startsWith('ORG:')) {
        organization = line.substring(4).trim();
      }
    }

    return VCardData(
      fullName: fullName,
      phone: phone,
      email: email,
      organization: organization,
    );
  }
}
