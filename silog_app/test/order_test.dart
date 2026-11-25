import 'package:flutter_test/flutter_test.dart';
import 'package:silog_app/model/order.dart';
import 'package:silog_app/data/order_api.dart';

void main() {
  group('Pengujian Model Order (Modul 9)', () {
    test('Penguraian fromJson dengan data lengkap', () {
      final json = {
        'id': 1,
        'userId': 10,
        'title': 'Pengiriman Paket Elektronik',
        'body': '2 koli laptop ke Bandung',
      };

      final order = Order.fromJson(json);

      expect(order.id, 1);
      expect(order.idPelanggan, 10);
      expect(order.judul, 'Pengiriman Paket Elektronik');
      expect(order.keterangan, '2 koli laptop ke Bandung');
      expect(order.toString(), 'Order#1 Pengiriman Paket Elektronik');
    });

    test('Penguraian fromJson dengan data null (null-safety)', () {
      final json = <String, dynamic>{
        'id': null,
        'userId': null,
        'title': null,
        'body': null,
      };

      final order = Order.fromJson(json);

      expect(order.id, isNull);
      expect(order.idPelanggan, 0); // fallback default
      expect(order.judul, '(tanpa judul)'); // fallback default
      expect(order.keterangan, ''); // fallback default
    });

    test('Serialisasi toJson menghasilkan Map yang sesuai', () {
      final order = Order(
        id: 99,
        idPelanggan: 5,
        judul: 'Pengiriman Dokumen',
        keterangan: 'Surat berharga via kilat',
      );

      final json = order.toJson();

      expect(json['userId'], 5);
      expect(json['title'], 'Pengiriman Dokumen');
      expect(json['body'], 'Surat berharga via kilat');
    });

    test('Exception GagalApi menghasilkan pesan yang sesuai', () {
      final err = GagalApi('Koneksi terputus', kode: 500);
      expect(err.pesan, 'Koneksi terputus');
      expect(err.kode, 500);
      expect(err.toString(), 'Koneksi terputus');
    });
  });
}

