import 'dart:async';
import 'dart:io';
import 'dart:math';
import 'package:flutter/material.dart';
import '../services/tanaman_repository.dart';
import '../services/profil_state.dart';
import 'data_screen.dart';
import 'profil_screen.dart';
import 'login_screen.dart';

class NotifItem {
  final String judul;
  final String isi;
  final DateTime waktu;
  bool dibaca;

  NotifItem({
    required this.judul,
    required this.isi,
    required this.waktu,
    this.dibaca = false,
  });
}

class DashboardScreen extends StatefulWidget {
  final String username;
  const DashboardScreen({super.key, required this.username});

  @override
  State<DashboardScreen> createState() => _DashboardScreenState();
}

class _DashboardScreenState extends State<DashboardScreen> {
  final _repo = TanamanRepository.instance;
  final _random = Random();
  Timer? _sensorTimer;
  int _tabIndex = 0;
  final Map<String, String> _jadwalTerakhirDiingatkan = {};

  // Palet warna — samain persis dengan preview HTML
  static const _hijauTua = Color(0xFF163C25);
  static const _hijauUtama = Color(0xFF2E7D32);
  static const _krem = Color(0xFFF6F4EE);
  static const _tekstUtama = Color(0xFF1C2620);
  static const _teksLembut = Color(0xFF6B7A6F);
  static const _garis = Color(0xFFE7E4DA);
  static const _biru = Color(0xFF3B7DD8);
  static const _oranye = Color(0xFFC97A2B);
  static const _teal = Color(0xFF2E8C82);
  static const _merah = Color(0xFFD64545);

  final List<NotifItem> _daftarNotif = [];

  int get _jumlahBelumDibaca => _daftarNotif.where((n) => !n.dibaca).length;

  @override
  void initState() {
    super.initState();
    ProfilState.instance.muat();
    _sensorTimer = Timer.periodic(const Duration(seconds: 6), (_) {
      setState(() {
        final sekarang = DateTime.now();
        final jamMenitSekarang =
            '${sekarang.hour.toString().padLeft(2, '0')}:${sekarang.minute.toString().padLeft(2, '0')}';

        for (final tanaman in _repo.getAll()) {
          if (!tanaman.aktif) continue;
          final perubahanKelembaban = (_random.nextDouble() * 10) - 5;
          final perubahanSuhu = (_random.nextDouble() * 2) - 1;
          tanaman.kelembaban =
              (tanaman.kelembaban + perubahanKelembaban).clamp(0, 100);
          tanaman.suhu = (tanaman.suhu + perubahanSuhu).clamp(15, 40);
          _repo.catatPembacaanSensor(
              tanaman.id, tanaman.kelembaban, tanaman.suhu);

          if (tanaman.kelembaban < 30) {
            _tambahNotif(
              judul: 'Sensor Melewati Batas',
              isi:
                  '${tanaman.nama} kelembaban tanah rendah (${tanaman.kelembaban.toStringAsFixed(0)}%)',
            );
          }

          if (tanaman.jadwalPenyiraman == jamMenitSekarang &&
              _jadwalTerakhirDiingatkan[tanaman.id] != jamMenitSekarang) {
            _jadwalTerakhirDiingatkan[tanaman.id] = jamMenitSekarang;
            _tambahNotif(
              judul: 'Jadwal Penyiraman Tiba',
              isi: 'Waktunya menyiram ${tanaman.nama} sekarang',
            );
          }
        }
      });
    });
  }

  void _tambahNotif({required String judul, required String isi}) {
    _daftarNotif.insert(
      0,
      NotifItem(judul: judul, isi: isi, waktu: DateTime.now()),
    );
    if (_daftarNotif.length > 30) {
      _daftarNotif.removeLast();
    }
  }

