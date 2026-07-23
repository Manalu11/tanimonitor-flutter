import 'sensor_history.dart';

class Tanaman {
  String id;
  String nama;
  String jenis;
  String metodeIrigasi;
  DateTime tanggalTanam;
  String jadwalPenyiraman;
  bool adaHama;
  bool aktif;
  double kelembaban;
  double suhu;
  List<SensorHistory> riwayat;

  Tanaman({
    required this.id,
    required this.nama,
    required this.jenis,
    required this.metodeIrigasi,
    required this.tanggalTanam,
    required this.jadwalPenyiraman,
    this.adaHama = false,
    this.aktif = true,
    this.kelembaban = 60,
    this.suhu = 28,
    List<SensorHistory>? riwayat,
  }) : riwayat = riwayat ?? [];

  String get status {
    if (!aktif) return 'Nonaktif';
    if (kelembaban < 30) return 'Perlu Perhatian';
    return 'Sehat';
  }
}
