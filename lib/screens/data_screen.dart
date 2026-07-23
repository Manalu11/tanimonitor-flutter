import 'package:flutter/material.dart';
import '../models/tanaman.dart';
import '../services/tanaman_repository.dart';
import 'form_screen.dart';
import 'detail_screen.dart';

class DataScreen extends StatefulWidget {
  final bool embedded;
  const DataScreen({super.key, this.embedded = false});

  @override
  State<DataScreen> createState() => _DataScreenState();
}

class _DataScreenState extends State<DataScreen> {
  final _repo = TanamanRepository.instance;
  final _searchController = TextEditingController();
  String _query = '';
  String _filterStatus = 'Semua';

  final List<String> _statusList = [
    'Semua',
    'Sehat',
    'Perlu Perhatian',
    'Nonaktif'
  ];

  @override
  void dispose() {
    _searchController.dispose();
    super.dispose();
  }

  void _hapus(Tanaman tanaman) {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Hapus Data'),
        content: Text('Yakin ingin menghapus ${tanaman.nama}?'),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: const Text('Batal'),
          ),
          TextButton(
            onPressed: () {
              setState(() => _repo.hapus(tanaman.id));
              Navigator.pop(context);
              ScaffoldMessenger.of(context).showSnackBar(
                SnackBar(content: Text('${tanaman.nama} berhasil dihapus')),
              );
            },
            child: const Text('Hapus', style: TextStyle(color: Colors.red)),
          ),
        ],
      ),
    );
  }

  Color _statusColor(String status) {
    switch (status) {
      case 'Sehat':
        return Colors.green;
      case 'Perlu Perhatian':
        return Colors.orange;
      default:
        return Colors.grey;
    }
  }

  List<Tanaman> _daftarTersaring() {
    var daftar = _repo.getAll();

    if (_query.isNotEmpty) {
      final q = _query.toLowerCase();
      daftar = daftar
          .where((t) =>
              t.nama.toLowerCase().contains(q) ||
              t.jenis.toLowerCase().contains(q))
          .toList();
    }

    if (_filterStatus != 'Semua') {
      daftar = daftar.where((t) => t.status == _filterStatus).toList();
    }

    return daftar;
  }

  Widget _buildSearchAndFilter() {
    return Padding(
      padding: const EdgeInsets.fromLTRB(12, 12, 12, 0),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          TextField(
            controller: _searchController,
            onChanged: (value) => setState(() => _query = value),
            decoration: InputDecoration(
              hintText: 'Cari nama atau jenis tanaman...',
              hintStyle: const TextStyle(fontSize: 13),
              prefixIcon: const Icon(Icons.search),
              suffixIcon: _query.isEmpty
                  ? null
                  : IconButton(
                      icon: const Icon(Icons.clear),
                      onPressed: () {
                        _searchController.clear();
                        setState(() => _query = '');
                      },
                    ),
              border:
                  OutlineInputBorder(borderRadius: BorderRadius.circular(10)),
              contentPadding:
                  const EdgeInsets.symmetric(vertical: 0, horizontal: 12),
            ),
          ),
          const SizedBox(height: 10),
          SizedBox(
            height: 36,
            child: ListView.separated(
              scrollDirection: Axis.horizontal,
              itemCount: _statusList.length,
              separatorBuilder: (_, __) => const SizedBox(width: 8),
              itemBuilder: (context, index) {
                final status = _statusList[index];
                final terpilih = _filterStatus == status;
                return ChoiceChip(
                  label: Text(status, style: const TextStyle(fontSize: 12)),
                  selected: terpilih,
                  selectedColor: const Color(0xFF2E7D32).withOpacity(0.2),
                  onSelected: (_) => setState(() => _filterStatus = status),
                );
              },
            ),
          ),
          const SizedBox(height: 8),
        ],
      ),
    );
  }

  Widget _buildList() {
    final daftar = _daftarTersaring();
    final screenWidth = MediaQuery.of(context).size.width;
    final isNarrow = screenWidth < 360;

    return Column(
      children: [
        _buildSearchAndFilter(),
        Expanded(
          child: daftar.isEmpty
              ? const Center(child: Text('Tidak ada tanaman yang cocok'))
              : ListView.builder(
                  padding: const EdgeInsets.all(12),
                  itemCount: daftar.length,
                  itemBuilder: (context, index) {
                    final tanaman = daftar[index];
                    return Card(
                      margin: const EdgeInsets.only(bottom: 10),
                      child: InkWell(
                        borderRadius: BorderRadius.circular(8),
                        onTap: () async {
                          await Navigator.of(context).push(
                            MaterialPageRoute(
                              builder: (_) =>
                                  DetailScreen(tanamanId: tanaman.id),
                            ),
                          );
                          setState(() {});
                        },
                        child: Padding(
                          padding: EdgeInsets.symmetric(
                            horizontal: isNarrow ? 10 : 16,
                            vertical: 12,
                          ),
                          child: Row(
                            crossAxisAlignment: CrossAxisAlignment.center,
                            children: [
                              CircleAvatar(
                                backgroundColor: _statusColor(tanaman.status)
                                    .withOpacity(0.15),
                                child: Icon(Icons.local_florist,
                                    color: _statusColor(tanaman.status)),
                              ),
                              const SizedBox(width: 12),
                              Expanded(
                                child: Column(
                                  crossAxisAlignment: CrossAxisAlignment.start,
                                  mainAxisSize: MainAxisSize.min,
                                  children: [
                                    Text(
                                      tanaman.nama,
                                      maxLines: 1,
                                      overflow: TextOverflow.ellipsis,
                                      style: const TextStyle(
                                          fontWeight: FontWeight.bold,
                                          fontSize: 15),
                                    ),
                                    const SizedBox(height: 3),
                                    Text(
                                      '${tanaman.jenis} • Kelembaban ${tanaman.kelembaban.toStringAsFixed(0)}%',
                                      maxLines: 1,
                                      overflow: TextOverflow.ellipsis,
                                      style: TextStyle(
                                          color: Colors.grey[600],
                                          fontSize: 12),
                                    ),
                                  ],
                                ),
                              ),
                              const SizedBox(width: 8),
                              Column(
                                mainAxisSize: MainAxisSize.min,
                                crossAxisAlignment: CrossAxisAlignment.end,
                                children: [
                                  Container(
                                    constraints: BoxConstraints(
                                        maxWidth: isNarrow ? 68 : 90),
                                    padding: const EdgeInsets.symmetric(
                                        horizontal: 6, vertical: 3),
                                    decoration: BoxDecoration(
                                      color: _statusColor(tanaman.status)
                                          .withOpacity(0.15),
                                      borderRadius: BorderRadius.circular(6),
                                    ),
                                    child: Text(
                                      tanaman.status,
                                      maxLines: 1,
                                      overflow: TextOverflow.ellipsis,
                                      textAlign: TextAlign.center,
                                      style: TextStyle(
                                          color: _statusColor(tanaman.status),
                                          fontSize: 10),
                                    ),
                                  ),
                                  SizedBox(
                                    height: 32,
                                    width: 32,
                                    child: PopupMenuButton<String>(
                                      padding: EdgeInsets.zero,
                                      icon:
                                          const Icon(Icons.more_vert, size: 20),
                                      onSelected: (value) async {
                                        if (value == 'edit') {
                                          await Navigator.of(context).push(
                                            MaterialPageRoute(
                                              builder: (_) =>
                                                  FormScreen(tanaman: tanaman),
                                            ),
                                          );
                                          setState(() {});
                                        } else if (value == 'hapus') {
                                          _hapus(tanaman);
                                        }
                                      },
                                      itemBuilder: (context) => const [
                                        PopupMenuItem(
                                          value: 'edit',
                                          child: Row(
                                            children: [
                                              Icon(Icons.edit, size: 18),
                                              SizedBox(width: 8),
                                              Text('Edit'),
                                            ],
                                          ),
                                        ),
                                        PopupMenuItem(
                                          value: 'hapus',
                                          child: Row(
                                            children: [
                                              Icon(Icons.delete,
                                                  size: 18, color: Colors.red),
                                              SizedBox(width: 8),
                                              Text('Hapus',
                                                  style: TextStyle(
                                                      color: Colors.red)),
                                            ],
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
                  },
                ),
        ),
      ],
    );
  }

  @override
  Widget build(BuildContext context) {
    final body = SafeArea(child: _buildList());
    final fab = FloatingActionButton(
      backgroundColor: const Color(0xFF2E7D32),
      onPressed: () async {
        await Navigator.of(context).push(
          MaterialPageRoute(builder: (_) => const FormScreen()),
        );
        setState(() {});
      },
      child: const Icon(Icons.add, color: Colors.white),
    );

    if (widget.embedded) {
      return Scaffold(body: body, floatingActionButton: fab);
    }

    return Scaffold(
      appBar: AppBar(
          title: const Text('Data Tanaman'),
          backgroundColor: const Color(0xFF2E7D32)),
      body: body,
      floatingActionButton: fab,
    );
  }
}
