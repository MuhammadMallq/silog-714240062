class ResiTidakDitemukan implements Exception {
  final String resi;
  ResiTidakDitemukan(this.resi);
  @override
  String toString() => 'Resi $resi tidak ditemukan pada basis data.';
}

final Map<String, String> basisResi = {
  'SLG-001': 'Paket sedang dalam perjalanan menuju gudang transit.',
  'SLG-002': 'Paket tiba di fasilitas sortir Surabaya.',
  'SLG-003': 'Paket sedang disortir di hub Bandung.',
  'SLG-004': 'Paket dibawa kurir ke alamat tujuan.',
  'SLG-005': 'Paket telah diterima.',
};

Future<String> ambilStatusKiriman(String resi) async {
  // Simulasi jeda jaringan selama dua detik
  await Future.delayed(const Duration(seconds: 2));
  if (!resi.startsWith('SLG-')) {
    throw FormatException('Format resi tidak sah: $resi');
  }
  final status = basisResi[resi];
  if (status == null) {
    throw ResiTidakDitemukan(resi);
  }
  return status;
}

Future<double> ambilOngkir(String resi) async {
  await Future.delayed(const Duration(seconds: 1));
  return 105400;
}

Future<void> bandingkanWaktu() async {
  final mulai = DateTime.now();
  final hasil = await Future.wait([
    ambilStatusKiriman('SLG-001'),
    ambilOngkir('SLG-001'),
  ]);
  final durasi = DateTime.now().difference(mulai);
  print('Status : ${hasil[0]}');
  print('Ongkir : ${hasil[1]}');
  print('Durasi total: ${durasi.inMilliseconds} ms');
}

Future<void> pantauBanyakResi(List<String> daftarResi) async {
  final tugas = daftarResi.map((resi) async {
    try {
      final status = await ambilStatusKiriman(resi);
      print('$resi -> $status');
    } on ResiTidakDitemukan catch (e) {
      print('Peringatan: $e');
    } on FormatException catch (e) {
      print('Kesalahan format: ${e.message}');
    } catch (e) {
      print('Kesalahan: $e');
    }
  });
  await Future.wait(tugas);
}

Future<void> main() async {
  print('1. Permintaan data dikirim...');
  try {
    final status = await ambilStatusKiriman('SLG-002');
    print('2. $status');
    final ongkir = await ambilOngkir('SLG-002');
    print('3. Ongkos kirim: Rp${ongkir.toStringAsFixed(0)}');
  } on FormatException catch (e) {
    print('Kesalahan format: ${e.message}');
  } on ResiTidakDitemukan catch (e) {
    print('Peringatan: $e');
  } catch (e) {
    print('Gagal mengambil Data: $e');
  }
  print('4. Proses selesai.');

  print('\n--- Latihan 4: Eksekusi Paralel ---');
  await bandingkanWaktu();

  print('\n--- Tugas Praktikum: Seluruh Resi Sah ---');
  await pantauBanyakResi(['SLG-001', 'SLG-002', 'SLG-003', 'SLG-004', 'SLG-005']);

  print('\n--- Tugas Praktikum: Terdapat Resi Tidak Sah ---');
  await pantauBanyakResi(['SLG-001', 'SLG-999', 'XYZ-002']);
}
