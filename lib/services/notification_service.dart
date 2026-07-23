import 'package:flutter_local_notifications/flutter_local_notifications.dart';
import 'package:timezone/timezone.dart' as tz;
import 'package:timezone/data/latest.dart' as tzdata;

class NotificationService {
  NotificationService._internal();
  static final NotificationService instance = NotificationService._internal();

  final FlutterLocalNotificationsPlugin _plugin =
      FlutterLocalNotificationsPlugin();

  Future<void> init() async {
    tzdata.initializeTimeZones();
    tz.setLocalLocation(tz.getLocation('Asia/Makassar')); // WITA

    const androidInit = AndroidInitializationSettings('@mipmap/ic_launcher');
    const initSettings = InitializationSettings(android: androidInit);
    await _plugin.initialize(initSettings);
  }

  Future<void> tampilkan({
    required String judul,
    required String isi,
    int id = 0,
  }) async {
    const androidDetails = AndroidNotificationDetails(
      'tanimonitor_channel',
      'TaniMonitor Notifikasi',
      channelDescription: 'Notifikasi kondisi lahan dan aktivitas pengguna',
      importance: Importance.high,
      priority: Priority.high,
    );
    const details = NotificationDetails(android: androidDetails);
    await _plugin.show(id, judul, isi, details);
  }

  /// Jadwal reminder harian (misal siram tanaman jam 07:00 & 17:00)
  Future<void> jadwalkanHarian({
    required int id,
    required String judul,
    required String isi,
    required int jam,
    required int menit,
  }) async {
    final now = tz.TZDateTime.now(tz.local);
    var jadwal =
        tz.TZDateTime(tz.local, now.year, now.month, now.day, jam, menit);
    if (jadwal.isBefore(now)) {
      jadwal = jadwal.add(const Duration(days: 1));
    }

    const androidDetails = AndroidNotificationDetails(
      'tanimonitor_channel',
      'TaniMonitor Notifikasi',
      channelDescription: 'Notifikasi kondisi lahan dan aktivitas pengguna',
      importance: Importance.high,
      priority: Priority.high,
    );
    const details = NotificationDetails(android: androidDetails);

    await _plugin.zonedSchedule(
      id,
      judul,
      isi,
      jadwal,
      details,
      uiLocalNotificationDateInterpretation:
          UILocalNotificationDateInterpretation
              .absoluteTime, // <-- tambahan ini
      androidScheduleMode: AndroidScheduleMode.exactAllowWhileIdle,
      matchDateTimeComponents: DateTimeComponents.time,
    );
  }
}
