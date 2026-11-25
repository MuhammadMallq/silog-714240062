import 'package:flutter/material.dart';
import '../data/order_api.dart';
import '../data/order_repository.dart';
import '../model/order.dart';

class OrderPage extends StatefulWidget {
  const OrderPage({super.key});

  @override
  State<OrderPage> createState() => _OrderPageState();
}

class _OrderPageState extends State<OrderPage> {
  final _api = OrderApi();
  final _cache = OrderRepository.instance;
  late Future<List<Order>> _future;

  String? _pesanPeringatan;
  final TextEditingController _cariController = TextEditingController();
  String _kataKunci = '';

  @override
  void initState() {
    super.initState();
    _future = _ambilDenganCadangan();
  }

  @override
  void dispose() {
    _cariController.dispose();
    _api.tutup();
    super.dispose();
  }

  /// Kode Program 9.4: Pengambilan data dengan cadangan lokal Sembast
  Future<List<Order>> _ambilDenganCadangan() async {
    _pesanPeringatan = null;
    try {
      final daring = await _api.ambilDaftar();
      await _cache.simpanSemua(daring); // simpan salinan lokal
      return daring;
    } on GagalApi catch (e) {
      final lokal = await _cache.ambilSemua();
      if (lokal.isEmpty) rethrow;
      _pesanPeringatan = 'Menampilkan data tersimpan. $e';
      // Memicu rebuild agar banner peringatan kuning ditampilkan
      if (mounted) setState(() {});
      return lokal;
    }
  }

  Future<void> _muatUlang() async {
    setState(() {
      _future = _ambilDenganCadangan();
    });
  }

