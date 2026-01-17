import 'package:easy_qr_toolkit/core/extensions/sizedbox.dart';
import 'package:flutter/material.dart';

class ResultDataSection extends StatelessWidget {
  final String content;

  const ResultDataSection({super.key, required this.content});

  @override
  Widget build(BuildContext context) {
    return Column(
      children: [
        33.h,
        Text(
          content,
          style: const TextStyle(fontSize: 20),
          textAlign: TextAlign.center,
        ),
        20.h,
        const Divider(
          indent: 25,
          endIndent: 25,
        ),
      ],
    );
  }
}
