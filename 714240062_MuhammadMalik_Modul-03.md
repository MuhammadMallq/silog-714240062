# LAPORAN PRAKTIKUM PEMROGRAMAN IV
## MODUL 3: NULL SAFETY DAN PEMROGRAMAN ASINKRON

---

### 1. Identitas Praktikan
- **Nama Praktikan** : Muhammad Malik
- **NIM** : 714240062
- **Kelas** : D4 Teknik Informatika (D4 TI)
- **Mata Kuliah** : Praktikum Pemrograman IV
- **Modul** : Modul 3 – Null Safety dan Pemrograman Asinkron
- **Tanggal Praktikum** : 7 Oktober 2026
- **Cabang Git** : `praktikum/modul-03`
- **Tautan Repositori** : [https://github.com/MuhammadMallq/silog-714240062.git](https://github.com/MuhammadMallq/silog-714240062.git)

---

### 2. Tujuan Praktikum
1. Memahami prinsip kerja **Sound Null Safety** pada bahasa pemrograman Dart versi 2.12 ke atas.
2. Menguasai deklarasi tipe data *nullable* (`?`) dan *non-nullable* serta operator *null-aware* (`?.`, `??`, `??=`, `!`).
3. Mengimplementasikan mekanisme penanganan kesalahan (*error & exception handling*) menggunakan `try`, `on`, `catch`, dan `finally`.
4. Memahami arsitektur eksekusi asinkron berbasis *single-thread event loop* melalui objek `Future`.
5. Menerapkan sintaksis `async` dan `await` untuk menangani proses pengambilan data yang memiliki latensi/tundaan jaringan.
6. Menganalisis perbedaan efisiensi waktu antara eksekusi sekuensial (berurutan) dan eksekusi paralel menggunakan `Future.wait`.
7. Menyusun fungsi pelacakan banyak paket secara konkuren yang tangguh (*fault-tolerant*) terhadap kegagalan individual.

---

### 3. Alat dan Bahan
| No | Perangkat / Alat | Deskripsi / Versi |
|:--:|---|---|
| 1 | Sistem Operasi | macOS (Darwin x86_64) |
| 2 | Dart SDK | Versi 3.8.1 (stable) |
| 3 | Flutter SDK | Versi 3.32.8 (stable channel) |
| 4 | Code Editor / IDE | Visual Studio Code / Antigravity IDE |
| 5 | Command Line Interface | Zsh Terminal |
| 6 | Version Control System | Git 2.39+ |
| 7 | Repositori GitHub | `https://github.com/MuhammadMallq/silog-714240062.git` |

---

### 4. Langkah Kerja

#### 4.1. Penyiapan Cabang Kerja (Branch Git)
1. Buka terminal pada direktori root proyek `praktikum-pemrograman4`.
2. Buat dan aktifkan cabang kerja baru untuk modul ini:
   ```bash
   git checkout -b praktikum/modul-03
   ```
3. Pastikan cabang aktif melalui perintah:
   ```bash
   git branch
   ```

#### 4.2. Penyiapan dan Eksekusi Berkas
1. Siapkan dua berkas di dalam direktori `silog_app/latihan/`:
   - `modul03_nullsafety.dart` (untuk materi Null Safety & Penanganan Error)
   - `modul03_async.dart` (untuk materi Future, Async/Await, dan Tugas Praktikum)
2. Jalankan program melalui terminal dari direktori `silog_app`:
   ```bash
   # Masuk ke direktori aplikasi
   cd silog_app

   # Menjalankan Latihan 1 & 2
   dart run latihan/modul03_nullsafety.dart

   # Menjalankan Latihan 3, 4, dan Tugas Praktikum
   dart run latihan/modul03_async.dart

   # Memverifikasi kode bersih dari error statis
   dart analyze
   ```

*(Catatan Teknis: Jika terminal sudah berada di dalam folder `latihan/`, eksekusi dilakukan langsung dengan memanggil nama berkas tanpa prefix direktori, misalnya `dart run modul03_nullsafety.dart`).*

---

### 5. Kode Program Beserta Penjelasannya

#### 5.1. Berkas `silog_app/latihan/modul03_nullsafety.dart`
```dart
// Modul 03: Null Safety dan Penanganan Error
// Praktikum Pemrograman IV - D4 Teknik Informatika ULBI

class DataKiriman {
  final String resi; // wajib (non-nullable)
  final String kotaTujuan; // wajib (non-nullable)
  final String? catatan; // opsional (nullable)
  final DateTime? waktuTerima; // opsional (nullable)

  DataKiriman({
    required this.resi,
    required this.kotaTujuan,
    this.catatan,
    this.waktuTerima,
  });
}

String ringkasan(DataKiriman k) {
  // Operator ?? memberikan fallback default jika nilai k.catatan adalah null
  final catatan = k.catatan ?? '(tanpa catatan)';
  
  // Menguji kondisi null; jika tidak null, gunakan operator null assertion (!)
  final status = k.waktuTerima == null
      ? 'Dalam perjalanan'
      : 'Diterima pada ${k.waktuTerima!.toIso8601String()}';
      
  return '${k.resi} | ${k.kotaTujuan} | $status | $catatan';
}

// Latihan 2: Penanganan Error
class ResiTidakDitemukan implements Exception {
  final String resi;
  ResiTidakDitemukan(this.resi);

  @override
  String toString() => 'Resi $resi tidak ditemukan pada basis data.';
}

final Map<String, String> basisResi = {
  'SLG-001': 'Bandung',
  'SLG-002': 'Surabaya',
};

String cariKota(String resi) {
  final kota = basisResi[resi];
  if (kota == null) {
    throw ResiTidakDitemukan(resi);
  }
  return kota;
}

void ujiPenanganan() {
  for (final resi in ['SLG-001', 'SLG-999']) {
    try {
      print('$resi -> ${cariKota(resi)}');
    } on ResiTidakDitemukan catch (e) {
      // Menangkap jenis exception spesifik domain
      print('Peringatan: $e');
    } catch (e, s) {
      // Menangkap kesalahan umum lainnya beserta stack trace
      print('Kesalahan tidak terduga: $e');
      print(s);
    } finally {
      // Blok finally selalu dijalankan di akhir proses
      print('Pencarian $resi selesai.');
    }
  }
}

void main() {
  print('=== LATIHAN 1: NULL SAFETY ===');
  final daftar = <DataKiriman>[
    DataKiriman(resi: 'SLG-001', kotaTujuan: 'Bandung'),
    DataKiriman(
      resi: 'SLG-002',
      kotaTujuan: 'Surabaya',
      catatan: 'Titipkan ke satpam',
      waktuTerima: DateTime(2026, 9, 12, 10, 30),
    ),
  ];
  for (final k in daftar) {
    print(ringkasan(k));
  }

  print('\n=== LATIHAN 2: PENANGANAN ERROR ===');
  ujiPenanganan();
}
```

**Penjelasan Logika:**
1. **Null Safety**: Variabel `resi` dan `kotaTujuan` dideklarasikan `String` (tanpa tanda tanya) sehingga compiler menjamin tidak pernah `null`. Variabel `catatan` bertipe `String?` dan `waktuTerima` bertipe `DateTime?` menandakan bahwa nilainya diizinkan bernilai `null`.
2. **Operator `??` (Null-Coalescing)**: Menetapkan nilai pengganti `(tanpa catatan)` jika `k.catatan` bernilai `null`.
3. **Operator `!` (Null-Assertion)**: Memberitahu compiler bahwa `k.waktuTerima` secara pasti sudah bukan `null` setelah diverifikasi melalui percabangan ternary.
4. **Exception Handling**: Pembuatan kelas `ResiTidakDitemukan` mengimplementasikan antarmuka bawaan `Exception`. Konstruksi `try - on ... catch - finally` memisahkan penanganan galat spesifik domain logistik dari galat sistem tak terduga, dan blok `finally` memastikan pembersihan/pemberitahuan akhir selalu dieksekusi.

---

#### 5.2. Berkas `silog_app/latihan/modul03_async.dart`
```dart
// Modul 03: Pemrograman Asinkron dan Future
// Praktikum Pemrograman IV - D4 Teknik Informatika ULBI
// Mahasiswa: Muhammad Malik (NIM: 714240062)

class ResiTidakDitemukan implements Exception {
  final String resi;
  ResiTidakDitemukan(this.resi);

  @override
  String toString() => 'Resi $resi tidak ditemukan pada basis data.';
}

// Basis data simulasi berisi minimal lima resi
final Map<String, String> basisDataStatus = {
  'SLG-001': 'Paket sedang disortir di hub Bandung',
  'SLG-002': 'Paket sedang dalam perjalanan menuju gudang transit Jakarta',
  'SLG-003': 'Paket tiba di fasilitas sortir Surabaya',
  'SLG-004': 'Paket sedang diantar kurir ke alamat penerima di Semarang',
  'SLG-005': 'Paket telah diterima oleh penerima di Medan',
};

// Fungsi asinkron simulasi pengambilan status kiriman
Future<String> ambilStatusKiriman(String resi) async {
  // Simulasi jeda latensi jaringan selama 2 detik sesuai panduan modul
  await Future.delayed(const Duration(seconds: 2));

  // Validasi format prefix resi
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

// Fungsi simulasi pengambilan ongkir (jeda 1 detik)
Future<double> ambilOngkir(String resi) async {
  await Future.delayed(const Duration(seconds: 1));
  return 105400;
}

// Latihan 4: Eksekusi Paralel menggunakan Future.wait
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

// Tugas Praktikum: Pemantauan Banyak Resi Secara Konkuren
Future<void> pantauBanyakResi(List<String> daftarResi) async {
  print('Memulai pemantauan ${daftarResi.length} resi secara bersamaan...');
  final waktuMulai = DateTime.now();

  final List<String> berhasil = [];
  final List<String> gagal = [];

  // Menjalankan seluruh permintaan resi secara bersamaan di event loop
  // Menangkap error di dalam setiap tugas agar tidak menggagalkan tugas lainnya
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
```

---

### 6. Hasil Eksekusi dan Analisis

#### 6.1. Eksekusi `modul03_nullsafety.dart`
Perintah:
```bash
dart run latihan/modul03_nullsafety.dart
```

Output:
```text
=== LATIHAN 1: NULL SAFETY ===
SLG-001 | Bandung | Dalam perjalanan | (tanpa catatan)
SLG-002 | Surabaya | Diterima pada 2026-09-12T10:30:00.000 | Titipkan ke satpam

=== LATIHAN 2: PENANGANAN ERROR ===
SLG-001 -> Bandung
Pencarian SLG-001 selesai.
Peringatan: Resi SLG-999 tidak ditemukan pada basis data.
Pencarian SLG-999 selesai.
```

#### 6.2. Analisis Eksperimen Latihan 1 (Butir B.3)
Pada pengujian butir B.3, tanda tanya pada `final String? catatan` dihapus menjadi `final String catatan`.

- **Pesan Error dari Compiler**:
  ```text
  latihan/modul03_nullsafety.dart:9:10: Error: The parameter 'catatan' can't have a value of 'null' because of its type 'String', but the implicit default value is 'null'.
  Try adding either an explicit non-'null' default value or the 'required' modifier.
      this.catatan,
           ^^^^^^^
  ```
- **Penjelasan**: Karena tipe `String` bersifat non-nullable, variabel tidak boleh menyimpan nilai null. Ketika parameter dibuat opsional pada konstruktor tanpa argumen nilai default, Dart secara otomatis memberikan nilai bawaan `null`. Compiler menolak hal ini pada waktu kompilasi untuk menjamin keselamatan tipe (*type safety*).
- **Penyelesaian**: Mengembalikan tipe data menjadi `String?` (nullable) atau mewajibkan pengisian argumen menggunakan kata kunci `required`.

#### 6.3. Eksekusi `modul03_async.dart`
Perintah:
```bash
dart run latihan/modul03_async.dart
```

Output:
```text
====================================================
LATIHAN 3: PEMANGGILAN BERURUTAN (SEQUENTIAL)
====================================================
1. Permintaan data dikirim...
2. Resi SLG-002: Paket sedang dalam perjalanan menuju gudang transit Jakarta
3. Ongkos kirim: Rp105400
4. Proses selesai dalam: 3014 ms

====================================================
LATIHAN 4: PEMANGGILAN PARALEL DENGAN FUTURE.WAIT
====================================================
Status      : Resi SLG-001: Paket sedang disortir di hub Bandung
Ongkir      : Rp105400
Durasi total: 2003 ms

====================================================
TUGAS PRAKTIKUM: SKENARIO 1 (SELURUH RESI SAH)
====================================================
Memulai pemantauan 5 resi secara bersamaan...
Selesai dalam 2002 ms.
Hasil Sukses (5):
  [✓] Resi SLG-001: Paket sedang disortir di hub Bandung
  [✓] Resi SLG-002: Paket sedang dalam perjalanan menuju gudang transit Jakarta
  [✓] Resi SLG-003: Paket tiba di fasilitas sortir Surabaya
  [✓] Resi SLG-004: Paket sedang diantar kurir ke alamat penerima di Semarang
  [✓] Resi SLG-005: Paket telah diterima oleh penerima di Medan
Hasil Gagal (0):
  (Tidak ada resi gagal)

====================================================
TUGAS PRAKTIKUM: SKENARIO 2 (TERDAPAT RESI TIDAK SAH)
====================================================
Memulai pemantauan 5 resi secara bersamaan...
Selesai dalam 2004 ms.
Hasil Sukses (2):
  [✓] Resi SLG-001: Paket sedang disortir di hub Bandung
  [✓] Resi SLG-004: Paket sedang diantar kurir ke alamat penerima di Semarang
Hasil Gagal (3):
  [✗] Resi SLG-999 -> Peringatan: Resi SLG-999 tidak ditemukan pada basis data.
  [✗] Resi XYZ-002 -> Kesalahan Format: Format resi tidak sah: XYZ-002
  [✗] Resi INV-123 -> Kesalahan Format: Format resi tidak sah: INV-123
====================================================
```

#### 6.4. Analisis Eksperimen Latihan 3 (Butir D.3 dan D.4)
1. **Butir D.3 (Menghapus keyword `await`)**:
   - Jika `await` dihapus: `final status = ambilStatusKiriman('SLG-002');`
   - Output yang muncul adalah `2. Instance of 'Future<String>'`.
   - **Penyebab**: Fungsi asinkron mengembalikan wadah masa depan (*future container*) bertipe `Future<String>`. Tanpa `await`, fungsi pemanggil tidak menanti penyelesaian nilai tersebut, melainkan langsung mencetak representasi teks `toString()` dari objek Future yang belum selesai (*uncompleted*).
2. **Butir D.4 (Pengujian Resi `'XYZ-002'`)**:
   - Resi `'XYZ-002'` melanggar kondisi `!resi.startsWith('SLG-')`.
   - Program melemparkan `FormatException('Format resi tidak sah: XYZ-002')`.
   - Kesalahan berhasil ditangkap oleh blok `on FormatException catch (e)` sehingga aplikasi tetap berjalan tertib menuju tahap berikutnya.

#### 6.5. Perbandingan Durasi Sekuensial vs Future.wait

| Parameter Uji | Pemanggilan Berurutan (Latihan 3) | Pemanggilan Bersamaan / Paralel (Latihan 4) |
|---|:---:|:---:|
| Durasi Operasi 1 (`ambilStatusKiriman`) | ~2.000 ms | ~2.000 ms |
| Durasi Operasi 2 (`ambilOngkir`) | ~1.000 ms | ~1.000 ms |
| **Total Waktu Eksekusi** | **3.014 ms** | **2.003 ms** |
| Pola Waktu | Akumulasi ($T_1 + T_2$) | Waktu Maksimum ($\max(T_1, T_2)$) |

**Kesimpulan Kapan `Future.wait` Layak & Tidak Layak Digunakan:**
- **Layak digunakan**: Saat sekumpulan tugas asinkron bersifat **independen** (tidak saling membutuhkan data satu sama lain). Contohnya: mengambil beberapa data analitik, memuat daftar banner dan notifikasi secara bersamaan, atau melacak status puluhan resi sekaligus.
- **Tidak layak digunakan**: Saat terdapat rantai ketergantungan urutan (*waterfall dependency*), di mana tugas kedua membutuhkan data keluaran dari tugas pertama (misal: mengambil token login baru kemudian mengambil data pengguna menggunakan token tersebut).

---

### 7. Jawaban Butir Tugas Praktikum (Sub-bab F)
1. **F.1**: Fungsi `ambilStatusKiriman` membaca status dari koleksi `basisDataStatus` yang berisi 5 resi (`SLG-001` hingga `SLG-005`). Jika format salah melempar `FormatException`, dan jika resi tidak terdaftar di Map melempar `ResiTidakDitemukan`.
2. **F.2**: Fungsi `pantauBanyakResi` memetakan daftar resi ke sekumpulan tugas asinkron yang dieksekusi bersamaan via `Future.wait`. Setiap tugas dilengkapi blok `try-catch` mandiri sehingga resi gagal tidak membatalkan atau menghentikan resi lain yang valid.
3. **F.3 Output Skenario**:
   - **Skenario 1 (Semua Sah)**: 5 resi sah diproses secara bersamaan dalam waktu **2.002 ms** dengan tingkat keberhasilan 100%.
   - **Skenario 2 (Terdapat Resi Tidak Sah)**: 5 resi diproses bersamaan dalam **2.004 ms**. 2 resi sah berhasil ditampilkan, dan 3 resi tidak sah (1 tidak terdaftar, 2 salah format) dicatat di daftar gagal tanpa menyebabkan aplikasi terhenti paksa (*crash*).

---

### 8. Bukti Analisis Statis Bebas Error (`dart analyze`)
```bash
$ dart analyze
Analyzing silog_app...
No issues found!
```
Hasil pemeriksaan kode program menunjukkan **No issues found!**, yang membuktikan bahwa seluruh implementasi bebas dari pelanggaran null safety dan linting rules.

---

### 9. Kesimpulan dan Kendala
- **Kesimpulan**:
  1. Fitur Sound Null Safety di Dart menjamin keandalan perangkat lunak sejak fase kompilasi sehingga memangkas risiko crash akibat dereferensi pointer null.
  2. Penggunaan `async/await` memudahkan penulisan kode asinkron dengan gaya sekuensial yang mudah dibaca.
  3. Pemanfaatan `Future.wait` meningkatkan efisiensi waktu respon aplikasi secara drastis saat menangani banyak operasi I/O simultan.
- **Kendala dan Solusi**:
  1. Terjadi galat `Could not find file` akibat perbedaan lokasi working directory saat eksekusi CLI. Solusinya adalah menjalankan perintah dari root paket atau menyesuaikan path berkas.
  2. Munculnya peringatan linter Flutter `avoid_print` untuk kode latihan CLI. Solusinya adalah mengatur `avoid_print: false` pada `silog_app/analysis_options.yaml`.

---

### 10. Tautan Repositori dan Riwayat Commit
- **URL Repositori** : [https://github.com/MuhammadMallq/silog-714240062.git](https://github.com/MuhammadMallq/silog-714240062.git)
- **Cabang Aktif** : `praktikum/modul-03`
- **Riwayat Commit Terakhir**:
  ```text
  3b98c55 (HEAD -> praktikum/modul-03) Modul 3: Null Safety dan Pemrograman Asinkron
  a9101cc (origin/main, origin/HEAD, main) Modul 2 : Dasar Pemograman Bahasa Dart
  29fed38 Modul 1: inisialisasi proyek SiLog
  ```
