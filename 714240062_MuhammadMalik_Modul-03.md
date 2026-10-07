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
1. Memahami konsep Sound Null Safety pada bahasa pemrograman Dart.
2. Menguasai deklarasi tipe nullable (`?`) dan non-nullable, serta operator null-aware (`?.`, `??`, `??=`, `!`).
3. Menerapkan penanganan kesalahan menggunakan `try`, `catch`, `on`, dan `finally`.
4. Memahami mekanisme eksekusi asinkron dan objek `Future`.
5. Menerapkan kata kunci `async` dan `await` pada pengambilan data yang tertunda.
6. Membandingkan performa eksekusi berurutan dengan eksekusi paralel menggunakan `Future.wait`.
7. Menyusun fungsi pelacakan resi secara bersamaan dengan penanganan error.

---

### 3. Alat dan Bahan
| No | Alat / Bahan | Keterangan / Versi |
|:--:|---|---|
| 1 | Sistem Operasi | macOS |
| 2 | Dart SDK | Versi 3.8.1 |
| 3 | Flutter SDK | Versi 3.32.8 |
| 4 | Visual Studio Code | Versi terbaru beserta ekstensi Dart |
| 5 | Terminal | Zsh Shell |
| 6 | Git | Version Control System |
| 7 | Repositori GitHub | `MuhammadMallq/silog-714240062` |

---

### 4. Langkah Kerja

#### 4.1. Penyiapan Cabang Kerja
1. Buka proyek `silog_app` pada Visual Studio Code.
2. Buat dan beralih ke cabang kerja modul 3 pada terminal:
   ```bash
   git checkout -b praktikum/modul-03
   ```
3. Pastikan cabang aktif melalui perintah:
   ```bash
   git branch
   ```

#### 4.2. Penyiapan Berkas Latihan
1. Buat berkas `modul03_nullsafety.dart` di dalam folder `latihan/`.
2. Buat berkas `modul03_async.dart` di dalam folder `latihan/`.

#### 4.3. Eksekusi Program
Jalankan program dari direktori `silog_app`:
```bash
# Latihan 1 dan Latihan 2
dart run latihan/modul03_nullsafety.dart

# Latihan 3, Latihan 4, dan Tugas Praktikum
dart run latihan/modul03_async.dart

# Pemeriksaan kode
dart analyze
```

---

### 5. Kode Program Beserta Penjelasannya

#### 5.1. Berkas `latihan/modul03_nullsafety.dart`
```dart
class DataKiriman {
  final String resi; // wajib
  final String kotaTujuan; // wajib
  final String? catatan; // opsional
  final DateTime? waktuTerima; // opsional
  DataKiriman({
    required this.resi,
    required this.kotaTujuan,
    this.catatan,
    this.waktuTerima,
  });
}

String ringkasan(DataKiriman k) {
  final catatan = k.catatan ?? '(tanpa catatan)';
  final status = k.waktuTerima == null
      ? 'Dalam perjalanan'
      : 'Diterima pada ${k.waktuTerima!.toIso8601String()}';
  return '${k.resi} | ${k.kotaTujuan} | $status | $catatan';
}

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
      print('Peringatan: $e');
    } catch (e, s) {
      print('Kesalahan tidak terduga: $e');
      print(s);
    } finally {
      print('Pencarian $resi selesai.');
    }
  }
}

void main() {
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

  ujiPenanganan();
}
```

**Penjelasan Singkat:**
- `DataKiriman`: Menggunakan null safety. `resi` dan `kotaTujuan` bertipe `String` (wajib diisi / non-nullable), sedangkan `catatan` bertipe `String?` dan `waktuTerima` bertipe `DateTime?` bersifat opsional (boleh bernilai null).
- Operator `??`: Memberikan teks pengganti `'(tanpa catatan)'` apabila `k.catatan` bernilai null.
- Operator `!`: Null assertion operator pada `k.waktuTerima!` digunakan karena pada blok `else` dari ternary sudah dipastikan nilainya bukan null.
- `ResiTidakDitemukan`: Kelas exception kustom yang mengimplementasikan `Exception`.
- `try-on-catch-finally`: `on ResiTidakDitemukan catch (e)` menangkap exception spesifik resi yang tidak ditemukan, sedangkan `finally` selalu dieksekusi di akhir setiap iterasi pencarian.

---

