import 'package:flutter/material.dart';
import '../model/pengiriman.dart';

class DetailPengirimanPage extends StatelessWidget {
  final Pengiriman pengiriman;

  const DetailPengirimanPage({
    super.key,
    required this.pengiriman,
  });

  void _tampilkanDialogKonfirmasi(BuildContext context) {
    showDialog(
      context: context,
      builder: (BuildContext dialogContext) {
        return AlertDialog(
          title: const Text('Konfirmasi Hapus'),
          content: Text(
            'Apakah Anda yakin ingin menghapus data pengiriman resi ${pengiriman.resi}?',
          ),
          actions: [
            TextButton(
              onPressed: () => Navigator.pop(dialogContext),
              child: const Text('Batal'),
            ),
            FilledButton(
              style: FilledButton.styleFrom(backgroundColor: Colors.red),
              onPressed: () {
                Navigator.pop(dialogContext); // 1. Tutup AlertDialog
                Navigator.pop(context, pengiriman.resi); // 2. Kembalikan resi ke halaman daftar
              },
              child: const Text('Hapus'),
            ),
          ],
        );
      },
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text('Detail: ${pengiriman.resi}'),
        actions: [
          IconButton(
            icon: const Icon(Icons.delete, color: Colors.red),
            onPressed: () => _tampilkanDialogKonfirmasi(context),
          ),
        ],
      ),
      body: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              'Resi: ${pengiriman.resi}',
              style: const TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
            ),
            const SizedBox(height: 8),
            Text('Kota Tujuan: ${pengiriman.kotaTujuan}'),
            Text('Status: ${pengiriman.status}'),
            Text('Nama Barang: ${pengiriman.barang.nama}'),
            Text('Harga Satuan: Rp ${pengiriman.barang.hargaSatuan}'),
            Text('Jumlah: ${pengiriman.barang.jumlah}'),
            const Spacer(),
            SizedBox(
              width: double.infinity,
              child: OutlinedButton.icon(
                style: OutlinedButton.styleFrom(foregroundColor: Colors.red),
                onPressed: () => _tampilkanDialogKonfirmasi(context),
                icon: const Icon(Icons.delete),
                label: const Text('Hapus Data Pengiriman'),
              ),
            ),
          ],
        ),
      ),
    );
  }
}