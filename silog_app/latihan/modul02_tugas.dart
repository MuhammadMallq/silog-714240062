String tentukanKategori(double berat) {
  if (berat <= 5) {
    return 'Paket Kecil';
  } else if (berat <= 20) {
    return 'Paket Sedang';
  } else {
    return 'Kargo';
  }
}

double hitungTotalBerat(List<Map<String, Object>> daftar) {
  double total = 0;
  for (final item in daftar) {
    total += item['berat'] as double;
  }
  return total;
}

double hitungRataRata(List<Map<String, Object>> daftar) {
  return hitungTotalBerat(daftar) / daftar.length;
}

Map<String, Object> cariTerberat(List<Map<String, Object>> daftar) {
  var terberat = daftar[0];
  for (final item in daftar) {
    if ((item['berat'] as double) > (terberat['berat'] as double)) {
      terberat = item;
    }
  }
  return terberat;
}

Map<String, Object> cariTeringan(List<Map<String, Object>> daftar) {
  var teringan = daftar[0];
  for (final item in daftar) {
    if ((item['berat'] as double) < (teringan['berat'] as double)) {
      teringan = item;
    }
  }
  return teringan;
}

Map<String, int> hitungKategori(List<Map<String, Object>> daftar) {
  final Map<String, int> rekap = {
    'Paket Kecil': 0,
    'Paket Sedang': 0,
    'Kargo': 0,
  };
  for (final item in daftar) {
    final berat = item['berat'] as double;
    final kategori = tentukanKategori(berat);
    rekap[kategori] = (rekap[kategori] ?? 0) + 1;
  }
  return rekap;
}

void main() {
  final List<Map<String, Object>> kiriman = [
    {'resi': 'SLG-001', 'kota': 'Bandung', 'berat': 3.0},
    {'resi': 'SLG-002', 'kota': 'Surabaya', 'berat': 12.5},
    {'resi': 'SLG-003', 'kota': 'Makassar', 'berat': 7.2},
    {'resi': 'SLG-004', 'kota': 'Surabaya', 'berat': 4.8},
    {'resi': 'SLG-005', 'kota': 'Jayapura', 'berat': 24.0},
    {'resi': 'SLG-006', 'kota': 'Bandung', 'berat': 5.5},
    {'resi': 'SLG-007', 'kota': 'Makassar', 'berat': 10.0},
    {'resi': 'SLG-008', 'kota': 'Jayapura', 'berat': 2.5},
  ];

  for (final item in kiriman) {
    final resi = item['resi'];
    final kota = item['kota'];
    final berat = item['berat'] as double;
    final kategori = tentukanKategori(berat);
    print('$resi $kota ${berat.toStringAsFixed(1)}kg ($kategori)');
  }

  final total = hitungTotalBerat(kiriman);
  final rataRata = hitungRataRata(kiriman);
  final terberat = cariTerberat(kiriman);
  final teringan = cariTeringan(kiriman);
  final rekapKategori = hitungKategori(kiriman);

  print('\n--- Rekapitulasi Berat Kiriman ---');
  print('Total berat : ${total.toStringAsFixed(2)} kg');
  print('Rata-rata berat : ${rataRata.toStringAsFixed(2)} kg');
  print('Kiriman terberat : ${terberat['resi']} (${terberat['kota']}) ${terberat['berat']} kg');
  print('Kiriman teringan : ${teringan['resi']} (${teringan['kota']}) ${teringan['berat']} kg');

  print('\n--- Jumlah Kiriman per Kategori ---');
  rekapKategori.forEach((kategori, jumlah) {
    print('$kategori : $jumlah');
  });
}
