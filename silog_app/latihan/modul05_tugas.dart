import '../lib/layanan/layanan_pengiriman.dart';
import '../lib/layanan/moda.dart';

void main() {
  print('=== TUGAS PRAKTIKUM MODUL 5: MIXIN TERASURANSI ===\n');

  // Inisialisasi masing-masing objek moda
  final truk = PengirimanTruk(
    kodeLayanan: 'TRK-REG-01',
    jarakKm: 500,
    beratKg: 800,
  );

  final kapal = PengirimanKapal(
    kodeLayanan: 'KPL-PETI-01',
    jarakKm: 1200,
    beratKg: 5000,
    volumeM3: 15.0,
  );

  final udara = PengirimanUdara(
    kodeLayanan: 'UDR-EXP-01',
    jarakKm: 1500,
    beratKg: 250,
    bandara: 'HLP-SUB',
    panjangCm: 80,
    lebarCm: 60,
    tinggiCm: 50,
  );

  const double nilaiBarang = 500000000; // Rp 500.000.000

  print('1. Uji Fitur Asuransi pada PengirimanKapal:');
  print('   Ringkasan: ${kapal.ringkasan()}');
  print('   Nilai Barang    : Rp${nilaiBarang.toStringAsFixed(0)}');
  print('   Persentase Premi: ${(kapal.persentasePremi * 100).toStringAsFixed(2)}%');
  print('   Biaya Premi     : Rp${kapal.hitungPremi(nilaiBarang).toStringAsFixed(0)}');
  print('');

  print('2. Uji Fitur Asuransi pada PengirimanUdara:');
  // Kustomisasi persentase premi khusus kargo udara bernilai tinggi
  udara.persentasePremi = 0.008; // 0.8%
  print('   Ringkasan: ${udara.ringkasan()}');
  print('   Nilai Barang    : Rp${nilaiBarang.toStringAsFixed(0)}');
  print('   Persentase Premi: ${(udara.persentasePremi * 100).toStringAsFixed(2)}%');
  print('   Biaya Premi     : Rp${udara.hitungPremi(nilaiBarang).toStringAsFixed(0)}');
  print('');

  print('3. Pembuktian PengirimanTruk TIDAK Memiliki Mixin Terasuransi:');
  // Pemeriksaan tipe saat runtime menggunakan operator 'is'
  if (truk is Terasuransi) {
    print('   [SALAH] PengirimanTruk memiliki mixin Terasuransi.');
  } else {
    print('   [BENAR] PengirimanTruk BUKAN bertipe Terasuransi.');
    print('   PengirimanTruk tidak memiliki atribut persentasePremi maupun metode hitungPremi().');
    print('   Jika baris `truk.hitungPremi(nilaiBarang);` dipanggil langsung, compiler Dart');
    print('   akan menolak dengan error:');
    print("   'The method hitungPremi isn't defined for the type PengirimanTruk.'");
  }
  print('');

  print('4. Pemrosesan Asuransi Koleksi Polimorfik:');
  final List<LayananPengiriman> semuaLayanan = [truk, kapal, udara];

  for (final layanan in semuaLayanan) {
    print('   Moda: ${layanan.kodeLayanan}');
    if (layanan is Terasuransi) {
      final asuransi = layanan as Terasuransi;
      final premi = asuransi.hitungPremi(nilaiBarang);
      print('     Status Asuransi: TERASURANSI');
      print('     Premi (Rp): ${premi.toStringAsFixed(0)}');
    } else {
      print('     Status Asuransi: TIDAK TERASURANSI (Tidak didukung oleh moda ini)');
    }
  }
}
