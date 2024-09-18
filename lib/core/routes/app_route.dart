import 'package:easy_qr_toolkit/views/home/home_view.dart';
import 'package:easy_qr_toolkit/views/qr_scan/qr_scan_view.dart';
import 'package:easy_qr_toolkit/views/qr_scan_history/qr_scan_history_view.dart';
import 'package:flutter/material.dart';

final appRoutes = {
  '/home': (BuildContext context) => const HomeView(),
  '/scan': (BuildContext context) => const QRScanView(),
  '/scan_history': (BuildContext context) => const QRScanHistoryView(),
};
