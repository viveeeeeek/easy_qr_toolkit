import 'package:flutter/foundation.dart';
import 'package:freezed_annotation/freezed_annotation.dart';

part 'scan_data_model.freezed.dart';

@freezed
class ScanDataModel with _$ScanDataModel {
  const factory ScanDataModel({
    required String content,
    Uint8List? image,
    required int date,
    @Default('text') String type,
    int? id,
  }) = _ScanDataModel;

  factory ScanDataModel.fromMap(Map<String, dynamic> map) {
    return ScanDataModel(
      id: map['id'] as int?,
      content: map['content'] as String,
      date: map['date'] as int,
      image: map['image'] as Uint8List?,
      type: (map['type'] as String?) ?? 'text',
    );
  }
}
