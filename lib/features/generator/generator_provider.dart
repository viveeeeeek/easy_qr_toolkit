import 'package:flutter/foundation.dart';
import 'package:pretty_qr_code/pretty_qr_code.dart';
import 'package:riverpod_annotation/riverpod_annotation.dart';

import '../../core/services/qr_service.dart';

part 'generator_provider.g.dart';

enum QrShape {
  smooth,
  rounded,
  sharp,
}

class GeneratorState {
  final String data;
  final QrShape shape;
  final Uint8List? generatedQrImage;

  const GeneratorState({
    this.data = '',
    this.shape = QrShape.smooth,
    this.generatedQrImage,
  });

  GeneratorState copyWith({
    String? data,
    QrShape? shape,
    Uint8List? generatedQrImage,
  }) {
    return GeneratorState(
      data: data ?? this.data,
      shape: shape ?? this.shape,
      generatedQrImage: generatedQrImage ?? this.generatedQrImage,
    );
  }

  @override
  bool operator ==(Object other) {
    if (identical(this, other)) return true;
    return other is GeneratorState &&
        other.data == data &&
        other.shape == shape &&
        listEquals(other.generatedQrImage, generatedQrImage);
  }

  @override
  int get hashCode =>
      data.hashCode ^ shape.hashCode ^ generatedQrImage.hashCode;
}

@riverpod
class Generator extends _$Generator {
  @override
  GeneratorState build() {
    return const GeneratorState();
  }

  void updateState({
    String? data,
    Uint8List? generatedQrImage,
    QrShape? shape,
  }) {
    state = state.copyWith(
      data: data,
      generatedQrImage: generatedQrImage,
      shape: shape,
    );
  }

  Future<void> generateImage([String? overrideData]) async {
    final data = overrideData ?? state.data;
    if (data.isEmpty) return;

    final qrService = ref.read(qrServiceProvider);

    // Initial state update
    updateState(data: data);

    final paddedQrBytes = await qrService.generateFullQrImage(
      data: data,
      shape: state.shape,
    );

    // Race condition check: Ensure the data hasn't changed while we were generating
    if (state.data != data || paddedQrBytes == null) return;

    updateState(
      data: data,
      generatedQrImage: paddedQrBytes,
    );
  }

  void reset() {
    state = const GeneratorState();
  }
}
