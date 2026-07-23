import 'package:flutter/material.dart';
import '../services/tanaman_repository.dart';
import 'sensor_history_screen.dart';

class DetailScreen extends StatelessWidget {
  final String tanamanId;
  const DetailScreen({super.key, required this.tanamanId});

  void _bukaRiwayat(BuildContext context, String nama, JenisSensor jenis) {
    Navigator.of(context).push(
      MaterialPageRoute(
        builder: (_) => SensorHistoryScreen(
          tanamanId: tanamanId,
          namaTanaman: nama,
          jenisAwal: jenis,
        ),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    final tanaman = TanamanRepository.instance.getById(tanamanId);

    if (tanaman == null) {
      return Scaffold(
        appBar: AppBar(title: const Text('Detail Tanaman')),
        body: const Center(child: Text('Data tidak ditemukan')),
      );
    }

    return Scaffold(
      appBar: AppBar(
          title: Text(tanaman.nama), backgroundColor: const Color(0xFF2E7D32)),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Card(
              child: Padding(
                padding: const EdgeInsets.all(16),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    _baris('Jenis Tanaman', tanaman.jenis),
                    _baris('Metode Irigasi', tanaman.metodeIrigasi),
                    _baris('Tanggal Tanam',
                        '${tanaman.tanggalTanam.day}/${tanaman.tanggalTanam.month}/${tanaman.tanggalTanam.year}'),
                    _baris('Jadwal Penyiraman', tanaman.jadwalPenyiraman),
                    _baris('Status Hama',
                        tanaman.adaHama ? 'Terdeteksi' : 'Tidak Ada'),
                    _baris('Status Pemantauan',
                        tanaman.aktif ? 'Aktif' : 'Nonaktif'),
                  ],
                ),
              ),
            ),
            const SizedBox(height: 16),
            const Text(
              'Ketuk kartu sensor untuk melihat riwayat dan grafik',
              style: TextStyle(fontSize: 12, color: Colors.grey),
            ),
            const SizedBox(height: 8),
            Row(
              children: [
                Expanded(
                  child: _sensorCard(
                    'Kelembaban Tanah',
                    '${tanaman.kelembaban.toStringAsFixed(0)}%',
                    Icons.water_drop,
                    Colors.blue,
                    () => _bukaRiwayat(
                        context, tanaman.nama, JenisSensor.kelembaban),
                  ),
                ),
                const SizedBox(width: 12),
                Expanded(
                  child: _sensorCard(
                    'Suhu',
                    '${tanaman.suhu.toStringAsFixed(1)}°C',
                    Icons.thermostat,
                    Colors.orange,
                    () => _bukaRiwayat(context, tanaman.nama, JenisSensor.suhu),
                  ),
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }

  Widget _baris(String label, String value) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 4),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          Text(label, style: const TextStyle(color: Colors.grey)),
          Text(value, style: const TextStyle(fontWeight: FontWeight.w600)),
        ],
      ),
    );
  }

  Widget _sensorCard(String label, String value, IconData icon, Color color,
      VoidCallback onTap) {
    return GestureDetector(
      onTap: onTap,
      child: Card(
        child: Padding(
          padding: const EdgeInsets.all(16),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  Icon(icon, color: color),
                  Icon(Icons.chevron_right,
                      color: Colors.grey.shade400, size: 18),
                ],
              ),
              const SizedBox(height: 8),
              Text(value,
                  style: const TextStyle(
                      fontSize: 18, fontWeight: FontWeight.bold)),
              Text(label,
                  style: const TextStyle(fontSize: 12, color: Colors.grey)),
            ],
          ),
        ),
      ),
    );
  }
}
