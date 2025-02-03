import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:supabase_flutter/supabase_flutter.dart';
import 'package:ukk_coba/pesanan.dart';
import 'package:ukk_coba/produk.dart';
import 'package:ukk_coba/profile.dart';
import 'bottomnavbar.dart';
class Riwayat extends StatefulWidget {
  const Riwayat({super.key});

  @override
  State<Riwayat> createState() => _RiwayatState();
}

class _RiwayatState extends State<Riwayat> {
  int _selectedIndex = 2;
  List<Map<String, dynamic>> transaksiList = [];

  @override
  void initState() {
    super.initState();
    fetchRiwayat();
  }

  // Langkah 1: Mengambil data transaksi dari tabel 'penjualan' dan detail transaksi
  Future<void> fetchRiwayat() async {
    try {
      final supabase = Supabase.instance.client;

      // Ambil data dari tabel 'penjualan' beserta nama pelanggan, diurutkan dari yang terbaru
      final penjualanResponse = await supabase
          .from('penjualan')
          .select('*, pelanggan(nama_pelanggan)')
          .order('tgl_penjualan', ascending: false) // Urutkan dari yang terbaru
          .order('penjualan_id',
              ascending: false); // Pastikan urutan berdasarkan ID terbaru

      if (penjualanResponse.isNotEmpty) {
        final futures = penjualanResponse.map((penjualan) async {
          final detailResponse = await supabase
              .from('detail_penjualan')
              .select('*, produk(nama_produk)')
              .eq('penjualan_id', penjualan['penjualan_id'])
              .order('detail_id',
                  ascending:
                      false); // Pastikan produk juga terurut dari yang terbaru

          return {
            'penjualan': penjualan,
            'details': detailResponse,
          };
        }).toList();

        final results = await Future.wait(futures);

        setState(() {
          transaksiList = results
              .where((result) => result != null)
              .cast<Map<String, dynamic>>()
              .toList();
        });
      }
    } catch (e) {
      ScaffoldMessenger.of(context).showSnackBar(SnackBar(
        content: Text('Terjadi kesalahan: $e'),
      ));
    }
  }

  // Langkah 2: Menyegarkan data transaksi
  Future<void> refreshRiwayat() async {
    await fetchRiwayat(); // Panggil ulang fetchRiwayat untuk mengambil data terbaru
  }

