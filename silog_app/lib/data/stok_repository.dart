import 'package:flutter/foundation.dart' show kIsWeb;
import 'package:path_provider/path_provider.dart';
import 'package:sembast/sembast.dart';
import 'package:sembast/sembast_io.dart';
import 'package:sembast_web/sembast_web.dart';
import '../model/stok.dart';

class StokRepository {
  static final StokRepository instance = StokRepository._();
  StokRepository._();
  Database? _db;
  final _store = intMapStoreFactory.store('stok');
  Future<Database> get _database async {
    if (_db != null) return _db!;
    if (kIsWeb) {
      _db = await databaseFactoryWeb.openDatabase('silog.db');
    } else {
      final dir = await getApplicationDocumentsDirectory();
      _db = await databaseFactoryIo.openDatabase('${dir.path}/silog.db');
    }
    return _db!;
  }

  /// CREATE
  Future<int> simpan(Stok stok) async {
    final db = await _database;
    return _store.add(db, stok.toMap());
  }

  /// READ - seluruh data, diurutkan berdasarkan nama barang (dengan filter pencarian)
  Future<List<Stok>> ambilSemua({String? kodeGudang, String? kataKunci}) async {
    final db = await _database;
    final List<Filter> filters = [];

    if (kodeGudang != null && kodeGudang.isNotEmpty) {
      filters.add(Filter.equals('kodeGudang', kodeGudang));
    }

    // Tugas 2: Pencarian nama barang menggunakan Filter.matchesRegExp
    if (kataKunci != null && kataKunci.trim().isNotEmpty) {
      filters.add(
        Filter.matchesRegExp(
          'namaBarang',
          RegExp(RegExp.escape(kataKunci.trim()), caseSensitive: false),
        ),
      );
    }

    final finder = Finder(
      filter: filters.isEmpty
          ? null
          : (filters.length == 1 ? filters.first : Filter.and(filters)),
      sortOrders: [SortOrder('namaBarang')],
    );
    final rekaman = await _store.find(db, finder: finder);
    return rekaman.map((r) => Stok.fromMap(r.key, r.value)).toList();
  }

  /// PENCARIAN nama barang menggunakan Filter.matchesRegExp (Tugas 2)
  Future<List<Stok>> cari(String kataKunci, {String? kodeGudang}) async {
    return ambilSemua(kodeGudang: kodeGudang, kataKunci: kataKunci);
  }

  /// READ - satu data
  Future<Stok?> ambilSatu(int id) async {
    final db = await _database;
    final nilai = await _store.record(id).get(db);
    return nilai == null ? null : Stok.fromMap(id, nilai);
  }

  /// UPDATE
  Future<void> perbarui(Stok stok) async {
    if (stok.id == null) {
      throw ArgumentError('Data tanpa id tidak dapat diperbarui');
    }
    final db = await _database;
    await _store.record(stok.id!).update(db, stok.toMap());
  }

  /// DELETE
  Future<void> hapus(int id) async {
    final db = await _database;
    await _store.record(id).delete(db);
  }

  Future<int> totalStokGudang(String kodeGudang) async {
    final daftar = await ambilSemua(kodeGudang: kodeGudang);
    return daftar.fold<int>(0, (a, s) => a + s.jumlah);
  }

  Future<void> kosongkan() async {
    final db = await _database;
    await _store.delete(db);
  }
}
