import 'package:flutter/material.dart';
import '../models/tanaman.dart';
import '../services/tanaman_repository.dart';

class FormScreen extends StatefulWidget {
  final Tanaman? tanaman;
  const FormScreen({super.key, this.tanaman});

  @override
  State<FormScreen> createState() => _FormScreenState();
}

class _FormScreenState extends State<FormScreen> {
  final _formKey = GlobalKey<FormState>();
  final _repo = TanamanRepository.instance;

  late TextEditingController _namaController;
  String _jenis = 'Padi';
  String _metodeIrigasi = 'Genangan';
  DateTime _tanggalTanam = DateTime.now();
  TimeOfDay _jadwalPenyiraman = const TimeOfDay(hour: 6, minute: 0);
  bool _adaHama = false;
  bool _aktif = true;

  final List<String> _jenisList = [
    'Padi',
    'Cabai',
    'Jagung',
    'Tomat',
    'Bawang Merah'
  ];
  final List<String> _irigasiList = ['Genangan', 'Tetes', 'Sprinkler'];

  bool get _isEdit => widget.tanaman != null;

  @override
  void initState() {
    super.initState();
    final t = widget.tanaman;
    _namaController = TextEditingController(text: t?.nama ?? '');
    if (t != null) {
      _jenis = t.jenis;
      _metodeIrigasi = t.metodeIrigasi;
      _tanggalTanam = t.tanggalTanam;
      _adaHama = t.adaHama;
      _aktif = t.aktif;
      final parts = t.jadwalPenyiraman.split(':');
      _jadwalPenyiraman =
          TimeOfDay(hour: int.parse(parts[0]), minute: int.parse(parts[1]));
    }
  }

  Future<void> _pilihTanggal() async {
    final hasil = await showDatePicker(
      context: context,
      initialDate: _tanggalTanam,
      firstDate: DateTime(2020),
      lastDate: DateTime.now().add(const Duration(days: 365)),
    );
    if (hasil != null) setState(() => _tanggalTanam = hasil);
  }

  Future<void> _pilihJam() async {
    final hasil =
        await showTimePicker(context: context, initialTime: _jadwalPenyiraman);
    if (hasil != null) setState(() => _jadwalPenyiraman = hasil);
  }

  void _simpan() {
    if (!_formKey.currentState!.validate()) return;

    final jadwalText =
        '${_jadwalPenyiraman.hour.toString().padLeft(2, '0')}:${_jadwalPenyiraman.minute.toString().padLeft(2, '0')}';

    if (_isEdit) {
      final t = widget.tanaman!;
      t.nama = _namaController.text;
      t.jenis = _jenis;
      t.metodeIrigasi = _metodeIrigasi;
      t.tanggalTanam = _tanggalTanam;
      t.jadwalPenyiraman = jadwalText;
      t.adaHama = _adaHama;
      t.aktif = _aktif;
      _repo.update(t);
    } else {
      final baru = Tanaman(
        id: DateTime.now().millisecondsSinceEpoch.toString(),
        nama: _namaController.text,
        jenis: _jenis,
        metodeIrigasi: _metodeIrigasi,
        tanggalTanam: _tanggalTanam,
        jadwalPenyiraman: jadwalText,
        adaHama: _adaHama,
        aktif: _aktif,
      );
      _repo.tambah(baru);
    }

    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
          content: Text(_isEdit
              ? 'Data berhasil diperbarui'
              : 'Data berhasil ditambahkan')),
    );
    Navigator.pop(context);
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text(_isEdit ? 'Edit Tanaman' : 'Tambah Tanaman'),
        backgroundColor: const Color(0xFF2E7D32),
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(16),
        child: Form(
          key: _formKey,
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              TextFormField(
                controller: _namaController,
                decoration: const InputDecoration(
                  labelText: 'Nama Tanaman / Lahan',
                  border: OutlineInputBorder(),
                ),
                validator: (v) =>
                    (v == null || v.isEmpty) ? 'Nama wajib diisi' : null,
              ),
              const SizedBox(height: 16),
              DropdownButtonFormField<String>(
                value: _jenis,
                decoration: const InputDecoration(
                    labelText: 'Jenis Tanaman', border: OutlineInputBorder()),
                items: _jenisList
                    .map((jenis) =>
                        DropdownMenuItem(value: jenis, child: Text(jenis)))
                    .toList(),
                onChanged: (value) => setState(() => _jenis = value ?? _jenis),
              ),
              const SizedBox(height: 16),
              const Text('Metode Irigasi',
                  style: TextStyle(fontWeight: FontWeight.bold)),
              ..._irigasiList.map(
                (metode) => RadioListTile<String>(
                  value: metode,
                  groupValue: _metodeIrigasi,
                  title: Text(metode),
                  onChanged: (value) =>
                      setState(() => _metodeIrigasi = value ?? _metodeIrigasi),
                ),
              ),
              const SizedBox(height: 8),
              ListTile(
                contentPadding: EdgeInsets.zero,
                title: const Text('Tanggal Tanam'),
                subtitle: Text(
                    '${_tanggalTanam.day}/${_tanggalTanam.month}/${_tanggalTanam.year}'),
                trailing: const Icon(Icons.calendar_today),
                onTap: _pilihTanggal,
              ),
              ListTile(
                contentPadding: EdgeInsets.zero,
                title: const Text('Jadwal Penyiraman'),
                subtitle: Text(_jadwalPenyiraman.format(context)),
                trailing: const Icon(Icons.access_time),
                onTap: _pilihJam,
              ),
              CheckboxListTile(
                contentPadding: EdgeInsets.zero,
                value: _adaHama,
                title: const Text('Terdeteksi Hama'),
                onChanged: (value) => setState(() => _adaHama = value ?? false),
              ),
              SwitchListTile(
                contentPadding: EdgeInsets.zero,
                value: _aktif,
                title: const Text('Status Aktif Dipantau'),
                onChanged: (value) => setState(() => _aktif = value),
              ),
              const SizedBox(height: 20),
              SizedBox(
                width: double.infinity,
                child: ElevatedButton(
                  style: ElevatedButton.styleFrom(
                    backgroundColor: const Color(0xFF2E7D32),
                    padding: const EdgeInsets.symmetric(vertical: 14),
                  ),
                  onPressed: _simpan,
                  child: Text(_isEdit ? 'Simpan Perubahan' : 'Tambah Data',
                      style: const TextStyle(color: Colors.white)),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
