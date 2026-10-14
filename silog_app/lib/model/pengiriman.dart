import 'barang.dart';
import 'gudang.dart';
import 'pelanggan.dart';

class Pengiriman {
  final String resi;
  final Gudang asal;
  final String kotaTujuan;
  final Barang barang;
  final int jumlah;
  final DateTime tanggalKirim;
  final Pelanggan? pelanggan;
  String _status;

  Pengiriman({
    required this.resi,
    required this.asal,
    required this.kotaTujuan,
    required this.barang,
    required this.jumlah,
    required this.tanggalKirim,
    this.pelanggan,
    String status = 'Draft',
  }) : _status = status;

  /// Konstruktor bernama untuk pengiriman yang baru didaftarkan hari ini.
  Pengiriman.baru({
    required this.resi,
    required this.asal,
    required this.kotaTujuan,
    required this.barang,
    required this.jumlah,
    this.pelanggan,
  }) : tanggalKirim = DateTime.now(),
       _status = 'Menunggu Pickup';

  String get status => _status;
  double get nilaiBarang => barang.nilaiTotal(jumlah);

  void ubahStatus(String statusBaru) {
    const urutan = [
      'Draft',
      'Menunggu Pickup',
      'Dalam Perjalanan',
      'Tiba di Kota Tujuan',
      'Diterima',
    ];
    if (!urutan.contains(statusBaru)) {
      throw ArgumentError('Status $statusBaru tidak dikenal');
    }
    if (urutan.indexOf(statusBaru) < urutan.indexOf(_status)) {
      throw StateError(
        'Status tidak dapat mundur dari $_status ke $statusBaru',
      );
    }
    _status = statusBaru;
  }

  @override
  String toString() {
    final infoPelanggan =
        pelanggan != null ? ' | Pelanggan: ${pelanggan!.nama}' : '';
    return '$resi | ${barang.nama} x$jumlah | ${asal.kota} -> $kotaTujuan$infoPelanggan | $_status';
  }
}