  void _bukaPanelNotifikasi() {
    setState(() {
      for (final n in _daftarNotif) {
        n.dibaca = true;
      }
    });

    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      backgroundColor: Colors.white,
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(20)),
      ),
      builder: (context) {
        return DraggableScrollableSheet(
          initialChildSize: 0.6,
          minChildSize: 0.3,
          maxChildSize: 0.9,
          expand: false,
          builder: (context, scrollController) {
            return Column(
              children: [
                Container(
                  margin: const EdgeInsets.only(top: 10),
                  width: 40,
                  height: 4,
                  decoration: BoxDecoration(
                    color: Colors.grey.shade300,
                    borderRadius: BorderRadius.circular(4),
                  ),
                ),
                Padding(
                  padding: const EdgeInsets.fromLTRB(20, 14, 12, 8),
                  child: Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      const Text('Notifikasi',
                          style: TextStyle(
                              fontSize: 18,
                              fontWeight: FontWeight.bold,
                              color: _tekstUtama)),
                      if (_daftarNotif.isNotEmpty)
                        TextButton(
                          onPressed: () {
                            setState(() => _daftarNotif.clear());
                            Navigator.pop(context);
                          },
                          style: TextButton.styleFrom(
                              foregroundColor: _hijauUtama),
                          child: const Text('Hapus Semua'),
                        ),
                    ],
                  ),
                ),
                const Divider(height: 1, color: _garis),
                Expanded(
                  child: _daftarNotif.isEmpty
                      ? Center(
                          child: Column(
                            mainAxisSize: MainAxisSize.min,
                            children: [
                              Icon(Icons.notifications_off_outlined,
                                  size: 40, color: Colors.grey.shade300),
                              const SizedBox(height: 8),
                              Text('Belum ada notifikasi',
                                  style:
                                      TextStyle(color: Colors.grey.shade500)),
                            ],
                          ),
                        )
                      : ListView.separated(
                          controller: scrollController,
                          padding: const EdgeInsets.symmetric(vertical: 4),
                          itemCount: _daftarNotif.length,
                          separatorBuilder: (_, __) =>
                              const Divider(height: 1, color: _garis),
                          itemBuilder: (context, index) {
                            final n = _daftarNotif[index];
                            return ListTile(
                              leading: Container(
                                padding: const EdgeInsets.all(8),
                                decoration: BoxDecoration(
                                  color: _hijauUtama.withOpacity(0.1),
                                  shape: BoxShape.circle,
                                ),
                                child: const Icon(Icons.notifications,
                                    color: _hijauUtama, size: 18),
                              ),
                              title: Text(n.judul,
                                  style: const TextStyle(
                                      fontWeight: FontWeight.w600,
                                      fontSize: 14)),
                              subtitle: Padding(
                                padding: const EdgeInsets.only(top: 2),
                                child: Text(n.isi,
                                    style: const TextStyle(fontSize: 12.5)),
                              ),
                              trailing: Text(
                                '${n.waktu.hour.toString().padLeft(2, '0')}:${n.waktu.minute.toString().padLeft(2, '0')}',
                                style: TextStyle(
                                    fontSize: 11, color: Colors.grey.shade500),
                              ),
                            );
                          },
                        ),
                ),
              ],
            );
          },
        );
      },
    );
  }

  @override
  void dispose() {
    _sensorTimer?.cancel();
    super.dispose();
  }

  void _logout() {
    Navigator.of(context).pushAndRemoveUntil(
      MaterialPageRoute(builder: (_) => const LoginScreen()),
      (route) => false,
    );
  }

  // ---------- HEADER ----------
  Widget _buildHeader() {
    return Container(
      width: double.infinity,
      decoration: const BoxDecoration(
        gradient: LinearGradient(
          colors: [_hijauTua, _hijauUtama],
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
        ),
      ),
      child: SafeArea(
        bottom: false,
        child: Padding(
          padding: const EdgeInsets.fromLTRB(20, 12, 20, 40),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  Row(
                    children: [
                      Container(
                        width: 30,
                        height: 30,
                        decoration: BoxDecoration(
                          color: Colors.white.withOpacity(0.14),
                          borderRadius: BorderRadius.circular(9),
                        ),
                        child: const Text('🌱', style: TextStyle(fontSize: 15)),
                      ),
                      const SizedBox(width: 9),
                      const Text(
                        'TaniMonitor',
                        style: TextStyle(
                          color: Colors.white,
                          fontWeight: FontWeight.bold,
                          fontSize: 15.5,
                          letterSpacing: 0.2,
                        ),
                      ),
                    ],
                  ),
                  Row(
                    children: [
                      _headerIconButton(
                        icon: Icons.notifications,
                        badgeCount: _jumlahBelumDibaca,
                        onTap: _bukaPanelNotifikasi,
                        iconColor: const Color(0xFFFFC107),
                      ),
                      const SizedBox(width: 6),
                      _headerIconButton(
                        icon: Icons.logout_outlined,
                        onTap: _logout,
                      ),
                    ],
                  ),
                ],
              ),
              const SizedBox(height: 22),
              Row(
                children: [
                  ValueListenableBuilder<File?>(
                    valueListenable: ProfilState.instance.fotoProfil,
                    builder: (context, fotoFile, _) {
                      return Container(
                        width: 52,
                        height: 52,
                        padding: const EdgeInsets.all(2),
                        decoration: BoxDecoration(
                          shape: BoxShape.circle,
                          border: Border.all(
                              color: Colors.white.withOpacity(0.55),
                              width: 1.5),
                        ),
                        child: Container(
                          decoration: BoxDecoration(
                            shape: BoxShape.circle,
                            color: Colors.white.withOpacity(0.18),
                            image: fotoFile != null
                                ? DecorationImage(
                                    image: FileImage(fotoFile),
                                    fit: BoxFit.cover,
                                  )
                                : null,
                          ),
                          child: fotoFile == null
                              ? const Text('🧑‍🌾',
                                  style: TextStyle(fontSize: 20))
                              : null,
                        ),
                      );
                    },
                  ),
                  const SizedBox(width: 13),
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          'Halo, ${widget.username.isEmpty ? "Petani" : widget.username} 👋',
                          style: const TextStyle(
                            fontSize: 18,
                            fontWeight: FontWeight.bold,
                            color: Colors.white,
                          ),
                          maxLines: 1,
                          overflow: TextOverflow.ellipsis,
                        ),
                        const SizedBox(height: 3),
                        Text(
                          'Ringkasan kondisi lahan Anda hari ini',
                          style: TextStyle(
                            fontSize: 12,
                            color: Colors.white.withOpacity(0.78),
                          ),
                        ),
                      ],
                    ),
                  ),
                ],
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _headerIconButton({
    required IconData icon,
    required VoidCallback onTap,
    int badgeCount = 0,
    Color iconColor = Colors.white,
  }) {
    return GestureDetector(
      onTap: onTap,
      child: Container(
        width: 34,
        height: 34,
        decoration: BoxDecoration(
          color: Colors.white.withOpacity(0.12),
          shape: BoxShape.circle,
        ),
        child: Stack(
          alignment: Alignment.center,
          children: [
            Icon(icon, color: iconColor, size: 17),
            if (badgeCount > 0)
              Positioned(
                top: -2,
                right: -2,
                child: Container(
                  padding: const EdgeInsets.all(3),
                  decoration: BoxDecoration(
                    color: _merah,
                    shape: BoxShape.circle,
                    border: Border.all(color: _hijauTua, width: 2),
                  ),
                  constraints:
                      const BoxConstraints(minWidth: 16, minHeight: 16),
                  child: Text(
                    '$badgeCount',
                    style: const TextStyle(
                      color: Colors.white,
                      fontSize: 9,
                      fontWeight: FontWeight.bold,
                    ),
                    textAlign: TextAlign.center,
                  ),
                ),
              ),
          ],
        ),
      ),
    );
  }

  // ---------- BODY ----------
  Widget _buildDashboardBody() {
    return LayoutBuilder(
      builder: (context, constraints) {
        final isWide = constraints.maxWidth > 600;
        return OrientationBuilder(
          builder: (context, orientation) {
            final crossAxisCount =
                isWide || orientation == Orientation.landscape ? 4 : 2;
            return SingleChildScrollView(
              padding: EdgeInsets.zero,
              child: ConstrainedBox(
                constraints: BoxConstraints(minHeight: constraints.maxHeight),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    _buildHeader(),
                    Transform.translate(
                      offset: const Offset(0, -16),
                      child: Padding(
                        padding: const EdgeInsets.symmetric(horizontal: 16),
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            GridView.count(
                              shrinkWrap: true,
                              physics: const NeverScrollableScrollPhysics(),
                              crossAxisCount: crossAxisCount,
                              mainAxisSpacing: 11,
                              crossAxisSpacing: 11,
                              childAspectRatio: 1.15,
                              children: [
                                _statCard(
                                  label: 'Jumlah Tanaman',
                                  value: '${_repo.jumlahTanaman}',
                                  emoji: '🌿',
                                  color: _hijauUtama,
                                ),
                                _statCard(
                                  label: 'Rata-rata Kelembaban',
                                  value:
                                      '${_repo.rataRataKelembaban.toStringAsFixed(0)}%',
                                  emoji: '💧',
                                  color: _biru,
                                ),
                                _statCard(
                                  label: 'Perlu Perhatian',
                                  value: '${_repo.jumlahPerluPerhatian}',
                                  emoji: '⚠️',
                                  color: _oranye,
                                ),
                                _statCard(
                                  label: 'Status Sensor',
                                  value: 'Aktif',
                                  emoji: '📡',
                                  color: _teal,
                                ),
                              ],
                            ),
                            const SizedBox(height: 24),
                            const Text(
                              'Menu Navigasi',
                              style: TextStyle(
                                fontSize: 14.5,
                                fontWeight: FontWeight.bold,
                                color: _tekstUtama,
                              ),
                            ),
                            const SizedBox(height: 12),
                            Row(
                              children: [
                                Expanded(
                                  child: _menuButton(
                                    label: 'Data Tanaman',
                                    emoji: '📋',
                                    onTap: () {
                                      Navigator.of(context).push(
                                        MaterialPageRoute(
                                            builder: (_) => const DataScreen()),
                                      );
                                    },
                                  ),
                                ),
                                const SizedBox(width: 11),
                                Expanded(
                                  child: _menuButton(
                                    label: 'Profil',
                                    emoji: '👤',
                                    onTap: () {
                                      Navigator.of(context).push(
                                        MaterialPageRoute(
                                            builder: (_) =>
                                                const ProfilScreen()),
                                      );
                                    },
                                  ),
                                ),
                              ],
                            ),
                            const SizedBox(height: 22),
                            _tipsCard(),
                            const SizedBox(height: 28),
                          ],
                        ),
                      ),
                    ),
                  ],
                ),
              ),
            );
          },
        );
      },
    );
  }

  Widget _tipsCard() {
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: _hijauUtama.withOpacity(0.06),
        borderRadius: BorderRadius.circular(16),
        border: Border.all(color: _hijauUtama.withOpacity(0.15)),
      ),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Container(
            width: 34,
            height: 34,
            decoration: BoxDecoration(
              color: _hijauUtama.withOpacity(0.12),
              borderRadius: BorderRadius.circular(10),
            ),
            child: const Text('💡', style: TextStyle(fontSize: 15)),
          ),
          const SizedBox(width: 12),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                const Text(
                  'Tips Hari Ini',
                  style: TextStyle(
                    fontSize: 13,
                    fontWeight: FontWeight.bold,
                    color: _tekstUtama,
                  ),
                ),
                const SizedBox(height: 4),
                Text(
                  'Cek kelembaban tanah rutin tiap pagi supaya tanaman tidak stres akibat kekurangan air.',
                  style: TextStyle(
                    fontSize: 12,
                    color: _teksLembut,
                    height: 1.4,
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _statCard({
    required String label,
    required String value,
    required String emoji,
    required Color color,
  }) {
    return Container(
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(16),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.06),
            blurRadius: 16,
            offset: const Offset(0, 6),
          ),
        ],
      ),
      padding: const EdgeInsets.all(14),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        mainAxisSize: MainAxisSize.min,
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Container(
            width: 32,
            height: 32,
            alignment: Alignment.center,
            decoration: BoxDecoration(
              color: color.withOpacity(0.1),
              borderRadius: BorderRadius.circular(9),
            ),
            child: Text(emoji, style: const TextStyle(fontSize: 15)),
          ),
          const SizedBox(height: 10),
          Text(
            value,
            style: const TextStyle(
                fontSize: 17, fontWeight: FontWeight.bold, color: _tekstUtama),
            maxLines: 1,
            overflow: TextOverflow.ellipsis,
          ),
          const SizedBox(height: 2),
          Text(
            label,
            style:
                const TextStyle(fontSize: 11, color: _teksLembut, height: 1.3),
            maxLines: 2,
            overflow: TextOverflow.ellipsis,
          ),
        ],
      ),
    );
  }

  Widget _menuButton({
    required String label,
    required String emoji,
    required VoidCallback onTap,
  }) {
    return Material(
      color: Colors.white,
      borderRadius: BorderRadius.circular(14),
      child: InkWell(
        onTap: onTap,
        borderRadius: BorderRadius.circular(14),
        child: Container(
          padding: const EdgeInsets.symmetric(vertical: 13, horizontal: 10),
          decoration: BoxDecoration(
            borderRadius: BorderRadius.circular(14),
            border: Border.all(color: _garis),
            boxShadow: [
              BoxShadow(
                color: Colors.black.withOpacity(0.05),
                blurRadius: 12,
                offset: const Offset(0, 4),
              ),
            ],
          ),
          child: Row(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Container(
                width: 26,
                height: 26,
                alignment: Alignment.center,
                decoration: BoxDecoration(
                  color: _hijauUtama.withOpacity(0.1),
                  borderRadius: BorderRadius.circular(7),
                ),
                child: Text(emoji, style: const TextStyle(fontSize: 13)),
              ),
              const SizedBox(width: 8),
              Flexible(
                child: Text(
                  label,
                  style: const TextStyle(
                      color: _hijauUtama,
                      fontWeight: FontWeight.w600,
                      fontSize: 12.5),
                  overflow: TextOverflow.ellipsis,
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  // ---------- BOTTOM NAV ----------
  Widget _buildBottomNav() {
    return Container(
      decoration: BoxDecoration(
        color: Colors.white,
        border: const Border(top: BorderSide(color: _garis)),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.04),
            blurRadius: 16,
            offset: const Offset(0, -6),
          ),
        ],
      ),
      child: SafeArea(
        child: Padding(
          padding: const EdgeInsets.symmetric(vertical: 6),
          child: Row(
            children: [
              _navItem(emoji: '🏠', label: 'Dashboard', index: 0),
              _navItem(emoji: '📋', label: 'Data', index: 1),
              _navItem(emoji: '👤', label: 'Profil', index: 2),
            ],
          ),
        ),
      ),
    );
  }

  Widget _navItem({
    required String emoji,
    required String label,
    required int index,
  }) {
    final aktif = _tabIndex == index;
    return Expanded(
      child: GestureDetector(
        onTap: () => setState(() => _tabIndex = index),
        behavior: HitTestBehavior.opaque,
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Opacity(
              opacity: aktif ? 1.0 : 0.4,
              child: Text(emoji, style: const TextStyle(fontSize: 22)),
            ),
            const SizedBox(height: 4),
            Text(
              label,
              style: TextStyle(
                fontSize: 10.5,
                fontWeight: aktif ? FontWeight.w700 : FontWeight.normal,
                color: aktif ? _hijauUtama : const Color(0xFFA6AFA3),
              ),
            ),
          ],
        ),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    final pages = [
      _buildDashboardBody(),
      const DataScreen(embedded: true),
      const ProfilScreen(embedded: true),
    ];

    return Scaffold(
      backgroundColor: _krem,
      body: pages[_tabIndex],
      bottomNavigationBar: _buildBottomNav(),
    );
  }
}
