import '../lib/model/barang.dart';
import '../lib/model/gudang.dart';
import '../lib/model/pelanggan.dart';
import '../lib/model/pengiriman.dart';

void main() {
  print('TUGAS PRAKTIKUM MODUL 4: PELANGGAN & PENGIRIMAN\n');

  // 1. Uji Entitas Pelanggan dan metode alamatRingkas()
  final pelanggan1 = Pelanggan(
    kode: 'PLG-001',
    nama: 'MhmmdMallq',
    telepon: '082122339125',
    alamat: 'Jl. Sukasari No. 2B, Sukajadi, Kota Bandung, Jawa Barat',
  );

  final pelanggan2 = Pelanggan(
    kode: 'PLG-002',
    nama: 'Lutfia Rifa Yolanda',
    telepon: '085712345678',
    alamat: 'Jl. Kasihan, Bantul, Yogyakarta',
  );

  print('Data Pelanggan 1: $pelanggan1');
  print('Alamat Asli 1 (${pelanggan1.alamat.length} karakter): ${pelanggan1.alamat}');
  print('Alamat Ringkas 1: ${pelanggan1.alamatRingkas()} (${pelanggan1.alamatRingkas().length} karakter)');
  print('');

  print('Data Pelanggan 2: $pelanggan2');
  print('Alamat Asli 2 (${pelanggan2.alamat.length} karakter): ${pelanggan2.alamat}');
  print('Alamat Ringkas 2: ${pelanggan2.alamatRingkas()} (${pelanggan2.alamatRingkas().length} karakter)');
  print('');

  // 2. Uji Integrasi Pelanggan pada Pengiriman
  final gudangBandung = Gudang(
    kode: 'GD-BDG',
    nama: 'Gudang Utama Bandung',
    kota: 'Bandung',
    kapasitas: 500,
  );

  final sepatu = Barang(
    kode: 'B-1024',
    nama: 'Sepatu Lari Pria',
    hargaSatuan: 450000,
    beratKg: 0.9,
  );

  gudangBandung.terimaBarang(sepatu, 50);

  final kirimPelanggan = Pengiriman.baru(
    resi: 'SLG-2026-0008',
    asal: gudangBandung,
    kotaTujuan: 'Surabaya',
    barang: sepatu,
    jumlah: 5,
    pelanggan: pelanggan1,
  );

  gudangBandung.keluarkanBarang(sepatu, kirimPelanggan.jumlah);

  print('Detail Pengiriman dengan Pelanggan:');
  print(kirimPelanggan);
  print('Penerima: ${kirimPelanggan.pelanggan?.nama} | Telp: ${kirimPelanggan.pelanggan?.telepon}');
  print('Alamat Pengiriman Ringkas: ${kirimPelanggan.pelanggan?.alamatRingkas()}');
  print('Nilai Barang: Rp${kirimPelanggan.nilaiBarang.toStringAsFixed(0)}');
  print('Sisa Stok Gudang: ${gudangBandung.totalStok}/${gudangBandung.kapasitas}');
}
