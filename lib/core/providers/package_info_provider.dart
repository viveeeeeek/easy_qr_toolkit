import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:package_info_plus/package_info_plus.dart';

final packageInfoProvider = Provider<PackageInfo>((ref) {
  // Overridden in main.dart via ProviderScope for synchronous access
  throw UnimplementedError('packageInfoProvider must be overridden in main.dart');
});
