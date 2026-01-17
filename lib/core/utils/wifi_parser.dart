
class WifiResult {
  final String ssid;
  final String password;
  final String type;
  final bool isHidden;

  WifiResult({
    required this.ssid,
    required this.password,
    required this.type,
    required this.isHidden,
  });
}

class WifiParser {
  static WifiResult? parse(String rawData) {
    if (!rawData.startsWith('WIFI:')) return null;

    String ssid = '';
    String password = '';
    String type = '';
    bool isHidden = false;

    // Remove the prefix "WIFI:"
    final content = rawData.substring(5);
    
    // Split by semicolons, but be careful of escaped characters (though basic splitting usually suffices for QR)
    // A more robust regex approach: 
    // S:(.*?)(?<!\\); 
    // But basic split is often used for these standard formats.
    
    // Simple state machine or plain split if we assume standard format
    // WIFI:S:MySSID;T:WPA;P:MyPass;H:false;;
    
    final tokens = content.split(';');
    for (var token in tokens) {
      if (token.isEmpty) continue;
      
      if (token.startsWith('S:')) {
        ssid = token.substring(2);
      } else if (token.startsWith('T:')) {
        type = token.substring(2);
      } else if (token.startsWith('P:')) {
        password = token.substring(2);
      } else if (token.startsWith('H:')) {
        isHidden = token.substring(2).toLowerCase() == 'true';
      }
    }

    return WifiResult(
      ssid: ssid,
      password: password,
      type: type,
      isHidden: isHidden,
    );
  }
}
