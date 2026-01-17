import 'package:flutter/foundation.dart';

class ScanDataModel {
  final String content;
  final Uint8List image;
  final int date;
  final String type;
  final int? id;

  const ScanDataModel({
    required this.content,
    required this.image,
    required this.date,
    this.type = 'text',
    this.id,
  });

  ScanDataModel copyWith({
    String? content,
    Uint8List? image,
    int? date,
    String? type,
    int? id,
  }) {
    return ScanDataModel(
      content: content ?? this.content,
      image: image ?? this.image,
      date: date ?? this.date,
      type: type ?? this.type,
      id: id ?? this.id,
    );
  }

  @override
  bool operator ==(Object other) {
    if (identical(this, other)) return true;
    return other is ScanDataModel &&
        other.content == content &&
        other.date == date &&
        other.type == type &&
        other.id == id &&
        listEquals(other.image, image);
  }

  @override
  int get hashCode {
    return content.hashCode ^
        image.hashCode ^
        date.hashCode ^
        type.hashCode ^
        id.hashCode;
  }
}
