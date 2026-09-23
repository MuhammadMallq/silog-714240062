double beratVolumetrik(double p, double l, double t, {double faktor = 6000}) =>
    (p * l * t) / faktor;
double beratTertagih({required double aktual, required double volumetrik}) =>
    aktual > volumetrik ? aktual : volumetrik;
double hitungOngkir({
  required double berat,
  required double tarifPerKg,
  bool asuransi = false,
  double persenAsuransi = 0.005,
  double nilaiBarang = 0,
}) {
  double biaya = berat * tarifPerKg;
  if (asuransi) {
    biaya += nilaiBarang * persenAsuransi;
  }
  return biaya;
}

int estimasiHariSampai(String kota) {
  switch (kota.toLowerCase()) {
    case 'bandung':
      return 1;
    case 'surabaya':
      return 2;
    case 'makassar':
      return 3;
    case 'jayapura':
      return 5;
    default:
      return 3;
  }
}

String rupiah(double nilai) => 'Rp${nilai.toStringAsFixed(0)}';
void main() {
  final kotaTujuan = 'Surabaya';
  final volumetrik = beratVolumetrik(45, 30, 25);
  final tertagih = beratTertagih(aktual: 12.4, volumetrik: volumetrik);
  
  final ongkir = hitungOngkir(
    berat: tertagih,
    tarifPerKg: 8500,
    asuransi: false, 
    nilaiBarang: 2500000,
  );
  final estimasi = estimasiHariSampai(kotaTujuan);
  print('Kota tujuan      : $kotaTujuan');
  print('Berat tertagih   : ${tertagih.toStringAsFixed(2)} kg');
  print('Ongkos kirim     : ${rupiah(ongkir)}');
  print('Estimasi sampai  : $estimasi hari');
}
