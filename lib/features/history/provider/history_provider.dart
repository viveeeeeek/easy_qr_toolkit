import 'package:easy_qr_toolkit/core/database/database_service.dart';
import 'package:easy_qr_toolkit/features/history/provider/history_state.dart';
import 'package:easy_qr_toolkit/features/history/scan_data_model.dart';
import 'package:flutter/foundation.dart';
import 'package:riverpod_annotation/riverpod_annotation.dart';

part 'history_provider.g.dart';


@riverpod
class History extends _$History {
  @override
  FutureOr<HistoryState> build() async {
    final db = ref.watch(databaseServiceProvider);
    final scans = await db.getData();
    return HistoryState(scans: scans);
  }

  Future<void> addScan(ScanDataModel scan) async {
    state = const AsyncValue.loading();
    state = await AsyncValue.guard(() async {
      await ref.read(databaseServiceProvider).addData(scan);
      final scans = await ref.read(databaseServiceProvider).getData();
      return state.value!.copyWith(scans: scans);
    });
  }

  Future<void> deleteScan(int id) async {
    // Optimistic update - remove from local state immediately
    if (state.hasValue) {
      final currentScans = state.value!.scans;
      final updatedScans = currentScans.where((scan) => scan.id != id).toList();
      state = AsyncValue.data(state.value!.copyWith(scans: updatedScans));
    }
    
    // Then delete from database in background
    await ref.read(databaseServiceProvider).deleteData(id);
  }

  Future<void> clearAllScans() async {
    state = const AsyncValue.loading();
    state = await AsyncValue.guard(() async {
      await ref.read(databaseServiceProvider).clearAll();
      return state.value!.copyWith(scans: []);
    });
  }

  void changeFilter(String newFilter) {
    if (state.hasValue) {
      state = AsyncValue.data(state.value!.copyWith(filter: newFilter));
    }
  }

  Future<Uint8List?> getScanImage(int id) {
    return ref.read(databaseServiceProvider).getScanImage(id);
  }

  void setSearchQuery(String query) {
    if (state.hasValue) {
      state = AsyncValue.data(state.value!.copyWith(searchQuery: query));
    }
  }
}
