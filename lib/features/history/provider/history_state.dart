import 'package:easy_qr_toolkit/features/history/scan_data_model.dart';

class HistoryState {
  final List<ScanDataModel> scans;
  final String filter;
  final String searchQuery;

  const HistoryState({
    required this.scans,
    this.filter = 'All',
    this.searchQuery = '',
  });

  HistoryState copyWith({
    List<ScanDataModel>? scans,
    String? filter,
    String? searchQuery,
  }) {
    return HistoryState(
      scans: scans ?? this.scans,
      filter: filter ?? this.filter,
      searchQuery: searchQuery ?? this.searchQuery,
    );
  }
}
