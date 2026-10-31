import 'package:flutter/material.dart';
import '../data/data_contoh.dart';
import '../model/pengiriman.dart';
import '../widget/kartu_pengiriman.dart';
import '../widget/ringkasan_pengiriman.dart';
import 'detail_pengiriman_page.dart';

class DaftarPengirimanPage extends StatelessWidget {
  const DaftarPengirimanPage({super.key});

  Widget _buildListPengiriman(
    BuildContext context,
    List<Pengiriman> daftar,
  ) {
    if (daftar.isEmpty) {
      return const Center(
        child: Text('Tidak ada data pengiriman'),
      );
    }

    return ListView.builder(
      itemCount: daftar.length,
      itemBuilder: (context, index) {
        final item = daftar[index];
        return KartuPengiriman(
          pengiriman: item,
          onTap: () {
            Navigator.push(
              context,
              MaterialPageRoute(
                builder: (_) => DetailPengirimanPage(pengiriman: item),
              ),
            );
          },
        );
      },
    );
  }

  @override
  Widget build(BuildContext context) {
    final daftarSemua = dataPengiriman;
    final daftarDalamPerjalanan =
        dataPengiriman.where((p) => p.status == 'Dalam Perjalanan').toList();
    final daftarDiterima =
        dataPengiriman.where((p) => p.status == 'Diterima').toList();

    final int totalPengiriman = dataPengiriman.length;
    final double totalNilaiBarang = dataPengiriman.fold<double>(
      0.0,
      (total, item) => total + item.nilaiBarang,
    );

    return DefaultTabController(
      length: 3,
      child: Scaffold(
        appBar: AppBar(
          title: const Text('Daftar Pengiriman'),
          actions: [
            IconButton(
              icon: const Icon(Icons.search),
              onPressed: () {},
              tooltip: 'Cari resi',
            ),
          ],
          bottom: const TabBar(
            tabs: [
              Tab(text: 'Semua'),
              Tab(text: 'Dalam Perjalanan'),
              Tab(text: 'Diterima'),
            ],
          ),
        ),
        body: Column(
          children: [
            RingkasanPengiriman(
              totalPengiriman: totalPengiriman,
              totalNilaiBarang: totalNilaiBarang,
            ),
            Expanded(
              child: TabBarView(
                children: [
                  _buildListPengiriman(context, daftarSemua),
                  _buildListPengiriman(context, daftarDalamPerjalanan),
                  _buildListPengiriman(context, daftarDiterima),
                ],
              ),
            ),
          ],
        ),
        floatingActionButton: FloatingActionButton.extended(
          onPressed: () {},
          icon: const Icon(Icons.add),
          label: const Text('Pengiriman Baru'),
        ),
      ),
    );
  }
}

