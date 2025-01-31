import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:supabase_flutter/supabase_flutter.dart';
import 'package:ukk_coba/pesanan.dart';
import 'package:ukk_coba/produk.dart';
import 'package:ukk_coba/profile.dart';

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

      // Ambil data dari tabel 'penjualan' beserta nama pelanggan
      final penjualanResponse = await supabase
          .from('penjualan')
          .select('*, pelanggan(nama_pelanggan)')
          .order('tgl_penjualan');

      if (penjualanResponse.isNotEmpty) {
        final futures = penjualanResponse.map((penjualan) async {
          final detailResponse = await supabase
              .from('detail_penjualan')
              .select('*, produk(nama_produk)')
              .eq('penjualan_id', penjualan['penjualan_id']);

          if (detailResponse.isNotEmpty) {
            return {
              'penjualan': penjualan,
              'details': detailResponse,
            };
          }
          return null;
        }).toList();

        final results = await Future.wait(futures);

        // Filter data null dan tambahkan ke transaksiList
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
      await supabase
          .from('penjualan')
          .delete()
          .eq('penjualan_id', penjualanId);

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
            color: const Color(0xFF074799),
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
                                padding: const EdgeInsets.symmetric(vertical: 8),
                                child: Row(
                                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                                  children: [
                                    Expanded(
                                      child: Text(
                                        'Produk: $namaProduk',
                                        style: GoogleFonts.poppins(
                                          fontSize: 13,
                                          fontWeight: FontWeight.w500,
                                        ),
                                      ),
                                    ),
                                    Text(
                                      'Jumlah: ${detail['jumlah_produk']}',
                                      style: GoogleFonts.poppins(
                                        fontSize: 13,
                                        fontWeight: FontWeight.w400,
                                      ),
                                    ),
                                    const SizedBox(width: 8),
                                    Text(
                                      'Subtotal: Rp ${detail['subtotal'].toStringAsFixed(0)}',
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
                                        deleteRiwayat(penjualan['penjualan_id']);
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
      bottomNavigationBar: _buildBottomNavBar(),
    );
  }

  BottomNavigationBar _buildBottomNavBar() {
    return BottomNavigationBar(
      currentIndex: _selectedIndex,
      onTap: (index) {
        if (_selectedIndex != index) {
          setState(() {
            _selectedIndex = index;
          });

          switch (index) {
            case 0:
              Navigator.pushAndRemoveUntil(
                context,
                MaterialPageRoute(builder: (context) => const Produk()),
                (Route<dynamic> route) => false,
              );
              break;
            case 1:
              Navigator.pushAndRemoveUntil(
                context,
                MaterialPageRoute(builder: (context) => const Pesanan()),
                (Route<dynamic> route) => false,
              );
              break;
            case 2:
              break;
            case 3:
              Navigator.pushAndRemoveUntil(
                context,
                MaterialPageRoute(builder: (context) => const ProfilPage()),
                (Route<dynamic> route) => false,
              );
              break;
          }
        }
      },
      selectedItemColor: const Color(0xFF074799),
      unselectedItemColor: Colors.grey,
      items: const [
        BottomNavigationBarItem(
          icon: Icon(Icons.store_mall_directory_outlined),
          label: 'Produk',
        ),
        BottomNavigationBarItem(
          icon: Icon(Icons.shopping_bag_outlined),
          label: 'Pesanan',
        ),
        BottomNavigationBarItem(
          icon: Icon(Icons.history_outlined),
          label: 'Riwayat',
        ),
        BottomNavigationBarItem(
          icon: Icon(Icons.person_outline),
          label: 'Profil',
        ),
      ],
    );
  }
}
