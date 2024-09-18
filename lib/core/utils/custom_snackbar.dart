import 'package:easy_qr_toolkit/core/extensions/color_extension.dart';
import 'package:flutter/material.dart';

/// custom snackbar for reusable
/// show snackbar
void showSnackBar({
  required BuildContext context,
  required String message,
  bool isError = false,
}) {
  ScaffoldMessenger.of(context).showSnackBar(
    SnackBar(
      content: Text(
        message,
        style: TextStyle(
          color: context.onTertiaryContainer,
        ),
      ),
      backgroundColor: isError ? Colors.red : context.tertiaryContainer,
    ),
  );
}
