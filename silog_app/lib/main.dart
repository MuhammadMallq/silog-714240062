import 'package:flutter/material.dart';
import 'data/preferensi.dart';
import 'tampilan/daftar_pengiriman_page.dart';

// Notifier global untuk perubahan mode tema secara reaktif
final ValueNotifier<ThemeMode> temaAppNotifier = ValueNotifier<ThemeMode>(ThemeMode.light);

void main() async {
  WidgetsFlutterBinding.ensureInitialized();
  // Tugas 3: Ambil preferensi mode gelap saat aplikasi pertama kali dimuat
  final pref = Preferensi();
  final isDark = await pref.modeGelap();
  temaAppNotifier.value = isDark ? ThemeMode.dark : ThemeMode.light;
  runApp(const SiLogApp());
}

class SiLogApp extends StatelessWidget {
  const SiLogApp({super.key});

  @override
  Widget build(BuildContext context) {
    return ValueListenableBuilder<ThemeMode>(
      valueListenable: temaAppNotifier,
      builder: (context, modeTema, _) {
        return MaterialApp(
          title: 'SiLog',
          debugShowCheckedModeBanner: false,
          themeMode: modeTema,
          theme: ThemeData(
            useMaterial3: true,
            brightness: Brightness.light,
            colorScheme: ColorScheme.fromSeed(
              seedColor: const Color(0xFF1B5E20),
              brightness: Brightness.light,
            ),
            cardTheme: CardThemeData(
              elevation: 1,
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(12),
              ),
            ),
            appBarTheme: const AppBarTheme(centerTitle: true),
          ),
          darkTheme: ThemeData(
            useMaterial3: true,
            brightness: Brightness.dark,
            colorScheme: ColorScheme.fromSeed(
              seedColor: const Color(0xFF1B5E20),
              brightness: Brightness.dark,
            ),
            cardTheme: CardThemeData(
              elevation: 1,
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(12),
              ),
            ),
            appBarTheme: const AppBarTheme(centerTitle: true),
          ),
          home: const DaftarPengirimanPage(),
        );
      },
    );
  }
}
