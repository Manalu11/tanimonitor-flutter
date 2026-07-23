import 'package:flutter/material.dart';
import 'package:workmanager/workmanager.dart';
import 'services/notification_service.dart';
import 'services/background_service.dart';
import 'screens/splash_screen.dart';

void main() async {
  WidgetsFlutterBinding.ensureInitialized();
  await NotificationService.instance.init();

  // Reminder siram tanaman tiap hari jam 07:00 & 17:00
  await NotificationService.instance.jadwalkanHarian(
    id: 1,
    judul: 'Waktunya Siram Tanaman 🌱',
    isi: 'Jangan lupa siram tanaman kamu pagi ini.',
    jam: 7,
    menit: 0,
  );
  await NotificationService.instance.jadwalkanHarian(
    id: 2,
    judul: 'Waktunya Siram Tanaman 🌱',
    isi: 'Jangan lupa siram tanaman kamu sore ini.',
    jam: 17,
    menit: 0,
  );

  // Background check kelembapan tiap 15 menit (minimum interval Android)
  await Workmanager().initialize(callbackDispatcher, isInDebugMode: false);
  await Workmanager().registerPeriodicTask(
    'task-cek-kelembapan',
    taskCekKelembapan,
    frequency: const Duration(minutes: 15),
  );

  runApp(const TaniMonitorApp());
}

class TaniMonitorApp extends StatelessWidget {
  const TaniMonitorApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'TaniMonitor',
      debugShowCheckedModeBanner: false,
      theme: ThemeData(
        primaryColor: const Color(0xFF2E7D32),
        colorScheme: ColorScheme.fromSeed(seedColor: const Color(0xFF2E7D32)),
        useMaterial3: true,
      ),
      home: const SplashScreen(),
    );
  }
}
