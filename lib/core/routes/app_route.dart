import 'package:easy_qr_toolkit/core/constants/app_constants.dart';
import 'package:easy_qr_toolkit/features/generator/view/home_view.dart';
import 'package:easy_qr_toolkit/features/scanner/view/qr_scan_view.dart';
import 'package:easy_qr_toolkit/features/history/view/history_view.dart';
import 'package:flutter/material.dart';

final appRoutes = {
  AppRoutes.home: (BuildContext context) => const HomeView(),
  AppRoutes.scan: (BuildContext context) => const QRScanView(),
  AppRoutes.history: (BuildContext context) => const QRScanHistoryView(),
};
