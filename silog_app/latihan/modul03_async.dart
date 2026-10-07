// Modul 03: Pemrograman Asinkron dan Future
// Praktikum Pemrograman IV - D4 Teknik Informatika ULBI
// Mahasiswa: Muhammad Malik (NIM: 714240062)

// ==========================================
// KELAS EXCEPTION KUSTOM
// ==========================================
class ResiTidakDitemukan implements Exception {
  final String resi;
  ResiTidakDitemukan(this.resi);

  @override
  String toString() => 'Resi $resi tidak ditemukan pada basis data.';
}

// ==========================================
// BASIS DATA SIMULASI (MINIMAL 5 RESI)
// ==========================================
final Map<String, String> basisDataStatus = {
  'SLG-001': 'Paket sedang disortir di hub Bandung',
  'SLG-002': 'Paket sedang dalam perjalanan menuju gudang transit Jakarta',
  'SLG-003': 'Paket tiba di fasilitas sortir Surabaya',
  'SLG-004': 'Paket sedang diantar kurir ke alamat penerima di Semarang',
  'SLG-005': 'Paket telah diterima oleh penerima di Medan',
};

// ==========================================
// FUNGSI ASINKRON PENGAMBIL STATUS KIRIMAN
// ==========================================
Future<String> ambilStatusKiriman(String resi) async {
  // Simulasi jeda latensi jaringan selama 2 detik sesuai modul
  await Future.delayed(const Duration(seconds: 2));

  // Validasi format resi (harus berawalan 'SLG-')
  if (!resi.startsWith('SLG-')) {
    throw FormatException('Format resi tidak sah: $resi');
  }

  // Validasi keberadaan resi di basis data
  final status = basisDataStatus[resi];
  if (status == null) {
    throw ResiTidakDitemukan(resi);
  }

  return 'Resi $resi: $status';
}

// Fungsi simulasi pengambilan ongkir (Latihan 3 & 4)
Future<double> ambilOngkir(String resi) async {
  await Future.delayed(const Duration(seconds: 1));
  return 105400;
}

// ==========================================
// LATIHAN 4: EKSEKUSI PARALEL DENGAN FUTURE.WAIT
// ==========================================
Future<void> bandingkanWaktu() async {
  final mulai = DateTime.now();
  final hasil = await Future.wait([
    ambilStatusKiriman('SLG-001'),
    ambilOngkir('SLG-001'),
  ]);
  final durasi = DateTime.now().difference(mulai);
  print('Status      : ${hasil[0]}');
  print('Ongkir      : Rp${(hasil[1] as double).toStringAsFixed(0)}');
  print('Durasi total: ${durasi.inMilliseconds} ms');
}

// ==========================================
// TUGAS PRAKTIKUM: PANTAU BANYAK RESI SECARA PARALEL
// ==========================================
Future<void> pantauBanyakResi(List<String> daftarResi) async {
  print('Memulai pemantauan ${daftarResi.length} resi secara bersamaan...');
  final waktuMulai = DateTime.now();

  final List<String> berhasil = [];
  final List<String> gagal = [];

  // Menjalankan pemanggilan status untuk semua resi secara bersamaan (konkuren)
  // Menangkap error per-resi agar kegagalan 1 resi tidak menghentikan resi lainnya
  final tasks = daftarResi.map((resi) async {
    try {
      final status = await ambilStatusKiriman(resi);
      berhasil.add(status);
    } on ResiTidakDitemukan catch (e) {
      gagal.add('Resi $resi -> Peringatan: $e');
    } on FormatException catch (e) {
      gagal.add('Resi $resi -> Kesalahan Format: ${e.message}');
    } catch (e) {
      gagal.add('Resi $resi -> Kesalahan tak terduga: $e');
    }
  });

  // Menunggu seluruh tugas asinkron selesai secara paralel
  await Future.wait(tasks);

  final durasi = DateTime.now().difference(waktuMulai);
  print('Selesai dalam ${durasi.inMilliseconds} ms.');
  print('Hasil Sukses (${berhasil.length}):');
  for (final item in berhasil) {
    print('  [✓] $item');
  }
  print('Hasil Gagal (${gagal.length}):');
  if (gagal.isEmpty) {
    print('  (Tidak ada resi gagal)');
  } else {
    for (final item in gagal) {
      print('  [✗] $item');
    }
  }
}

// ==========================================
// FUNGSI MAIN
// ==========================================
Future<void> main() async {
  print('====================================================');
  print('LATIHAN 3: PEMANGGILAN BERURUTAN (SEQUENTIAL)');
  print('====================================================');
  print('1. Permintaan data dikirim...');
  final mulaiLatihan3 = DateTime.now();
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
    print('Gagal mengambil data: $e');
  }
  final durasiLatihan3 = DateTime.now().difference(mulaiLatihan3);
  print('4. Proses selesai dalam: ${durasiLatihan3.inMilliseconds} ms\n');

  print('====================================================');
  print('LATIHAN 4: PEMANGGILAN PARALEL DENGAN FUTURE.WAIT');
  print('====================================================');
  await bandingkanWaktu();
  print('');

  print('====================================================');
  print('TUGAS PRAKTIKUM: SKENARIO 1 (SELURUH RESI SAH)');
  print('====================================================');
  final resiSah = ['SLG-001', 'SLG-002', 'SLG-003', 'SLG-004', 'SLG-005'];
  await pantauBanyakResi(resiSah);
  print('');

  print('====================================================');
  print('TUGAS PRAKTIKUM: SKENARIO 2 (TERDAPAT RESI TIDAK SAH)');
  print('====================================================');
  final resiCampuran = ['SLG-001', 'SLG-999', 'XYZ-002', 'SLG-004', 'INV-123'];
  await pantauBanyakResi(resiCampuran);
  print('====================================================');
}
