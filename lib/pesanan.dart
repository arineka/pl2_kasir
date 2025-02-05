import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:supabase_flutter/supabase_flutter.dart';
// import 'package:ukk_coba/checkout.dart';
import 'package:ukk_coba/history.dart';
import 'package:ukk_coba/pelanggan.dart';
import 'package:ukk_coba/produk.dart';
import 'package:ukk_coba/profile.dart'; // Pastikan file ini ada
import 'bottomnavbar.dart';

class Pesanan extends StatefulWidget {
  const Pesanan({Key? key}) : super(key: key);

  @override
  State<Pesanan> createState() => _PesananState();
}

class _PesananState extends State<Pesanan> {
  final SupabaseClient supabase = Supabase.instance.client;

  int _selectedIndex = 1; // Index awal untuk Pesanan
  List<Map<String, dynamic>> produkList = [];
  List<Map<String, dynamic>> pelangganList = [];
  Map<String, dynamic>? selectedPelanggan;
  List<Map<String, dynamic>> keranjang = [];
  double totalHarga = 0.0;

  @override
  void initState() {
    super.initState();
    _fetchProduk();
    _fetchPelanggan();
  }

  Future<void> _fetchProduk() async {
    final response = await supabase.from('produk').select();
    if (response != null) {
      setState(() {
        produkList = (response as List).cast<Map<String, dynamic>>();
      });
    } else {
      ScaffoldMessenger.of(context).showSnackBar(const SnackBar(
        content: Text('Gagal memuat data produk'),
      ));
    }
  }

  Future<void> _fetchPelanggan() async {
    //mengambil data pelanggan
    final response = await supabase.from('pelanggan').select();
    if (response != null) {
      setState(() {
        pelangganList = (response as List).cast<Map<String, dynamic>>();
      });
    } else {
      ScaffoldMessenger.of(context).showSnackBar(const SnackBar(
        content: Text('Gagal memuat data pelanggan'),
      ));
    }
  }

  void _addToCart(Map<String, dynamic> produk, int jumlah) {
    //menambahkan produk ke keranjang
    // Cek apakah produk sudah ada dalam keranjang
    final existingItemIndex = keranjang.indexWhere(
      (item) => item['produk_id'] == produk['produk_id'],
    );

    if (existingItemIndex != -1) {
      // Jika produk sudah ada, cukup tambahkan jumlahnya
      final existingItem = keranjang[existingItemIndex];
      final availableStock = produk['stok'] -
          existingItem['jumlah']; // Stok sisa setelah menambah jumlah
      if (availableStock >= jumlah) {
        setState(() {
          existingItem['jumlah'] += jumlah;
          existingItem['subtotal'] = existingItem['jumlah'] * produk['harga'];
          totalHarga += produk['harga'] * jumlah;
        });
      } else {
        ScaffoldMessenger.of(context).showSnackBar(const SnackBar(
          content: Text('Stok tidak mencukupi untuk menambah jumlah!'),
        ));
      }
    } else {
      // Jika produk belum ada di keranjang, tambahkan produk baru
      if (produk['stok'] >= jumlah) {
        final subtotal = produk['harga'] * jumlah;
        setState(() {
          keranjang.add({
            'produk_id': produk['produk_id'],
            'nama_produk': produk['nama_produk'],
            'jumlah': jumlah,
            'subtotal': subtotal,
          });
          totalHarga += subtotal;
        });
      } else {
        ScaffoldMessenger.of(context).showSnackBar(const SnackBar(
          content: Text('Stok tidak mencukupi!'),
        ));
      }
    }

    // Update stok produk setelah ditambahkan ke keranjang
    final updatedStock = produk['stok'] - jumlah;
    setState(() {
      produk['stok'] = updatedStock;
    });
  }

