import 'dart:async';
import 'dart:convert';
import 'dart:io';
import 'package:http/http.dart' as http;
import '../model/order.dart';

class GagalApi implements Exception {
  final String pesan;
  final int? kode;
  GagalApi(this.pesan, {this.kode});

  @override
  String toString() => pesan;
}

class OrderApi {
  static const _basis = 'https://jsonplaceholder.typicode.com';
  static const _batasWaktu = Duration(seconds: 12);
  final http.Client _client;

  OrderApi({http.Client? client}) : _client = client ?? http.Client();

  Future<List<Order>> ambilDaftar({int limit = 10}) async {
    final url = Uri.parse('$_basis/posts?_limit=$limit');
    try {
      final res = await _client.get(url).timeout(_batasWaktu);
      if (res.statusCode == 200) {
        final data = jsonDecode(res.body) as List<dynamic>;
        return data
            .map((e) => Order.fromJson(e as Map<String, dynamic>))
            .toList();
      } else if (res.statusCode == 404) {
        throw GagalApi('Data order tidak ditemukan', kode: 404);
      } else if (res.statusCode >= 500) {
        throw GagalApi('Server sedang bermasalah, coba beberapa saat lagi',
            kode: res.statusCode);
      } else {
        throw GagalApi('Permintaan ditolak server', kode: res.statusCode);
      }
    } on SocketException {
      throw GagalApi('Tidak ada koneksi internet');
    } on http.ClientException {
      throw GagalApi('Tidak ada koneksi internet');
    } on TimeoutException {
      throw GagalApi('Waktu tunggu habis, periksa jaringan Anda');
    } on FormatException {
      throw GagalApi('Format data dari server tidak sesuai');
    }
  }

  Future<Order> kirimOrder(Order order) async {
    final url = Uri.parse('$_basis/posts');
    try {
      final res = await _client
          .post(
            url,
            headers: {'Content-Type': 'application/json; charset=UTF-8'},
            body: jsonEncode(order.toJson()),
          )
          .timeout(_batasWaktu);
      if (res.statusCode == 201 || res.statusCode == 200) {
        return Order.fromJson(jsonDecode(res.body) as Map<String, dynamic>);
      }
      throw GagalApi('Gagal mengirim order', kode: res.statusCode);
    } on SocketException {
      throw GagalApi('Tidak ada koneksi internet');
    } on http.ClientException {
      throw GagalApi('Tidak ada koneksi internet');
    } on TimeoutException {
      throw GagalApi('Waktu tunggu habis saat mengirim order');
    }
  }

  /// Tugas Praktikum Butir 2: Memperbarui order dengan metode PUT
  Future<Order> perbaruiOrder(Order order) async {
    if (order.id == null) {
      throw GagalApi('ID order tidak boleh kosong untuk pembaruan');
    }
    final url = Uri.parse('$_basis/posts/${order.id}');
    try {
      final res = await _client
          .put(
            url,
            headers: {'Content-Type': 'application/json; charset=UTF-8'},
            body: jsonEncode(order.toJson()),
          )
          .timeout(_batasWaktu);
      if (res.statusCode == 200) {
        return Order.fromJson(jsonDecode(res.body) as Map<String, dynamic>);
      } else if (res.statusCode == 404) {
        throw GagalApi('Order dengan id ${order.id} tidak ditemukan di server',
            kode: 404);
      } else if (res.statusCode >= 500) {
        throw GagalApi('Server sedang bermasalah, coba beberapa saat lagi',
            kode: res.statusCode);
      } else {
        throw GagalApi('Gagal memperbarui order', kode: res.statusCode);
      }
    } on SocketException {
      throw GagalApi('Tidak ada koneksi internet');
    } on http.ClientException {
      throw GagalApi('Tidak ada koneksi internet');
    } on TimeoutException {
      throw GagalApi('Waktu tunggu habis saat memperbarui order');
    } on FormatException {
      throw GagalApi('Format data dari server tidak sesuai');
    }
  }

  /// Tugas Praktikum Butir 2: Menghapus order dengan metode DELETE
  Future<void> hapusOrder(int id) async {
    final url = Uri.parse('$_basis/posts/$id');
    try {
      final res = await _client.delete(url).timeout(_batasWaktu);
      if (res.statusCode == 200 || res.statusCode == 204) {
        return;
      } else if (res.statusCode == 404) {
        throw GagalApi('Order dengan id $id tidak ditemukan di server',
            kode: 404);
      } else if (res.statusCode >= 500) {
        throw GagalApi('Server sedang bermasalah, coba beberapa saat lagi',
            kode: res.statusCode);
      } else {
        throw GagalApi('Gagal menghapus order', kode: res.statusCode);
      }
    } on SocketException {
      throw GagalApi('Tidak ada koneksi internet');
    } on http.ClientException {
      throw GagalApi('Tidak ada koneksi internet');
    } on TimeoutException {
      throw GagalApi('Waktu tunggu habis saat menghapus order');
    }
  }

  void tutup() => _client.close();
}

