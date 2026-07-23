import 'dart:math';
import 'package:workmanager/workmanager.dart';
import 'notification_service.dart';

const String taskCekKelembapan = 'cekKelembapanTask';

@pragma('vm:entry-point')
void callbackDispatcher() {
  Workmanager().executeTask((task, inputData) async {
    if (task == taskCekKelembapan) {
      await NotificationService.instance.init();

      final kelembapan = Random().nextInt(100);

      if (kelembapan < 30) {
        await NotificationService.instance.tampilkan(
          id: 99,
          judul: 'Kelembapan Rendah!',
          isi: 'Kelembapan tanah $kelembapan%. Segera siram tanaman kamu.',
        );
      }
    }
    return Future.value(true);
  });
}