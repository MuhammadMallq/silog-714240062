class Order {
  final int? id;
  final int idPelanggan;
  final String judul;
  final String keterangan;

  Order({
    this.id,
    required this.idPelanggan,
    required this.judul,
    required this.keterangan,
  });

  factory Order.fromJson(Map<String, dynamic> json) => Order(
        id: json['id'] as int?,
        idPelanggan: json['userId'] as int? ?? 0,
        judul: (json['title'] as String?) ?? '(tanpa judul)',
        keterangan: (json['body'] as String?) ?? '',
      );

  Map<String, dynamic> toJson() => {
        'userId': idPelanggan,
        'title': judul,
        'body': keterangan,
      };

  Map<String, dynamic> toMap() => {
        if (id != null) 'id': id,
        'userId': idPelanggan,
        'title': judul,
        'body': keterangan,
      };

  factory Order.fromMap(int key, Map<String, dynamic> map) => Order(
        id: (map['id'] as int?) ?? key,
        idPelanggan: map['userId'] as int? ?? 0,
        judul: (map['title'] as String?) ?? '(tanpa judul)',
        keterangan: (map['body'] as String?) ?? '',
      );

  Order copyWith({
    int? id,
    int? idPelanggan,
    String? judul,
    String? keterangan,
  }) {
    return Order(
      id: id ?? this.id,
      idPelanggan: idPelanggan ?? this.idPelanggan,
      judul: judul ?? this.judul,
      keterangan: keterangan ?? this.keterangan,
    );
  }

  @override
  String toString() => 'Order#$id $judul';
}

