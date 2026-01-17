import 'package:easy_qr_toolkit/core/database/database_service.dart';
import 'package:easy_qr_toolkit/features/history/scan_data_model.dart';
import 'package:riverpod_annotation/riverpod_annotation.dart';

part 'history_provider.g.dart';

@riverpod
class History extends _$History {
  @override
  FutureOr<List<ScanDataModel>> build() async {
    final db = ref.watch(databaseServiceProvider);
    return db.getData();
  }

  Future<void> addScan(ScanDataModel scan) async {
    state = const AsyncValue.loading();
    state = await AsyncValue.guard(() async {
      await ref.read(databaseServiceProvider).addData(scan);
      return ref.read(databaseServiceProvider).getData();
    });
  }

  Future<void> deleteScan(int id) async {
    state = const AsyncValue.loading();
    state = await AsyncValue.guard(() async {
      await ref.read(databaseServiceProvider).deleteData(id);
      return ref.read(databaseServiceProvider).getData();
    });
  }
}
