import 'package:flutter/material.dart';
import '../data/preferensi.dart';
import '../data/stok_repository.dart';
import '../main.dart';
import '../model/stok.dart';

class StokPage extends StatefulWidget {
  const StokPage({super.key});

  @override
  State<StokPage> createState() => _StokPageState();
}

class _StokPageState extends State<StokPage> {
  final _repo = StokRepository.instance;
  final _pref = Preferensi();
  final _cariC = TextEditingController();

  List<Stok> _daftar = [];
  String _gudang = 'GD-BDG';
  String _kataKunci = '';
  bool _memuat = true;

  @override
  void initState() {
    super.initState();
    _muat();
  }

  @override
  void dispose() {
    _cariC.dispose();
    super.dispose();
  }

  Future<void> _muat() async {
    setState(() => _memuat = true);
    _gudang = await _pref.ambilGudangTerakhir();
    // Tugas 2: Memanggil ambilSemua dengan parameter kataKunci untuk pencarian Filter.matchesRegExp
    final data = await _repo.ambilSemua(
      kodeGudang: _gudang,
      kataKunci: _kataKunci,
    );
    if (!mounted) return;
    setState(() {
      _daftar = data;
      _memuat = false;
    });
  }

  // Tugas 1: Formulir Penambahan Stok dengan Validasi (Menggantikan Tombol Data Contoh)
  Future<void> _tampilkanFormTambahStok() async {
    final formKey = GlobalKey<FormState>();
    final kodeC = TextEditingController();
    final namaC = TextEditingController();
    final jumlahC = TextEditingController();
    String gudangPilihan = _gudang;

    final berhasil = await showDialog<bool>(
      context: context,
      builder: (ctx) {
        return StatefulBuilder(
          builder: (ctx, setDialogState) {
            return AlertDialog(
              title: const Text('Tambah Stok Barang'),
              content: SingleChildScrollView(
                child: Form(
                  key: formKey,
                  child: Column(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      TextFormField(
                        controller: kodeC,
                        textCapitalization: TextCapitalization.characters,
                        decoration: const InputDecoration(
                          labelText: 'Kode Barang',
                          hintText: 'Contoh: B-1001',
                          prefixIcon: Icon(Icons.qr_code),
                        ),
                        validator: (v) {
                          if (v == null || v.trim().isEmpty) {
                            return 'Kode barang wajib diisi';
                          }
                          return null;
                        },
                      ),
                      const SizedBox(height: 12),
                      TextFormField(
                        controller: namaC,
                        decoration: const InputDecoration(
                          labelText: 'Nama Barang',
                          hintText: 'Contoh: Laptop ThinkPad',
                          prefixIcon: Icon(Icons.inventory),
                        ),
                        validator: (v) {
                          if (v == null || v.trim().isEmpty) {
                            return 'Nama barang wajib diisi';
                          }
                          if (v.trim().length < 3) {
                            return 'Nama barang minimal 3 karakter';
                          }
                          return null;
                        },
                      ),
                      const SizedBox(height: 12),
                      TextFormField(
                        controller: jumlahC,
                        keyboardType: TextInputType.number,
                        decoration: const InputDecoration(
                          labelText: 'Jumlah Unit',
                          hintText: 'Contoh: 50',
                          prefixIcon: Icon(Icons.numbers),
                        ),
                        validator: (v) {
                          if (v == null || v.trim().isEmpty) {
                            return 'Jumlah unit wajib diisi';
                          }
                          final angka = int.tryParse(v.trim());
                          if (angka == null) {
                            return 'Jumlah harus berupa bilangan bulat';
                          }
                          if (angka < 0) {
                            return 'Jumlah tidak boleh bernilai negatif';
                          }
                          return null;
                        },
                      ),
                      const SizedBox(height: 12),
                      DropdownButtonFormField<String>(
                        value: gudangPilihan,
                        decoration: const InputDecoration(
                          labelText: 'Kode Gudang',
                          prefixIcon: Icon(Icons.warehouse),
                        ),
                        items: const [
                          DropdownMenuItem(value: 'GD-BDG', child: Text('GD-BDG (Bandung)')),
                          DropdownMenuItem(value: 'GD-JKT', child: Text('GD-JKT (Jakarta)')),
                          DropdownMenuItem(value: 'GD-SBY', child: Text('GD-SBY (Surabaya)')),
                        ],
                        onChanged: (val) {
                          if (val != null) {
                            setDialogState(() => gudangPilihan = val);
                          }
                        },
                      ),
                    ],
                  ),
                ),
              ),
              actions: [
                TextButton(
                  onPressed: () => Navigator.pop(ctx, false),
                  child: const Text('Batal'),
                ),
                FilledButton.icon(
                  icon: const Icon(Icons.save),
                  label: const Text('Simpan'),
                  onPressed: () async {
                    if (formKey.currentState!.validate()) {
                      final stokBaru = Stok(
                        kodeBarang: kodeC.text.trim().toUpperCase(),
                        namaBarang: namaC.text.trim(),
                        kodeGudang: gudangPilihan,
                        jumlah: int.parse(jumlahC.text.trim()),
                        diperbaruiPada: DateTime.now(),
                      );
                      await _repo.simpan(stokBaru);
                      if (ctx.mounted) Navigator.pop(ctx, true);
                    }
                  },
                ),
              ],
            );
          },
        );
      },
    );

