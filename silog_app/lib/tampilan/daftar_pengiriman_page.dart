import 'package:flutter/material.dart';
import '../data/data_contoh.dart';
import '../model/pengiriman.dart';
import '../widget/kartu_pengiriman.dart';
import 'detail_pengiriman_page.dart';
import 'form_pengiriman_page.dart';

class DaftarPengirimanPage extends StatefulWidget {
  const DaftarPengirimanPage({super.key});

  @override
  State<DaftarPengirimanPage> createState() => _DaftarPengirimanPageState();
}

class _DaftarPengirimanPageState extends State<DaftarPengirimanPage> {
  late List<Pengiriman> _daftar;
  String _filterStatus = 'Semua';

  @override
  void initState() {
    super.initState();
    _daftar = List<Pengiriman>.from(dataPengiriman);
  }

  List<Pengiriman> get _hasilSaring => _filterStatus == 'Semua'
      ? _daftar
      : _daftar.where((p) => p.status == _filterStatus).toList();

  Future<void> _bukaFormulir() async {
    // Tugas 2: Mengirimkan daftar resi yang sudah ada untuk pengecekan duplikat
    final listResi = _daftar.map((e) => e.resi).toList();

    final hasil = await Navigator.push<Pengiriman>(
      context,
      MaterialPageRoute(
        builder: (_) => FormPengirimanPage(daftarResiAda: listResi),
      ),
    );

    if (hasil != null) {
      setState(() => _daftar.insert(0, hasil));
      if (!mounted) return;
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text('Pengiriman ${hasil.resi} berhasil ditambahkan'),
        ),
      );
    }
  }

Future<void> _bukaDetail(Pengiriman item) async {
    // Menunggu resi yang dikembalikan dari DetailPengirimanPage
    final resiDihapus = await Navigator.push<String>(
      context,
      MaterialPageRoute(
        builder: (_) => DetailPengirimanPage(pengiriman: item),
      ),
    );

    // Jika ada resi yang dikembalikan (artinya pengguna menekan tombol Hapus)
    if (resiDihapus != null) {
      setState(() {
        _daftar.removeWhere((p) => p.resi.trim() == resiDihapus.trim());
      });
      if (!mounted) return;
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text('Pengiriman $resiDihapus berhasil dihapus'),
        ),
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    const opsi = ['Semua', 'Menunggu Pickup', 'Dalam Perjalanan', 'Diterima'];
    return Scaffold(
      appBar: AppBar(title: const Text('Daftar Pengiriman')),
      body: Column(
        children: [
          SingleChildScrollView(
            scrollDirection: Axis.horizontal,
            padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
            child: Row(
              children: opsi.map((o) {
                return Padding(
                  padding: const EdgeInsets.only(right: 8),
                  child: ChoiceChip(
                    label: Text(o),
                    selected: _filterStatus == o,
                    onSelected: (_) => setState(() => _filterStatus = o),
                  ),
                );
              }).toList(),
            ),
          ),
          Padding(
            padding: const EdgeInsets.symmetric(vertical: 4),
            child: Text(
              'Menampilkan ${_hasilSaring.length} dari ${_daftar.length} data',
            ),
          ),
          Expanded(
            child: _hasilSaring.isEmpty
                ? const Center(child: Text('Tidak ada data pengiriman'))
                : ListView.builder(
                    itemCount: _hasilSaring.length,
                    itemBuilder: (context, i) {
                      final item = _hasilSaring[i];
                      return KartuPengiriman(
                        pengiriman: item,
                        onTap: () => _bukaDetail(item),
                      );
                    },
                  ),
          ),
        ],
      ),
      floatingActionButton: FloatingActionButton.extended(
        onPressed: _bukaFormulir,
        icon: const Icon(Icons.add),
        label: const Text('Pengiriman Baru'),
      ),
      bottomNavigationBar: const SafeArea(
        child: Padding
          (padding: EdgeInsets.all(8), 
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
