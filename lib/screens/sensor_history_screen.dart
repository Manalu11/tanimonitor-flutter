import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import 'package:fl_chart/fl_chart.dart';
import '../models/sensor_history.dart';
import '../services/tanaman_repository.dart';

enum JenisSensor { kelembaban, suhu }

class SensorHistoryScreen extends StatefulWidget {
  final String tanamanId;
  final String namaTanaman;
  final JenisSensor jenisAwal;

  const SensorHistoryScreen({
    super.key,
    required this.tanamanId,
    required this.namaTanaman,
    this.jenisAwal = JenisSensor.kelembaban,
  });

  @override
  State<SensorHistoryScreen> createState() => _SensorHistoryScreenState();
}

class _SensorHistoryScreenState extends State<SensorHistoryScreen> {
  final _repo = TanamanRepository.instance;
  late JenisSensor _jenis;

  @override
  void initState() {
    super.initState();
    _jenis = widget.jenisAwal;
  }

  Color get _warna =>
      _jenis == JenisSensor.kelembaban ? Colors.blue : Colors.orange;
  String get _label =>
      _jenis == JenisSensor.kelembaban ? 'Kelembaban Tanah (%)' : 'Suhu (°C)';

  double _nilaiDari(SensorHistory h) =>
      _jenis == JenisSensor.kelembaban ? h.kelembaban : h.suhu;

  @override
  Widget build(BuildContext context) {
    final riwayat = _repo.getRiwayatSensor(widget.tanamanId);

    return Scaffold(
      appBar: AppBar(
        title: Text('Riwayat Sensor - ${widget.namaTanaman}'),
        backgroundColor: const Color(0xFF2E7D32),
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            SegmentedButton<JenisSensor>(
              segments: const [
                ButtonSegment(
                  value: JenisSensor.kelembaban,
                  label: Text('Kelembaban'),
                  icon: Icon(Icons.water_drop),
                ),
                ButtonSegment(
                  value: JenisSensor.suhu,
                  label: Text('Suhu'),
                  icon: Icon(Icons.thermostat),
                ),
              ],
              selected: {_jenis},
              onSelectionChanged: (value) =>
                  setState(() => _jenis = value.first),
            ),
            const SizedBox(height: 20),
            Text(_label,
                style:
                    const TextStyle(fontWeight: FontWeight.bold, fontSize: 16)),
            const SizedBox(height: 12),
            if (riwayat.isEmpty)
              const Padding(
                padding: EdgeInsets.symmetric(vertical: 40),
                child: Center(child: Text('Belum ada data riwayat sensor')),
              )
            else
              SizedBox(
                height: 240,
                child: LineChart(
                  LineChartData(
                    minY: 0,
                    maxY: _jenis == JenisSensor.kelembaban ? 100 : 45,
                    gridData: const FlGridData(show: true),
                    titlesData: FlTitlesData(
                      rightTitles: const AxisTitles(
                          sideTitles: SideTitles(showTitles: false)),
                      topTitles: const AxisTitles(
                          sideTitles: SideTitles(showTitles: false)),
                      leftTitles: AxisTitles(
                        sideTitles:
                            SideTitles(showTitles: true, reservedSize: 32),
                      ),
                      bottomTitles: AxisTitles(
                        sideTitles: SideTitles(
                          showTitles: true,
                          reservedSize: 28,
                          interval: (riwayat.length / 4)
                              .clamp(1, double.infinity)
                              .toDouble(),
                          getTitlesWidget: (value, meta) {
                            final index = value.toInt();
                            if (index < 0 || index >= riwayat.length)
                              return const SizedBox();
                            final waktu = riwayat[index].waktu;
                            return Padding(
                              padding: const EdgeInsets.only(top: 6),
                              child: Text(
                                DateFormat('HH:mm').format(waktu),
                                style: const TextStyle(fontSize: 10),
                              ),
                            );
                          },
                        ),
                      ),
                    ),
                    borderData: FlBorderData(show: true),
                    lineBarsData: [
                      LineChartBarData(
                        spots: List.generate(
                          riwayat.length,
                          (i) => FlSpot(i.toDouble(), _nilaiDari(riwayat[i])),
                        ),
                        isCurved: true,
                        color: _warna,
                        barWidth: 3,
                        dotData: const FlDotData(show: true),
                        belowBarData: BarAreaData(
                            show: true, color: _warna.withOpacity(0.15)),
                      ),
                    ],
                  ),
                ),
              ),
            const SizedBox(height: 24),
            const Text('Daftar Pembacaan',
                style: TextStyle(fontWeight: FontWeight.bold, fontSize: 16)),
            const SizedBox(height: 8),
            ListView.separated(
              shrinkWrap: true,
              physics: const NeverScrollableScrollPhysics(),
              itemCount: riwayat.length,
              separatorBuilder: (_, __) => const Divider(height: 1),
              itemBuilder: (context, index) {
                final h = riwayat[riwayat.length - 1 - index];
                return ListTile(
                  contentPadding: EdgeInsets.zero,
                  leading: Icon(
                    _jenis == JenisSensor.kelembaban
                        ? Icons.water_drop
                        : Icons.thermostat,
                    color: _warna,
                  ),
                  title: Text(
                    _jenis == JenisSensor.kelembaban
                        ? '${h.kelembaban.toStringAsFixed(1)}%'
                        : '${h.suhu.toStringAsFixed(1)}°C',
                    style: const TextStyle(fontWeight: FontWeight.w600),
                  ),
                  subtitle:
                      Text(DateFormat('dd MMM yyyy, HH:mm:ss').format(h.waktu)),
                );
              },
            ),
          ],
        ),
      ),
    );
  }
}
