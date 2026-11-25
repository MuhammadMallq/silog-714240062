import 'package:flutter/foundation.dart' show kIsWeb;
import 'package:path_provider/path_provider.dart';
import 'package:sembast/sembast.dart';
import 'package:sembast/sembast_io.dart';
import 'package:sembast_web/sembast_web.dart';
import '../model/order.dart';

/// Repositori penyimpanan lokal sembast untuk cadangan offline data order (Modul 9 Bagian F)
class OrderRepository {
  static final OrderRepository instance = OrderRepository._();
  OrderRepository._();

  Database? _db;
  final _store = intMapStoreFactory.store('order_cache');

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

  /// Menyimpan seluruh salinan order dari API ke penyimpanan lokal
  Future<void> simpanSemua(List<Order> orders) async {
    final db = await _database;
    await _store.delete(db);
    for (final o in orders) {
      if (o.id != null) {
        await _store.record(o.id!).put(db, o.toMap());
      } else {
        await _store.add(db, o.toMap());
      }
    }
  }

  /// Mengambil seluruh data cadangan order dari penyimpanan lokal
  Future<List<Order>> ambilSemua() async {
    final db = await _database;
    final rekaman = await _store.find(db);
    return rekaman.map((r) => Order.fromMap(r.key, r.value)).toList();
  }

  /// Mengosongkan cadangan data order
  Future<void> kosongkan() async {
    final db = await _database;
    await _store.delete(db);
  }
}

