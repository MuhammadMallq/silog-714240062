import 'layanan_pengiriman.dart';

class PengirimanTruk extends LayananPengiriman with Terlacak {
  final bool ekspres;

  PengirimanTruk({
    required super.kodeLayanan,
    required super.jarakKm,
    required super.beratKg,
    this.ekspres = false,
  });

  @override
  double hitungTarif() {
    const tarifDasarPerKm = 4500;
    const tarifPerKg = 1200;
    final tarif = (jarakKm * tarifDasarPerKm) + (beratKg * tarifPerKg);
    return ekspres ? tarif * 1.5 : tarif;
  }

  @override
  int estimasiHari() {
    final hari = (jarakKm / 450).ceil();
    return ekspres ? (hari / 2).ceil() : hari;
  }
}

class PengirimanKeretaApi extends LayananPengiriman with Terlacak {
  final String stasiunAsal;
  final String stasiunTujuan;

  PengirimanKeretaApi({
    required super.kodeLayanan,
    required super.jarakKm,
    required super.beratKg,
    required this.stasiunAsal,
    required this.stasiunTujuan,
  });

  @override
  double hitungTarif() {
    const tarifPerKmKg = 95;
    const biayaBongkarMuat = 250000;
    return (jarakKm * beratKg * tarifPerKmKg / 100) + biayaBongkarMuat;
  }

  @override
  int estimasiHari() => (jarakKm / 700).ceil() + 1;

  @override
  String ringkasan() => '${super.ringkasan()} | $stasiunAsal-$stasiunTujuan';
}

class PengirimanKapal extends LayananPengiriman with Terlacak, Terasuransi {
  final double volumeM3;
  final bool petiKemas;

  PengirimanKapal({
    required super.kodeLayanan,
    required super.jarakKm,
    required super.beratKg,
    required this.volumeM3,
    this.petiKemas = true,
  });

  @override
  double hitungTarif() {
    const tarifPerM3 = 850000;
    const biayaPelabuhan = 1750000;
    final tarif = (volumeM3 * tarifPerM3) + biayaPelabuhan;
    return petiKemas ? tarif : tarif * 1.2;
  }

  @override
  int estimasiHari() => (jarakKm / 320).ceil() + 3;
}

// Kelas PengirimanUdara untuk Latihan E & Tugas Praktikum F
class PengirimanUdara extends LayananPengiriman with Terlacak, Terasuransi {
  final String bandara;
  final double panjangCm;
  final double lebarCm;
  final double tinggiCm;

  PengirimanUdara({
    required super.kodeLayanan,
    required super.jarakKm,
    required super.beratKg,
    required this.bandara,
    this.panjangCm = 60,
    this.lebarCm = 50,
    this.tinggiCm = 40,
  });

  /// Berat volumetrik dari Modul 2: (p * l * t) / 6000
  double get beratVolumetrik => (panjangCm * lebarCm * tinggiCm) / 6000;

  /// Berat tertagih: membandingkan berat aktual dan volumetrik
  double get beratTertagih =>
      beratKg > beratVolumetrik ? beratKg : beratVolumetrik;

  @override
  double hitungTarif() {
    const tarifPerKg = 25000;
    const biayaBandaraTetap = 350000;
    final tarif =
        (beratTertagih * tarifPerKg) + (jarakKm * 2500) + biayaBandaraTetap;
    return tarif;
  }

  @override
  int estimasiHari() => (jarakKm / 1200).ceil();

  @override
  String ringkasan() => '${super.ringkasan()} | $bandara';
}