#### 5.2. Berkas `latihan/modul03_async.dart`
```dart
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
    print('Gagal mengambil data: $e');
  }
  print('4. Proses selesai.');

  print('\n--- Latihan 4: Eksekusi Paralel ---');
  await bandingkanWaktu();

  print('\n--- Tugas Praktikum: Seluruh Resi Sah ---');
  await pantauBanyakResi(['SLG-001', 'SLG-002', 'SLG-003', 'SLG-004', 'SLG-005']);

  print('\n--- Tugas Praktikum: Terdapat Resi Tidak Sah ---');
  await pantauBanyakResi(['SLG-001', 'SLG-999', 'XYZ-002']);
}
```

**Penjelasan Singkat:**
- `ambilStatusKiriman`: Membaca data status dari Map `basisResi` (5 resi). Melempar `FormatException` bila format bukan `'SLG-'`, dan melempar `ResiTidakDitemukan` bila resi tidak ada di basis data.
- `ambilOngkir`: Mengembalikan biaya kirim dengan jeda 1 detik.
- `bandingkanWaktu`: Menjalankan pengambilan status dan ongkir secara bersamaan menggunakan `Future.wait`.
- `pantauBanyakResi`: Memanggil `ambilStatusKiriman` untuk seluruh daftar resi secara simultan dengan `Future.wait`. Error pada resi yang salah ditangkap di dalam blok masing-masing sehingga proses resi lain tidak berhenti.

---

### 6. Hasil Eksekusi dan Analisisnya

#### 6.1. Output `modul03_nullsafety.dart`
```text
SLG-001 | Bandung | Dalam perjalanan | (tanpa catatan)
SLG-002 | Surabaya | Diterima pada 2026-09-12T10:30:00.000 | Titipkan ke satpam
SLG-001 -> Bandung
Pencarian SLG-001 selesai.
Peringatan: Resi SLG-999 tidak ditemukan pada basis data.
Pencarian SLG-999 selesai.
```

#### 6.2. Analisis Eksperimen Latihan 1 (Butir B.3)
Saat tanda tanya pada deklarasi `final String? catatan` dihapus menjadi `final String catatan`, compiler Dart menampilkan pesan error:
```text
Error: The parameter 'catatan' can't have a value of 'null' because of its type 'String', but the implicit default value is 'null'.
Try adding either an explicit non-'null' default value or the 'required' modifier.
```
**Analisis:**
Karena Dart menerapkan Sound Null Safety, tipe `String` dijamin tidak boleh bernilai null. Parameter opsional pada konstruktor `{this.catatan}` memiliki nilai bawaan implisit `null` apabila pemanggil tidak mengisinya. Hal ini melanggar aturan non-nullable sehingga ditolak saat kompilasi. Penyelesaiannya adalah mengembalikan tipe menjadi `String?` atau menambahkan kata kunci `required`.

#### 6.3. Output `modul03_async.dart`
```text
1. Permintaan data dikirim...
2. Paket tiba di fasilitas sortir Surabaya.
3. Ongkos kirim: Rp105400
4. Proses selesai.

--- Latihan 4: Eksekusi Paralel ---
Status : Paket sedang dalam perjalanan menuju gudang transit.
Ongkir : 105400.0
Durasi total: 2004 ms

--- Tugas Praktikum: Seluruh Resi Sah ---
SLG-001 -> Paket sedang dalam perjalanan menuju gudang transit.
SLG-002 -> Paket tiba di fasilitas sortir Surabaya.
SLG-003 -> Paket sedang disortir di hub Bandung.
SLG-004 -> Paket dibawa kurir ke alamat tujuan.
SLG-005 -> Paket telah diterima.

--- Tugas Praktikum: Terdapat Resi Tidak Sah ---
SLG-001 -> Paket sedang dalam perjalanan menuju gudang transit.
Peringatan: Resi SLG-999 tidak ditemukan pada basis data.
Kesalahan format: Format resi tidak sah: XYZ-002
```

#### 6.4. Analisis Eksperimen Latihan 3 (Butir D.3 dan D.4)
- **Eksperimen D.3 (Menghapus keyword `await`)**:
  Ketika baris `final status = await ambilStatusKiriman('SLG-002');` diubah tanpa `await`, output yang tercetak adalah `Instance of 'Future<String>'`. Hal ini terjadi karena tanpa `await`, kode tidak menunggu Future selesai, melainkan langsung mencetak objek Future itu sendiri yang statusnya masih *uncompleted*.
