import '../models/tanaman.dart';
import '../models/sensor_history.dart';

class TanamanRepository {
  TanamanRepository._internal() {
    _seed();
  }
  static final TanamanRepository instance = TanamanRepository._internal();

  final List<Tanaman> _daftar = [];

  void _seed() {
    final padi = Tanaman(
      id: '1',
      nama: 'Padi Sawah Blok A',
      jenis: 'Padi',
      metodeIrigasi: 'Genangan',
      tanggalTanam: DateTime.now().subtract(const Duration(days: 20)),
      jadwalPenyiraman: '06:00',
      kelembaban: 68,
      suhu: 27,
    );
    final cabai = Tanaman(
      id: '2',
      nama: 'Cabai Rawit Blok B',
      jenis: 'Cabai',
      metodeIrigasi: 'Tetes',
      tanggalTanam: DateTime.now().subtract(const Duration(days: 10)),
      jadwalPenyiraman: '07:00',
      kelembaban: 45,
      suhu: 30,
    );
    _daftar.addAll([padi, cabai]);
    for (final t in _daftar) {
      t.riwayat.add(SensorHistory(
        tanamanId: t.id,
        kelembaban: t.kelembaban,
        suhu: t.suhu,
        waktu: DateTime.now(),
      ));
    }
  }

  List<Tanaman> getAll() => _daftar;

  Tanaman? getById(String id) {
    try {
      return _daftar.firstWhere((t) => t.id == id);
    } catch (_) {
      return null;
    }
  }

  void tambah(Tanaman tanaman) {
    tanaman.riwayat.add(SensorHistory(
      tanamanId: tanaman.id,
      kelembaban: tanaman.kelembaban,
      suhu: tanaman.suhu,
      waktu: DateTime.now(),
    ));
    _daftar.add(tanaman);
  }

  void update(Tanaman tanaman) {
    final index = _daftar.indexWhere((t) => t.id == tanaman.id);
    if (index != -1) {
      _daftar[index] = tanaman;
    }
  }

  void hapus(String id) {
    _daftar.removeWhere((t) => t.id == id);
  }

  void catatPembacaanSensor(String tanamanId, double kelembaban, double suhu) {
    final tanaman = getById(tanamanId);
    if (tanaman == null) return;
    tanaman.riwayat.add(SensorHistory(
      tanamanId: tanamanId,
      kelembaban: kelembaban,
      suhu: suhu,
      waktu: DateTime.now(),
    ));
    if (tanaman.riwayat.length > 30) {
      tanaman.riwayat.removeAt(0);
    }
  }

  List<SensorHistory> getRiwayatSensor(String tanamanId) {
    final tanaman = getById(tanamanId);
    return tanaman?.riwayat ?? [];
  }

  int get jumlahTanaman => _daftar.length;

  double get rataRataKelembaban {
    if (_daftar.isEmpty) return 0;
    final total = _daftar.fold<double>(0, (sum, t) => sum + t.kelembaban);
    return total / _daftar.length;
  }

  int get jumlahPerluPerhatian =>
      _daftar.where((t) => t.status == 'Perlu Perhatian').length;
}
