import 'package:flutter/foundation.dart';

class ScanDataModel {
  final String content;
  final Uint8List image;
  final int date;
  final int? id;

  ScanDataModel({
    required this.content,
    required this.image,
    required this.date,
    this.id,
  });

  factory ScanDataModel.fromMap(Map<String, dynamic> map) {
    return ScanDataModel(
      content: map['content'],
      image: map['image'],
      date: map['date'],
      id: map['id'] ?? 0,
    );
  }

  Map<String, dynamic> toMap() {
    return {
      'content': content,
      'image': image,
      'date': date,
      'id': id,
    };
  }
}
