import 'package:flutter/foundation.dart';
import 'package:flutter_contacts/flutter_contacts.dart';
import 'package:riverpod_annotation/riverpod_annotation.dart';

part 'vcard_cache_provider.g.dart';

@Riverpod(keepAlive: true)
class VCardCache extends _$VCardCache {
  @override
  Map<String, String> build() => {};

  Future<void> resolve(String content) async {
    // 1. Fast exit if already cached
    if (state.containsKey(content)) {
      return;
    }

    // 2. Compute in background isolate
    try {
      final name = await compute(_isolateParseVCard, content);

      // 3. Update state (cache the result)
      if (name != null) {
        state = {...state, content: name};
      } else {
        // Cache failure as "Contact Card" to prevent infinite retry
        state = {...state, content: 'Contact Card'};
      }
    } catch (_) {
      // On error, also cache to prevent retry
      state = {...state, content: 'Contact Card'};
    }
  }
}

// Pure function must be top-level for compute
String? _isolateParseVCard(String content) {
  try {
    final contact = Contact.fromVCard(content);
    return contact.displayName.isNotEmpty ? contact.displayName : null;
  } catch (_) {
    return null;
  }
}