  Future<void> _simpanTransaksi() async {
    // Pastikan keranjang tidak kosong
    if (keranjang.isEmpty) {
      ScaffoldMessenger.of(context).showSnackBar(const SnackBar(
        content: Text('Keranjang tidak boleh kosong!'),
      ));
      return;
    }

    // Jika tidak ada pelanggan yang dipilih, gunakan pelanggan anonim
    Map<String, dynamic> pelanggan = selectedPelanggan ??
        {
          'pelanggan_id': 0, // ID pelanggan anonim
          'nama_pelanggan': 'User', // Nama default untuk pelanggan anonim
          'alamat': '-', // Alamat default
          'no_tlp': '-', // Nomor telepon default
        };

    try {
      // Menyisipkan ke tabel 'penjualan'
      final response = await supabase.from('penjualan').insert({
        'tgl_penjualan': DateTime.now().toIso8601String(),
        'total_harga': totalHarga,
        'pelanggan_id': pelanggan['id_pelanggan'], // ID pelanggan anonim
      }).select();

      if (response.isNotEmpty) {
        final penjualanId = response[0]['penjualan_id'];

        // Menyisipkan ke tabel 'detail_penjualan' untuk setiap item dalam keranjang
        for (final item in keranjang) {
          await supabase.from('detail_penjualan').insert({
            'penjualan_id': penjualanId,
            'produk_id': item['produk_id'],
            'jumlah_produk': item['jumlah'],
            'subtotal': item['subtotal'],
            'created_at': DateTime.now().toIso8601String(),
          });

          // Memperbarui stok di tabel 'produk'
          final produk = produkList.firstWhere(
            (p) => p['produk_id'] == item['produk_id'],
            orElse: () => {},
          );

          final stokBaru = produk['stok'] - item['jumlah'];
          if (stokBaru >= 0) {
            await supabase.from('produk').update({'stok': stokBaru}).eq(
              'produk_id',
              item['produk_id'],
            );
          }
        }
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(
            content: Text('Transaksi berhasil disimpan!'),
            duration: Duration(seconds: 1),
          ),
        );

        // Navigasi ke halaman Riwayat
        Navigator.push(
          context,
          MaterialPageRoute(builder: (context) => const Riwayat()),
        );

        // Reset data setelah transaksi berhasil
        setState(() {
          keranjang.clear();
          totalHarga = 0.0;
          selectedPelanggan = null; // Reset pilihan pelanggan
        });
      } else {
        ScaffoldMessenger.of(context).showSnackBar(const SnackBar(
          content: Text('Gagal menyimpan transaksi.'),
        ));
      }
    } catch (e) {
      ScaffoldMessenger.of(context).showSnackBar(SnackBar(
        content: Text('Terjadi kesalahan: $e'),
      ));
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      // appBar: AppBar(
      //   title: Text(
      //     'Pesanan',
      //     style: GoogleFonts.poppins(
      //       fontSize: 24,
      //       fontWeight: FontWeight.w600,
      //       color: const Color(0xFF000957),
      //     ),
      //   ),
      // ),
      body: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              'Pelanggan',
              style: GoogleFonts.poppins(
                fontSize: 16,
                fontWeight: FontWeight.bold,
                color: Colors.blue.shade800,
              ),
            ),
            const SizedBox(height: 8),
            DropdownButtonFormField<int>(
              decoration: InputDecoration(
                filled: true,
                fillColor: Colors.grey.shade200,
                labelText: 'Pilih Pelanggan',
                border: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(10),
                ),
              ),
              items: pelangganList.map((pelanggan) {
                return DropdownMenuItem<int>(
                  value: pelanggan['id_pelanggan'],
                  child: Text(pelanggan['nama_pelanggan']),
                );
              }).toList(),
              onChanged: (value) {
                setState(() {
                  selectedPelanggan = pelangganList.firstWhere(
                    (pelanggan) => pelanggan['id_pelanggan'] == value,
                    orElse: () =>
                        {}, // Jika tidak ditemukan, kembalikan map kosong
                  );
                });
              },
              value: selectedPelanggan != null
                  ? selectedPelanggan!['id_pelanggan']
                  : null,
            ),
            const SizedBox(height: 8),
            // Tombol untuk tambah pelanggan
            // TextButton.icon(
            //   onPressed: () async {
            //     // Arahkan ke halaman AddPelanggan dan tunggu hasilnya
            //     final result = await Navigator.push(
            //       context,
            //       MaterialPageRoute(builder: (context) => const AddPelanggan()),
            //     );

            //     // Jika berhasil menambah pelanggan, refresh data pelanggan
            //     if (result == true) {
            //       _fetchPelanggan();
            //     }
            //   },
            //   icon: const Icon(Icons.add, size: 16),
            //   label: const Text('Tambah Pelanggan'),
            // ),
            const SizedBox(height: 16),
            Text(
              'Produk',
              style: GoogleFonts.poppins(
                fontSize: 16,
                fontWeight: FontWeight.bold,
                color: Colors.blue.shade800,
              ),
            ),
            const SizedBox(height: 8),
            DropdownButtonFormField<Map<String, dynamic>>(
              decoration: InputDecoration(
                filled: true,
                fillColor: Colors.grey.shade200,
                labelText: 'Pilih Produk',
                border: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(10),
                ),
              ),
              items: produkList
                  .map((produk) => DropdownMenuItem(
                        value: produk,
                        child: Text(
                            '${produk['nama_produk']} (Stok: ${produk['stok']})'),
                      ))
                  .toList(),
              onChanged: (value) {
                if (value != null) {
                  _addToCart(value, 1);
                }
              },
            ),
            const SizedBox(height: 16),
            // Menampilkan Produk yang ada di Keranjang
            Expanded(
              child: ListView.builder(
                itemCount:
                    keranjang.length, // Jumlah item yang ada di keranjang
                itemBuilder: (context, index) {
                  final item = keranjang[index]; // Ambil item berdasarkan index
                  final produkId = item['produk_id']; // ID produk
                  final produk = produkList.firstWhere(
                    (p) => p['produk_id'] == produkId,
                    orElse: () =>
                        {'harga': 0}, // Jika tidak ditemukan, gunakan harga 0
                  );
                  final harga =
                      produk['harga'] ?? 0; // Menggunakan harga produk
                  final jumlah = item['jumlah'] ??
                      0; // Menggunakan jumlah default 0 jika null
                  final subtotal =
                      harga * jumlah; // Menghitung subtotal setiap item

                  // Update subtotal untuk setiap item
                  item['subtotal'] = subtotal;

                  return ListTile(
                    title: Text(item['nama_produk']), // Nama produk
                    subtitle: Text(
                      'Jumlah: $jumlah | Subtotal: Rp${subtotal.toStringAsFixed(0)}',
                      style: GoogleFonts.poppins(fontSize: 14),
                    ),
                    trailing: Row(
                      mainAxisSize: MainAxisSize.min,
                      children: [
                        // Tombol untuk mengurangi jumlah produk
                        IconButton(
                          icon: const Icon(Icons.remove, color: Colors.red),
                          onPressed: () {
                            setState(() {
                              if (item['jumlah'] > 1) {
                                item['jumlah']--;
                                item['subtotal'] =
                                    item['jumlah'] * harga; // Update subtotal
                                totalHarga -= harga; // Update totalHarga
                              } else {
                                totalHarga -=
                                    item['subtotal']; // Kurangi total harga
                                keranjang.removeAt(
                                    index); // Hapus item jika jumlah = 0
                              }
                            });
                          },
                        ),
                        // Menampilkan jumlah produk
                        Text(item['jumlah'].toString()),
                        // Tombol untuk menambah jumlah produk
                        IconButton(
                          icon: const Icon(Icons.add, color: Colors.green),
                          onPressed: () {
                            final stokProduk =
                                produk['stok'] ?? 0; // Cek stok produk
                            if (item['jumlah'] < stokProduk) {
                              setState(() {
                                item['jumlah']++;
                                item['subtotal'] =
                                    item['jumlah'] * harga; // Update subtotal
                                totalHarga += harga; // Update totalHarga
                              });
                            } else {
                              ScaffoldMessenger.of(context)
                                  .showSnackBar(const SnackBar(
                                content: Text('Stok tidak mencukupi!'),
                              ));
                            }
                          },
                        ),
                        // Tombol untuk menghapus produk dari keranjang
                        IconButton(
                          icon: const Icon(Icons.delete,
                              color: Color.fromARGB(255, 249, 0, 0)),
                          onPressed: () {
                            setState(() {
                              totalHarga -=
                                  item['subtotal']; // Kurangi total harga
                              keranjang
                                  .removeAt(index); // Hapus item dari keranjang
                            });
                          },
                        ),
                      ],
                    ),
                  );
                },
              ),
            ),
            // Bagian untuk menampilkan total harga
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Text(
                  'Total: Rp${totalHarga.toStringAsFixed(0)}', // Menampilkan total harga
                  style: GoogleFonts.poppins(
                    fontSize: 20,
                    fontWeight: FontWeight.bold,
                  ),
                ),
                ElevatedButton(
                  onPressed:
                      _simpanTransaksi, // Simpan transaksi dan lanjut ke checkout
                  style: ElevatedButton.styleFrom(
                    backgroundColor: const Color(0xFF074799),
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(8),
                    ),
                  ),
                  child: const Text(
                    'Simpan',
                    style: TextStyle(color: Colors.white),
                  ),
                ),
              ],
            )
          ],
        ),
      ),
      // bottomNavigationBar: BottomNavBar(),
    );
  }
}