- **Eksperimen D.4 (Uji penanganan error dengan `'XYZ-002'`)**:
  Karena resi tidak berawalan `'SLG-'`, fungsi melempar `FormatException`. Kesalahan ini berhasil ditangkap oleh blok `on FormatException catch (e)` sehingga menampilkan `Kesalahan format: Format resi tidak sah: XYZ-002` tanpa menghentikan program secara paksa.

#### 6.5. Perbandingan Durasi Berurutan vs Future.wait
- **Pemanggilan Berurutan (Latihan 3)**:
  Total waktu = 2 detik (status) + 1 detik (ongkir) = ~3.000 ms.
- **Pemanggilan Bersamaan dengan `Future.wait` (Latihan 4)**:
  Total waktu = ~2.004 ms. Durasi total hanya mengikuti operasi yang paling lama ($\max(2\text{s}, 1\text{s})$), sehingga menghemat waktu sekitar 1 detik.

**Kesimpulan Kapan `Future.wait` Layak Digunakan dan Kapan Tidak:**
- **Layak digunakan**: Ketika beberapa operasi asinkron **tidak saling bergantung** satu sama lain, seperti mengambil status dan ongkir sekaligus, atau melacak status banyak resi secara bersamaan.
- **Tidak layak digunakan**: Ketika operasi asinkron memiliki ketergantungan urutan (*dependency*), di mana hasil operasi pertama diperlukan sebagai input untuk operasi kedua.

---

### 7. Jawaban Tugas Praktikum (Sub-bab F)
1. **F.1**: Fungsi `ambilStatusKiriman` membaca data dari Map `basisResi` yang berisi 5 resi (`SLG-001` s/d `SLG-005`), serta melemparkan `ResiTidakDitemukan` jika resi tidak terdaftar dan `FormatException` jika awalan resi salah.
2. **F.2**: Fungsi `pantauBanyakResi(List<String> daftarResi)` memanggil `ambilStatusKiriman` untuk seluruh resi secara bersamaan dengan `Future.wait`. Setiap pemanggilan dibungkus `try-catch` sehingga resi gagal tercatat tanpa menghentikan proses pemantauan resi lainnya.
3. **F.3**:
   - Skenario seluruh resi sah: seluruh 5 resi (`SLG-001` s/d `SLG-005`) berhasil ditampilkan statusnya secara bersamaan.
   - Skenario terdapat resi tidak sah (`['SLG-001', 'SLG-999', 'XYZ-002']`): resi `SLG-001` sukses ditampilkan, resi `SLG-999` ditangkap sebagai peringatan resi tidak ditemukan, dan `XYZ-002` ditangkap sebagai kesalahan format. Seluruh proses selesai dengan tertib.

---

### 8. Bukti Analisis Statis Bebas Error (`dart analyze`)
```bash
$ dart analyze
Analyzing silog_app...
No issues found!
```
Program sepenuhnya bebas dari error null safety dan memenuhi panduan linter.

---

### 9. Kesimpulan dan Kendala
- **Kesimpulan**:
  1. Fitur Null Safety di Dart menjamin keamanan program terhadap error null saat runtime melalui pemeriksaan ketat pada waktu kompilasi.
  2. Pemrograman asinkron (`Future`, `async`, `await`) memastikan antarmuka aplikasi tidak membeku saat menjalankan operasi yang memakan waktu (I/O).
  3. `Future.wait` memberikan efisiensi waktu yang signifikan saat mengeksekusi operasi asinkron independen secara bersamaan.
- **Kendala dan Solusi**:
  1. Terjadi kendala `Could not find file` pada terminal akibat menjalankan perintah dari subdirektori `latihan/`. Solusinya adalah menjalankan dari direktori root `silog_app` (`cd ..`).
  2. Aturan linter `avoid_print` memunculkan info linting pada kode latihan konsol. Solusinya adalah mengaktifkan `avoid_print: false` pada `analysis_options.yaml`.

---

### 10. Tautan Repositori dan Riwayat Commit
- **Repositori**: [https://github.com/MuhammadMallq/silog-714240062.git](https://github.com/MuhammadMallq/silog-714240062.git)
- **Cabang**: `praktikum/modul-03`
- **Riwayat Commit**:
  ```text
  Modul 3: Null Safety dan Pemrograman Asinkron
  ```