  // Langkah 3: Menghapus riwayat transaksi
  Future<void> deleteRiwayat(int penjualanId) async {
    try {
      final supabase = Supabase.instance.client;

      // Hapus data di detail_penjualan berdasarkan penjualan_id
      await supabase
          .from('detail_penjualan')
          .delete()
          .eq('penjualan_id', penjualanId);

      // Hapus data di penjualan berdasarkan penjualan_id
      await supabase.from('penjualan').delete().eq('penjualan_id', penjualanId);

      // Setelah penghapusan, refresh daftar riwayat transaksi
      refreshRiwayat();
      ScaffoldMessenger.of(context).showSnackBar(SnackBar(
        content: Text('Riwayat transaksi berhasil dihapus'),
      ));
    } catch (e) {
      ScaffoldMessenger.of(context).showSnackBar(SnackBar(
        content: Text('Terjadi kesalahan: $e'),
      ));
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFFF6F8FC),
      appBar: AppBar(
        automaticallyImplyLeading: false,
        title: Text(
          'Riwayat Transaksi',
          style: GoogleFonts.poppins(
            fontSize: 24,
            fontWeight: FontWeight.w600,
            color: const Color(0xFF000957),
          ),
        ),
      ),
      body: RefreshIndicator(
        onRefresh: refreshRiwayat, // Menyegarkan data dengan geser ke bawah
        child: transaksiList.isEmpty
            ? const Center(child: CircularProgressIndicator())
            : ListView.builder(
                padding: const EdgeInsets.all(12),
                itemCount: transaksiList.length,
                itemBuilder: (context, index) {
                  final transaksi = transaksiList[index];
                  final penjualan = transaksi['penjualan'];
                  final details = transaksi['details'];

                  // Mengambil nama pelanggan dari relasi 'pelanggan'
                  final namaPelanggan = penjualan['pelanggan'] != null
                      ? penjualan['pelanggan']['nama_pelanggan']
                      : 'User';

                  return Card(
                    margin: const EdgeInsets.only(bottom: 16),
                    elevation: 4,
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(12),
                    ),
                    child: Padding(
                      padding: const EdgeInsets.all(16),
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          // Menampilkan Nama Pelanggan
                          Text(
                            'Pelanggan: $namaPelanggan',
                            style: GoogleFonts.poppins(
                              fontSize: 14,
                              fontWeight: FontWeight.w600,
                              color: const Color(0xFF074799),
                            ),
                          ),
                          const SizedBox(height: 8),

                          // Header Transaksi
                          Row(
                            mainAxisAlignment: MainAxisAlignment.spaceBetween,
                            children: [
                              Column(
                                crossAxisAlignment: CrossAxisAlignment.start,
                                children: [
                                  Text(
                                    'Tanggal: ${penjualan['tgl_penjualan']}',
                                    style: GoogleFonts.poppins(
                                      fontSize: 14,
                                      fontWeight: FontWeight.w500,
                                    ),
                                  ),
                                ],
                              ),
                              Text(
                                'Total: Rp ${penjualan['total_harga'].toStringAsFixed(0)}',
                                style: GoogleFonts.poppins(
                                  fontSize: 14,
                                  fontWeight: FontWeight.bold,
                                  color: Colors.green,
                                ),
                              ),
                            ],
                          ),
                          const SizedBox(height: 12),
                          const Divider(),
                          const SizedBox(height: 8),

                          // Detail Produk
                          ListView.builder(
                            shrinkWrap: true,
                            physics: const NeverScrollableScrollPhysics(),
                            itemCount: details.length,
                            itemBuilder: (context, detailIndex) {
                              final detail = details[detailIndex];
                              final namaProduk = detail['produk'] != null
                                  ? detail['produk']['nama_produk']
                                  : 'Produk tidak ditemukan';

                              return Padding(
                                padding: const EdgeInsets.symmetric(
                                    vertical: 4), // Spasi antar produk
                                child: Column(
                                  crossAxisAlignment: CrossAxisAlignment.start,
                                  children: [
                                    // Menampilkan label "Produk :" hanya untuk produk pertama
                                    if (detailIndex == 0)
                                      Text(
                                        'Produk :',
                                        style: GoogleFonts.poppins(
                                          fontSize: 13,
                                          fontWeight: FontWeight.bold,
                                        ),
                                      ),
                                    const SizedBox(height: 5),
                                    Text(
                                      '$namaProduk | ${detail['jumlah_produk']}',
                                      style: GoogleFonts.poppins(
                                        fontSize: 13,
                                        fontWeight: FontWeight.w500,
                                      ),
                                    ),
                                    const SizedBox(height: 5),
                                    Text(
                                      'Total : Rp ${detail['subtotal'].toStringAsFixed(0)}',
                                      style: GoogleFonts.poppins(
                                        fontSize: 13,
                                        fontWeight: FontWeight.w600,
                                        color: Colors.blueGrey,
                                      ),
                                    ),
                                  ],
                                ),
                              );
                            },
                          ),

                          // Tombol Hapus Riwayat
                          const SizedBox(height: 16),
                          ElevatedButton.icon(
                            onPressed: () {
                              // Konfirmasi sebelum menghapus
                              showDialog(
                                context: context,
                                builder: (context) => AlertDialog(
                                  title: const Text('Hapus Riwayat Transaksi'),
                                  content: const Text(
                                      'Apakah Anda yakin ingin menghapus riwayat transaksi ini?'),
                                  actions: [
                                    TextButton(
                                      onPressed: () {
                                        Navigator.pop(context); // Tutup dialog
                                      },
                                      child: const Text('Batal'),
                                    ),
                                    TextButton(
                                      onPressed: () {
                                        // Menghapus transaksi
                                        deleteRiwayat(
                                            penjualan['penjualan_id']);
                                        Navigator.pop(context); // Tutup dialog
                                      },
                                      child: const Text('Hapus'),
                                    ),
                                  ],
                                ),
                              );
                            },
                            icon: const Icon(Icons.delete),
                            label: const Text('Hapus Riwayat'),
                            style: ElevatedButton.styleFrom(
                              iconColor: Colors.red,
                              backgroundColor: Colors.white,
                            ),
                          ),
                        ],
                      ),
                    ),
                  );
                },
              ),
      ),
      bottomNavigationBar: BottomNavBar(),
    );
  }

}