  Future<void> _kirimContoh() async {
    try {
      final hasil = await _api.kirimOrder(Order(
        idPelanggan: 7,
        judul: 'Order pengiriman Bandung - Surabaya',
        keterangan: '3 koli, berat total 42 kg, layanan reguler',
      ));
      if (!mounted) return;
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text('Order terkirim dengan id ${hasil.id}'),
          backgroundColor: Colors.green.shade700,
        ),
      );
      // Muat ulang daftar setelah mengirim
      _muatUlang();
    } on GagalApi catch (e) {
      if (!mounted) return;
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text('Gagal: $e'),
          backgroundColor: Colors.red.shade700,
        ),
      );
    }
  }

  /// Tugas Praktikum 2: Menguji metode PUT untuk memperbarui order
  Future<void> _dialogUbah(Order order) async {
    final judulC = TextEditingController(text: order.judul);
    final ketC = TextEditingController(text: order.keterangan);

    final diubah = await showDialog<bool>(
      context: context,
      builder: (ctx) => AlertDialog(
        title: Text('Perbarui Order #${order.id}'),
        content: SingleChildScrollView(
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              TextField(
                controller: judulC,
                decoration: const InputDecoration(
                  labelText: 'Judul Order',
                  border: OutlineInputBorder(),
                ),
              ),
              const SizedBox(height: 12),
              TextField(
                controller: ketC,
                maxLines: 3,
                decoration: const InputDecoration(
                  labelText: 'Keterangan Order',
                  border: OutlineInputBorder(),
                ),
              ),
            ],
          ),
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(ctx, false),
            child: const Text('Batal'),
          ),
          FilledButton(
            onPressed: () => Navigator.pop(ctx, true),
            child: const Text('Simpan'),
          ),
        ],
      ),
    );

    if (diubah == true) {
      try {
        final orderBaru = order.copyWith(
          judul: judulC.text.trim(),
          keterangan: ketC.text.trim(),
        );
        final hasil = await _api.perbaruiOrder(orderBaru);
        if (!mounted) return;
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('Order #${hasil.id} berhasil diperbarui (HTTP 200)'),
            backgroundColor: Colors.teal.shade700,
          ),
        );
        _muatUlang();
      } on GagalApi catch (e) {
        if (!mounted) return;
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('Gagal perbarui: $e'),
            backgroundColor: Colors.red.shade700,
          ),
        );
      }
    }
  }

  /// Tugas Praktikum 2: Menguji metode DELETE untuk menghapus order
  Future<void> _konfirmasiHapus(Order order) async {
    final konfirmasi = await showDialog<bool>(
      context: context,
      builder: (ctx) => AlertDialog(
        title: const Text('Hapus Order'),
        content: Text('Yakin ingin menghapus Order #${order.id} - "${order.judul}"?'),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(ctx, false),
            child: const Text('Batal'),
          ),
          FilledButton(
            style: FilledButton.styleFrom(backgroundColor: Colors.red),
            onPressed: () => Navigator.pop(ctx, true),
            child: const Text('Hapus'),
          ),
        ],
      ),
    );

    if (konfirmasi == true && order.id != null) {
      try {
        await _api.hapusOrder(order.id!);
        if (!mounted) return;
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('Order #${order.id} berhasil dihapus (HTTP 200)'),
            backgroundColor: Colors.red.shade700,
          ),
        );
        _muatUlang();
      } on GagalApi catch (e) {
        if (!mounted) return;
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('Gagal hapus: $e'),
            backgroundColor: Colors.red.shade700,
          ),
        );
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Order dari Layanan Web'),
        actions: [
          IconButton(
            icon: const Icon(Icons.refresh),
            tooltip: 'Muat Ulang',
            onPressed: _muatUlang,
          ),
        ],
      ),
      body: Column(
        children: [
          // Banner peringatan bila menggunakan cadangan lokal (Modul 9 Bagian F)
          if (_pesanPeringatan != null)
            Container(
              width: double.infinity,
              padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 10),
              color: Colors.amber.shade100,
              child: Row(
                children: [
                  Icon(Icons.cloud_off, color: Colors.amber.shade900, size: 20),
                  const SizedBox(width: 8),
                  Expanded(
                    child: Text(
                      _pesanPeringatan!,
                      style: TextStyle(
                        color: Colors.amber.shade900,
                        fontSize: 12,
                        fontWeight: FontWeight.w600,
                      ),
                    ),
                  ),
                ],
              ),
            ),

          // Tugas Praktikum 1: Fitur pencarian order berdasarkan kata kunci pada judul di sisi aplikasi
          Padding(
            padding: const EdgeInsets.fromLTRB(16, 12, 16, 8),
            child: TextField(
              controller: _cariController,
              decoration: InputDecoration(
                hintText: 'Cari judul order...',
                prefixIcon: const Icon(Icons.search),
                suffixIcon: _kataKunci.isNotEmpty
                    ? IconButton(
                        icon: const Icon(Icons.clear),
                        onPressed: () {
                          _cariController.clear();
                          setState(() => _kataKunci = '');
                        },
                      )
                    : null,
                filled: true,
                contentPadding: const EdgeInsets.symmetric(vertical: 0, horizontal: 16),
                border: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(10),
                  borderSide: BorderSide.none,
                ),
              ),
              onChanged: (val) {
                setState(() => _kataKunci = val);
              },
            ),
          ),

          // Tampilan daftar order menggunakan FutureBuilder (Kode Program 9.3)
          Expanded(
            child: FutureBuilder<List<Order>>(
              future: _future,
              builder: (context, snapshot) {
                if (snapshot.connectionState == ConnectionState.waiting) {
                  return const Center(child: CircularProgressIndicator());
                }

                if (snapshot.hasError) {
                  return Center(
                    child: Padding(
                      padding: const EdgeInsets.all(24),
                      child: Column(
                        mainAxisAlignment: MainAxisAlignment.center,
                        children: [
                          const Icon(Icons.cloud_off, size: 56, color: Colors.grey),
                          const SizedBox(height: 12),
                          Text(
                            '${snapshot.error}',
                            textAlign: TextAlign.center,
                            style: const TextStyle(fontSize: 14),
                          ),
                          const SizedBox(height: 16),
                          FilledButton.icon(
                            onPressed: _muatUlang,
                            icon: const Icon(Icons.refresh),
                            label: const Text('Coba Lagi'),
                          ),
                        ],
                      ),
                    ),
                  );
                }

                final semuaData = snapshot.data ?? [];

                // Filter kata kunci pada judul sisi aplikasi (Tugas Praktikum 1)
                final data = _kataKunci.trim().isEmpty
                    ? semuaData
                    : semuaData.where((o) {
                        return o.judul
                            .toLowerCase()
                            .contains(_kataKunci.trim().toLowerCase());
                      }).toList();

                if (data.isEmpty) {
                  return Center(
                    child: Column(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        Icon(
                          _kataKunci.isNotEmpty
                              ? Icons.search_off
                              : Icons.inbox_outlined,
                          size: 48,
                          color: Colors.grey,
                        ),
                        const SizedBox(height: 8),
                        Text(
                          _kataKunci.isNotEmpty
                              ? 'Tidak ada order yang cocok dengan "$_kataKunci"'
                              : 'Belum ada order yang tercatat',
                          style: const TextStyle(color: Colors.grey),
                        ),
                      ],
                    ),
                  );
                }

                return RefreshIndicator(
                  onRefresh: _muatUlang,
                  child: ListView.separated(
                    itemCount: data.length,
                    separatorBuilder: (_, __) => const Divider(height: 1),
                    itemBuilder: (context, i) {
                      final o = data[i];
                      return ListTile(
                        leading: CircleAvatar(
                          child: Text('${o.id ?? i + 1}'),
                        ),
                        title: Text(
                          o.judul,
                          maxLines: 1,
                          overflow: TextOverflow.ellipsis,
                          style: const TextStyle(fontWeight: FontWeight.w600),
                        ),
                        subtitle: Text(
                          o.keterangan,
                          maxLines: 2,
                          overflow: TextOverflow.ellipsis,
                        ),
                        trailing: Row(
                          mainAxisSize: MainAxisSize.min,
                          children: [
                            Container(
                              padding: const EdgeInsets.symmetric(horizontal: 6, vertical: 2),
                              decoration: BoxDecoration(
                                color: Theme.of(context).colorScheme.primaryContainer,
                                borderRadius: BorderRadius.circular(6),
                              ),
                              child: Text(
                                'Plg ${o.idPelanggan}',
                                style: TextStyle(
                                  fontSize: 11,
                                  color: Theme.of(context).colorScheme.onPrimaryContainer,
                                  fontWeight: FontWeight.bold,
                                ),
                              ),
                            ),
                            IconButton(
                              icon: const Icon(Icons.edit_outlined, size: 18),
                              tooltip: 'Edit Order',
                              onPressed: () => _dialogUbah(o),
                            ),
                            IconButton(
                              icon: const Icon(Icons.delete_outline, size: 18, color: Colors.red),
                              tooltip: 'Hapus Order',
                              onPressed: () => _konfirmasiHapus(o),
                            ),
                          ],
                        ),
                      );
                    },
                  ),
                );
              },
            ),
          ),
        ],
      ),
      floatingActionButton: FloatingActionButton.extended(
        onPressed: _kirimContoh,
        icon: const Icon(Icons.cloud_upload),
        label: const Text('Kirim Order'),
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

