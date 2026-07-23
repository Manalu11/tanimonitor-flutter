import 'dart:io';
import 'package:flutter/material.dart';
import 'package:file_picker/file_picker.dart';
import 'package:path_provider/path_provider.dart';
import '../services/profil_state.dart';

class ProfilScreen extends StatefulWidget {
  final bool embedded;
  const ProfilScreen({super.key, this.embedded = false});

  @override
  State<ProfilScreen> createState() => _ProfilScreenState();
}

class _ProfilScreenState extends State<ProfilScreen> {
  @override
  void initState() {
    super.initState();
    ProfilState.instance.muat();
  }

  Future<void> _pilihFoto() async {
    final hasil = await FilePicker.platform.pickFiles(
      type: FileType.image,
      withData: true,
    );
    if (hasil != null && hasil.files.single.bytes != null) {
      final bytes = hasil.files.single.bytes!;
      final dir = await getApplicationDocumentsDirectory();
      final namaFile =
          'foto_profil${DateTime.now().millisecondsSinceEpoch}.jpg';
      final file = File('${dir.path}/$namaFile');
      await file.writeAsBytes(bytes);
      await ProfilState.instance.simpan(file);
    }
  }

  @override
  Widget build(BuildContext context) {
    final lebarLayar = MediaQuery.of(context).size.width;
    final radiusAvatar = lebarLayar < 400 ? 45.0 : 60.0;

    final body = SingleChildScrollView(
      padding: const EdgeInsets.all(24),
      child: Column(
        children: [
          ValueListenableBuilder<File?>(
            valueListenable: ProfilState.instance.fotoProfil,
            builder: (context, fotoFile, _) {
              return GestureDetector(
                onTap: _pilihFoto,
                child: Stack(
                  children: [
                    CircleAvatar(
                      radius: radiusAvatar,
                      backgroundColor: const Color(0xFF2E7D32),
                      backgroundImage:
                          fotoFile != null ? FileImage(fotoFile) : null,
                      child: fotoFile == null
                          ? Icon(Icons.person,
                              size: radiusAvatar, color: Colors.white)
                          : null,
                    ),
                    Positioned(
                      bottom: 0,
                      right: 0,
                      child: Container(
                        padding: const EdgeInsets.all(6),
                        decoration: const BoxDecoration(
                          color: Color(0xFF2E7D32),
                          shape: BoxShape.circle,
                        ),
                        child: const Icon(Icons.camera_alt,
                            color: Colors.white, size: 16),
                      ),
                    ),
                  ],
                ),
              );
            },
          ),
          const SizedBox(height: 8),
          const Text('Ketuk foto untuk mengubah',
              style: TextStyle(fontSize: 12, color: Colors.grey)),
          const SizedBox(height: 20),
          Card(
            child: Padding(
              padding: const EdgeInsets.all(16),
              child: Column(
                children: const [
                  _InfoRow(label: 'Nama', value: 'Marcahaya'),
                  Divider(),
                  _InfoRow(label: 'NIM', value: '202312035'),
                  Divider(),
                  _InfoRow(label: 'Program Studi', value: 'Teknik Informatika'),
                  Divider(),
                  _InfoRow(
                      label: 'Mata Kuliah',
                      value: 'Pemrograman Perangkat Bergerak'),
                ],
              ),
            ),
          ),
        ],
      ),
    );

    if (widget.embedded) return body;

    return Scaffold(
      appBar: AppBar(
          title: const Text('Profil'),
          backgroundColor: const Color(0xFF2E7D32)),
      body: body,
    );
  }
}

class _InfoRow extends StatelessWidget {
  final String label;
  final String value;
  const _InfoRow({required this.label, required this.value});

  @override
  Widget build(BuildContext context) {
    return Row(
      mainAxisAlignment: MainAxisAlignment.spaceBetween,
      children: [
        Text(label, style: const TextStyle(color: Colors.grey)),
        const SizedBox(width: 12),
        Flexible(
          child: Text(
            value,
            style: const TextStyle(fontWeight: FontWeight.w600),
            textAlign: TextAlign.end,
          ),
        ),
      ],
    );
  }
}