    if (berhasil == true) {
      if (gudangPilihan != _gudang) {
        await _pref.simpanGudangTerakhir(gudangPilihan);
      }
      await _muat();
      if (!mounted) return;
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Data stok baru berhasil ditambahkan')),
      );
    }
    kodeC.dispose();
    namaC.dispose();
    jumlahC.dispose();
  }

  // Opsi menghapus seluruh data stok di gudang
  Future<void> _kosongkanData() async {
    final ya = await showDialog<bool>(
      context: context,
      builder: (_) => AlertDialog(
        title: const Text('Kosongkan Semua Data'),
        content: const Text('Apakah Anda yakin ingin menghapus seluruh data stok? Tindakan ini tidak dapat dibatalkan.'),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context, false),
            child: const Text('Batal'),
          ),
          FilledButton(
            style: FilledButton.styleFrom(backgroundColor: Colors.red),
            onPressed: () => Navigator.pop(context, true),
            child: const Text('Kosongkan'),
          ),
        ],
      ),
    );

    if (ya == true) {
      await _repo.kosongkan();
      await _muat();
      if (!mounted) return;
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Seluruh data stok telah dibersihkan')),
      );
    }
  }

  Future<void> _ubahJumlah(Stok stok, int delta) async {
    final baru = stok.jumlah + delta;
    if (baru < 0) return;
    await _repo.perbarui(stok.salinDengan(jumlah: baru));
    await _muat();
  }

  Future<void> _hapus(Stok stok) async {
    final ya = await showDialog<bool>(
      context: context,
      builder: (_) => AlertDialog(
        title: const Text('Hapus data stok'),
        content: Text('Hapus ${stok.namaBarang} dari gudang $_gudang?'),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context, false),
            child: const Text('Batal'),
          ),
          FilledButton(
            onPressed: () => Navigator.pop(context, true),
            child: const Text('Hapus'),
          ),
        ],
      ),
    );

    if (ya == true && stok.id != null) {
      await _repo.hapus(stok.id!);
      await _muat();
      if (!mounted) return;
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Stok ${stok.namaBarang} berhasil dihapus')),
      );
    }
  }

  Future<void> _gantiGudang(String gudangBaru) async {
    await _pref.simpanGudangTerakhir(gudangBaru);
    await _muat();
  }

  @override
  Widget build(BuildContext context) {
    final total = _daftar.fold<int>(0, (a, s) => a + s.jumlah);

    return Scaffold(
      appBar: AppBar(
        title: Text('Stok Gudang $_gudang'),
        actions: [
          // Menu Pilihan Gudang & Opsi Bersihkan Data
          PopupMenuButton<String>(
            icon: const Icon(Icons.store),
            tooltip: 'Pilih Gudang & Opsi',
            onSelected: (val) {
              if (val == 'kosongkan') {
                _kosongkanData();
              } else {
                _gantiGudang(val);
              }
            },
            itemBuilder: (_) => const [
              PopupMenuItem(value: 'GD-BDG', child: Text('Gudang Bandung (GD-BDG)')),
              PopupMenuItem(value: 'GD-JKT', child: Text('Gudang Jakarta (GD-JKT)')),
              PopupMenuItem(value: 'GD-SBY', child: Text('Gudang Surabaya (GD-SBY)')),
              PopupMenuDivider(),
              PopupMenuItem(
                value: 'kosongkan',
                child: Row(
                  children: [
                    Icon(Icons.delete_sweep, color: Colors.red, size: 20),
                    SizedBox(width: 8),
                    Text('Kosongkan Semua Data', style: TextStyle(color: Colors.red)),
                  ],
                ),
              ),
            ],
          ),
          // Tugas 3: Mode Gelap/Terang
          ValueListenableBuilder<ThemeMode>(
            valueListenable: temaAppNotifier,
            builder: (context, themeMode, _) {
              final isDark = themeMode == ThemeMode.dark;
              return IconButton(
                icon: Icon(isDark ? Icons.light_mode : Icons.dark_mode_outlined),
                tooltip: isDark ? 'Mode Terang' : 'Mode Gelap',
                onPressed: () async {
                  final baru = !isDark;
                  await Preferensi().setModeGelap(baru);
                  temaAppNotifier.value = baru ? ThemeMode.dark : ThemeMode.light;
                },
              );
            },
          ),
        ],
      ),
      body: Column(
        children: [
          // Tugas 2: Fitur Pencarian Nama Barang
          Padding(
            padding: const EdgeInsets.fromLTRB(12, 10, 12, 4),
            child: TextField(
              controller: _cariC,
              decoration: InputDecoration(
                hintText: 'Cari nama barang...',
                prefixIcon: const Icon(Icons.search),
                suffixIcon: _kataKunci.isNotEmpty
                    ? IconButton(
                        icon: const Icon(Icons.clear),
                        onPressed: () {
                          _cariC.clear();
                          _kataKunci = '';
                          _muat();
                        },
                      )
                    : null,
                border: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(12),
                ),
                contentPadding: const EdgeInsets.symmetric(horizontal: 16, vertical: 10),
              ),
              onChanged: (val) {
                _kataKunci = val;
                _muat();
              },
            ),
          ),
          Padding(
            padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
            child: Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Text(
                  'Total stok: $total unit',
                  style: const TextStyle(fontWeight: FontWeight.bold),
                ),
                Text(
                  '${_daftar.length} jenis barang',
                  style: TextStyle(color: Theme.of(context).colorScheme.outline),
                ),
              ],
            ),
          ),
          const Divider(height: 1),
          Expanded(
            child: _memuat
                ? const Center(child: CircularProgressIndicator())
                : _daftar.isEmpty
                    ? Center(
                        child: Text(
                          _kataKunci.isNotEmpty
                              ? 'Tidak ada barang cocok dengan "$_kataKunci"'
                              : 'Belum ada data stok di gudang $_gudang',
                          style: TextStyle(color: Theme.of(context).colorScheme.outline),
                        ),
                      )
                    : ListView.builder(
                        itemCount: _daftar.length,
                        itemBuilder: (context, i) {
                          final s = _daftar[i];
                          return Card(
                            margin: const EdgeInsets.symmetric(horizontal: 12, vertical: 4),
                            child: ListTile(
                              leading: CircleAvatar(
                                child: Text('${i + 1}'),
                              ),
                              title: Text(
                                s.namaBarang,
                                style: const TextStyle(fontWeight: FontWeight.w600),
                              ),
                              subtitle: Text('${s.kodeBarang} • Gudang: ${s.kodeGudang}'),
                              trailing: Row(
                                mainAxisSize: MainAxisSize.min,
                                children: [
                                  IconButton(
                                    icon: const Icon(Icons.remove_circle_outline, color: Colors.orange),
                                    tooltip: 'Kurangi',
                                    onPressed: () => _ubahJumlah(s, -1),
                                  ),
                                  Text(
                                    '${s.jumlah}',
                                    style: const TextStyle(
                                      fontWeight: FontWeight.bold,
                                      fontSize: 15,
                                    ),
                                  ),
                                  IconButton(
                                    icon: const Icon(Icons.add_circle_outline, color: Colors.green),
                                    tooltip: 'Tambah',
                                    onPressed: () => _ubahJumlah(s, 1),
                                  ),
                                  IconButton(
                                    icon: const Icon(Icons.delete_outline, color: Colors.red),
                                    tooltip: 'Hapus',
                                    onPressed: () => _hapus(s),
                                  ),
                                ],
                              ),
                            ),
                          );
                        },
                      ),
          ),
        ],
      ),
      floatingActionButton: FloatingActionButton.extended(
        onPressed: _tampilkanFormTambahStok,
        icon: const Icon(Icons.add),
        label: const Text('Tambah Stok'),
      ),
      bottomNavigationBar: const SafeArea(
        child: Padding(
          padding: EdgeInsets.all(8),
          child: Text(
            'Muhammad Malik Nur - 714240062',
            textAlign: TextAlign.center,
            style: TextStyle(fontSize: 12),
          ),
        ),
      ),
    );
  }
}
