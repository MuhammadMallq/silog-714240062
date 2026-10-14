class Pelanggan {
  final String kode;
  final String nama;
  final String telepon;
  final String alamat;

  Pelanggan({
    required this.kode,
    required this.nama,
    required this.telepon,
    required this.alamat,
  });

  /// Mengembalikan alamat maksimal 40 karakter.
  /// Jika alamat lebih dari 40 karakter, dipotong hingga 37 karakter dan ditambah '...'.
  String alamatRingkas() {
    if (alamat.length <= 40) {
      return alamat;
    }
    return '${alamat.substring(0, 37)}...';
  }

  @override
  String toString() => '$kode - $nama ($telepon)';
}
