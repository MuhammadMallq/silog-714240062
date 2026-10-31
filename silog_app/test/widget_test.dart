// This is a basic Flutter widget test.
//
// To perform an interaction with a widget in your test, use the WidgetTester
// utility in the flutter_test package. For example, you can send tap and scroll
// gestures. You can also use WidgetTester to find child widgets in the widget
// tree, read text, and verify that the values of widget properties are correct.

import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';

import 'package:silog_app/main.dart';

void main() {
  testWidgets('SiLog smoke test', (WidgetTester tester) async {
    // Build our app and trigger a frame.
    await tester.pumpWidget(const SiLogApp());

    // Verify AppBar title is present.
    expect(find.text('Daftar Pengiriman'), findsOneWidget);

    // Verify Tabs are present.
    expect(find.text('Semua'), findsOneWidget);
    expect(find.text('Dalam Perjalanan'), findsOneWidget);
    expect(find.text('Diterima'), findsOneWidget);

    // Verify Summary widget is present.
    expect(find.text('Total Kirim'), findsOneWidget);
    expect(find.text('Total Nilai'), findsOneWidget);
  });
}
