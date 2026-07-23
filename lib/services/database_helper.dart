import 'package:sqflite/sqflite.dart';
import 'package:path/path.dart';
import '../models/tanaman.dart';
import '../models/sensor_history.dart';

class DatabaseHelper {
  DatabaseHelper._internal();
  static final DatabaseHelper instance = DatabaseHelper._internal();

  Database? _db;

  Future<Database> get database async {
    if (_db != null) return _db!;
    _db = await _initDb();
    return _db!;
  }

  Future<Database> _initDb() async {
    final dbPath = await getDatabasesPath();
    final path = join(dbPath, 'tanimonitor.db');

    return openDatabase(
      path,
      version: 1,
      onCreate: (db, version) async {
        await db.execute('''
          CREATE TABLE tanaman (
            id TEXT PRIMARY KEY,
            nama TEXT NOT NULL,
            jenis TEXT NOT NULL,
            metode_irigasi TEXT NOT NULL,
            tanggal_tanam TEXT NOT NULL,
            jadwal_penyiraman TEXT NOT NULL,
            ada_hama INTEGER NOT NULL DEFAULT 0,
            aktif INTEGER NOT NULL DEFAULT 1,
            kelembaban REAL NOT NULL DEFAULT 60,
            suhu REAL NOT NULL DEFAULT 28
          )
        ''');
        await db.execute('''
          CREATE TABLE sensor_history (
            id INTEGER PRIMARY KEY AUTOINCREMENT,
            tanaman_id TEXT NOT NULL,
            kelembaban REAL NOT NULL,
            suhu REAL NOT NULL,
            waktu TEXT NOT NULL,
            FOREIGN KEY (tanaman_id) REFERENCES tanaman (id) ON DELETE CASCADE
          )
        ''');
        await _seedData(db);
      },
    );
  }

  Future<void> _seedData(Database db) async {
    final contoh = [
      Tanaman(
        id: '1',
        nama: 'Padi Sawah Blok A',
        jenis: 'Padi',
        metodeIrigasi: 'Genangan',
        tanggalTanam: DateTime.now().subtract(const Duration(days: 20)),
        jadwalPenyiraman: '06:00',
        kelembaban: 68,
        suhu: 27,
      ),
      Tanaman(
        id: '2',
        nama: 'Cabai Rawit Blok B',
        jenis: 'Cabai',
        metodeIrigasi: 'Tetes',
        tanggalTanam: DateTime.now().subtract(const Duration(days: 10)),
        jadwalPenyiraman: '07:00',
        kelembaban: 45,
        suhu: 30,
      ),
    ];
    for (final t in contoh) {
      await db.insert('tanaman', t.toMap());
      await db.insert(
          'sensor_history',
          SensorHistory(
            tanamanId: t.id,
            kelembaban: t.kelembaban,
            suhu: t.suhu,
            waktu: DateTime.now(),
          ).toMap());
    }
  }

  Future<List<Tanaman>> getAllTanaman() async {
    final db = await database;
    final result = await db.query('tanaman', orderBy: 'nama ASC');
    return result.map((row) => Tanaman.fromMap(row)).toList();
  }

  Future<Tanaman?> getTanamanById(String id) async {
    final db = await database;
    final result = await db.query('tanaman', where: 'id = ?', whereArgs: [id]);
    if (result.isEmpty) return null;
    return Tanaman.fromMap(result.first);
  }

  Future<void> insertTanaman(Tanaman tanaman) async {
    final db = await database;
    await db.insert('tanaman', tanaman.toMap());
    await insertSensorHistory(SensorHistory(
      tanamanId: tanaman.id,
      kelembaban: tanaman.kelembaban,
      suhu: tanaman.suhu,
      waktu: DateTime.now(),
    ));
  }

  Future<void> updateTanaman(Tanaman tanaman) async {
    final db = await database;
    await db.update('tanaman', tanaman.toMap(),
        where: 'id = ?', whereArgs: [tanaman.id]);
  }

  Future<void> hapusTanaman(String id) async {
    final db = await database;
    await db.delete('sensor_history', where: 'tanaman_id = ?', whereArgs: [id]);
    await db.delete('tanaman', where: 'id = ?', whereArgs: [id]);
  }

  Future<void> insertSensorHistory(SensorHistory history) async {
    final db = await database;
    await db.insert('sensor_history', history.toMap());
  }

  Future<List<SensorHistory>> getHistoryByTanamanId(String tanamanId,
      {int limit = 30}) async {
    final db = await database;
    final result = await db.query(
      'sensor_history',
      where: 'tanaman_id = ?',
      whereArgs: [tanamanId],
      orderBy: 'waktu DESC',
      limit: limit,
    );
    return result
        .map((row) => SensorHistory.fromMap(row))
        .toList()
        .reversed
        .toList();
  }
}
