import 'dart:io';
import 'package:flutter/foundation.dart';
import 'package:shared_preferences/shared_preferences.dart';

/// State global sederhana buat foto profil, dipakai bareng
/// oleh ProfilScreen dan DashboardScreen supaya foto yang
/// baru diupload otomatis muncul juga di header dashboard.
class ProfilState {
  ProfilState._();
  static final ProfilState instance = ProfilState._();

  static const _prefKey = 'foto_profil_path';

  /// Dengerin ini pakai ValueListenableBuilder di widget manapun
  /// yang mau nampilin foto profil.
  final ValueNotifier<File?> fotoProfil = ValueNotifier<File?>(null);

  /// Panggil sekali waktu screen dibuka (initState) buat load
  /// foto yang udah tersimpan sebelumnya.
  Future<void> muat() async {
    final prefs = await SharedPreferences.getInstance();
    final path = prefs.getString(_prefKey);
    if (path != null && File(path).existsSync()) {
      fotoProfil.value = File(path);
    }
  }

  /// Panggil setelah user pilih foto baru.
  Future<void> simpan(File file) async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.setString(_prefKey, file.path);
    fotoProfil.value = file;
  }
}
