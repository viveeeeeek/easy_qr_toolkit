import 'package:flutter/foundation.dart';
import 'package:pretty_qr_code/pretty_qr_code.dart';
import 'package:riverpod_annotation/riverpod_annotation.dart';

part 'generator_provider.g.dart';

class GeneratorState {
  final String data;
  final QrImage? qrImageObject;
  final Uint8List? generatedQrImage;

  const GeneratorState({
    this.data = '',
    this.qrImageObject,
    this.generatedQrImage,
  });

  GeneratorState copyWith({
    String? data,
    QrImage? qrImageObject,
    Uint8List? generatedQrImage,
  }) {
    return GeneratorState(
      data: data ?? this.data,
      qrImageObject: qrImageObject ?? this.qrImageObject,
      generatedQrImage: generatedQrImage ?? this.generatedQrImage,
    );
  }

  @override
  bool operator ==(Object other) {
    if (identical(this, other)) return true;
    return other is GeneratorState &&
        other.data == data &&
        other.qrImageObject == qrImageObject &&
        listEquals(other.generatedQrImage, generatedQrImage);
  }

  @override
  int get hashCode => data.hashCode ^ qrImageObject.hashCode ^ generatedQrImage.hashCode;
}

@riverpod
class Generator extends _$Generator {
  @override
  GeneratorState build() {
    return const GeneratorState();
  }

  void updateState({
    String? data,
    QrImage? qrImageObject,
    Uint8List? generatedQrImage,
  }) {
    state = state.copyWith(
      data: data,
      qrImageObject: qrImageObject,
      generatedQrImage: generatedQrImage,
    );
  }

  void reset() {
    state = const GeneratorState();
  }
}
