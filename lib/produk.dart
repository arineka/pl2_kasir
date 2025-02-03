import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:supabase_flutter/supabase_flutter.dart';
import 'package:ukk_coba/history.dart';
import 'package:ukk_coba/login.dart';
import 'pesanan.dart'; // Pastikan untuk mengimpor halaman lain jika diperlukan
import 'profile.dart'; // Pastikan untuk mengimpor halaman lain jika diperlukan
import 'bottomnavbar.dart';

class FlutterVizBottomNavigationBarModel {
  final IconData icon;
  final String label;

  FlutterVizBottomNavigationBarModel({
    required this.icon,
    required this.label,
  });
}

class Produk extends StatefulWidget {
  const Produk({super.key});

  @override
  _ProdukState createState() => _ProdukState();
}

class _ProdukState extends State<Produk> {
  int _selectedIndex = 0;
  final SupabaseClient supabase = Supabase.instance.client;
  List<Map<String, dynamic>> produk = [];
  List<Map<String, dynamic>> filteredProduk =
      []; // List untuk menyimpan produk yang difilter
  String searchQuery = ''; // Variabel untuk menyimpan query pencarian

  @override
  void initState() {
    super.initState();
    _fetchProduk();
  }

  Future<void> _fetchProduk() async {
    try {
      print('Fetching produk...');
      final response = await supabase
          .from('produk')
          .select('*')
          .order('produk_id', ascending: true);

      print('Response: $response');
      if (response != null) {
        setState(() {
          produk = List<Map<String, dynamic>>.from(response);
          filteredProduk = produk; // Awalnya semua produk ditampilkan
          produk.sort((a, b) => a['produk_id'].compareTo(b['produk_id']));
        });
      } else {
        _showSnackBar('Gagal memuat data produk.');
      }
    } catch (e) {
      print('Error fetching produk: $e');
      _showSnackBar('Terjadi kesalahan: $e');
    }
  }

  Future<void> _addProduct(String nama, double harga, int stok) async {
    try {
      final response = await supabase.from('produk').insert({
        'nama_produk': nama,
        'harga': harga,
        'stok': stok,
      }).select();

      if (response != null) {
        _showSnackBar('Produk berhasil ditambahkan!');
      } else {
        _showSnackBar('Gagal menambahkan produk.');
      }
    } catch (e) {
      _showSnackBar('Terjadi kesalahan: $e');
    }
  }

  // Fungsi untuk mengedit produk di database
  Future<void> _editProduk(int id, String nama, double harga, int stok) async {
    try {
      await supabase.from('produk').update({
        'nama_produk': nama,
        'harga': harga,
        'stok': stok,
      }).eq('produk_id', id);

      setState(() {
        final index = produk.indexWhere((p) => p['produk_id'] == id);
        if (index != -1) {
          produk[index] = {
            'produk_id': id,
            'nama_produk': nama,
            'harga': harga,
            'stok': stok,
          };
        }
      });
      _showSnackBar('Produk berhasil diperbarui!');
    } catch (e) {
      _showSnackBar('Terjadi kesalahan: $e');
    }
  }

  // Fungsi untuk menghapus produk dari database
  Future<void> _deleteProduk(int id) async {
    try {
      await supabase.from('detail_penjualan').delete().eq('produk_id', id);
      await supabase.from('produk').delete().eq('produk_id', id);

      setState(() {
        produk.removeWhere((p) => p['produk_id'] == id);
      });

      _showSnackBar('Produk berhasil dihapus!');
    } catch (e) {
      _showSnackBar('Terjadi kesalahan: $e');
    }
  }

  void _showSnackBar(String message) {
    //Fungsi untuk menampilkan SnackBar dengan pesan tertentu.
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text(message),
        duration: const Duration(seconds: 2),
      ),
    );
  }

  void _showAddProductDialog() {
    final _formKey =
        GlobalKey<FormState>(); // Tambahkan GlobalKey untuk validasi
    final TextEditingController namaController = TextEditingController();
    final TextEditingController hargaController = TextEditingController();
    final TextEditingController stokController = TextEditingController();

    showDialog(
      context: context,
      builder: (BuildContext context) {
        return AlertDialog(
          title: const Text('Tambah Produk'),
          content: Form(
            key: _formKey, // Gunakan form key
            child: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                TextFormField(
                  controller: namaController,
                  decoration: const InputDecoration(labelText: 'Nama Produk'),
                  validator: (value) {
                    if (value == null || value.trim().isEmpty) {
                      return 'Nama produk tidak boleh kosong';
                    }
                    return null;
                  },
                ),
                TextFormField(
                  controller: hargaController,
                  decoration: const InputDecoration(labelText: 'Harga'),
                  keyboardType: TextInputType.number,
                  validator: (value) {
                    if (value == null || value.trim().isEmpty) {
                      return 'Harga harus diisi';
                    } else if (double.tryParse(value) == null) {
                      return 'Harga harus berupa angka';
                    } else if (double.tryParse(value)! <= 0) {
                      return 'Harga harus lebih besar dari 0';
                    }
                    return null;
                  },
                ),
                TextFormField(
                  controller: stokController,
                  decoration: const InputDecoration(labelText: 'Stok'),
                  keyboardType: TextInputType.number,
                  validator: (value) {
                    if (value == null || value.trim().isEmpty) {
                      return 'Stok harus diisi';
                    } else if (double.tryParse(value) == null) {
                      return 'Stok harus berupa angka';
                    } else if (double.tryParse(value)! <= 0) {
                      return 'Stok harus lebih besar dari 0';
                    }
                    return null;
                  },
                ),
              ],
            ),
          ),
          actions: [
            TextButton(
              onPressed: () {
                Navigator.pop(context);
              },
              child: const Text('Batal'),
            ),
            TextButton(
              onPressed: () {
                if (_formKey.currentState!.validate()) {
                  final String nama = namaController.text.trim();
                  final double harga =
                      double.tryParse(hargaController.text.trim()) ?? 0.0;
                  final int stok =
                      int.tryParse(stokController.text.trim()) ?? 0;

                  _addProduct(nama, harga, stok).then((_) {
                    Navigator.pop(context);
                    _fetchProduk(); // Refresh data produk setelah menyimpan
                  });
                }
              },
              child: const Text('Simpan'),
            ),
          ],
        );
      },
    );
  }

  void _showEditDialog(Map<String, dynamic> product) {
    final TextEditingController namaController =
        TextEditingController(text: product['nama_produk']);
    final TextEditingController hargaController =
        TextEditingController(text: product['harga'].toString());
    final TextEditingController stokController =
        TextEditingController(text: product['stok'].toString());

    showDialog(
      context: context,
      builder: (context) {
        return AlertDialog(
          title: Text(
            'Edit Produk',
            style: GoogleFonts.poppins(
                fontWeight: FontWeight.bold,
                fontSize: 18,
                color: const Color(0xFF074799)),
          ),
          content: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              _buildTextField(namaController, 'Nama Produk'),
              const SizedBox(height: 10),
              _buildTextField(hargaController, 'Harga',
                  keyboardType: TextInputType.number),
              const SizedBox(height: 10),
              _buildTextField(stokController, 'Stok',
                  keyboardType: TextInputType.number),
            ],
          ),
          actions: [
            _buildDialogButton('Batal', () {
              Navigator.pop(context);
            }),
            _buildDialogButton('Simpan', () {
              final int id = product['produk_id'];
              final String nama = namaController.text.trim();
              final double harga =
                  double.tryParse(hargaController.text.trim()) ?? 0.0;
              final int stok = int.tryParse(stokController.text.trim()) ?? 0;

              if (nama.isNotEmpty && harga > 0 && stok >= 0) {
                Navigator.pop(context);
                _editProduk(id, nama, harga, stok)
                    .then((_) => _fetchProduk()); // Tambahkan di sini
              } else {
                _showSnackBar('Isi semua field dengan data yang valid!');
              }
            }),
          ],
        );
      },
    );
  }

  void _showDeleteConfirmationDialog(int id) {
    showDialog(
      context: context,
      builder: (context) {
        return AlertDialog(
          title: Text(
            'Konfirmasi Hapus Produk',
            style: GoogleFonts.poppins(
                fontWeight: FontWeight.bold,
                fontSize: 18,
                color: const Color(0xFF074799)),
          ),
          content: Text('Apakah Anda yakin ingin menghapus produk ini?',
              style: GoogleFonts.poppins(fontSize: 16)),
          actions: [
            _buildDialogButton('Batal', () {
              Navigator.pop(context);
            }),
            _buildDialogButton('Hapus', () {
              Navigator.pop(context);
              _deleteProduk(id);
            }),
          ],
        );
      },
    );
  }

  Widget _buildTextField(TextEditingController controller, String label,
      {TextInputType keyboardType = TextInputType.text}) {
    return TextField(
      controller: controller,
      keyboardType: keyboardType,
      decoration: InputDecoration(
        labelText: label,
        labelStyle: GoogleFonts.poppins(),
      ),
    );
  }

  Widget _buildDialogButton(String label, VoidCallback onPressed) {
    return TextButton(
      onPressed: onPressed,
      child: Text(label, style: GoogleFonts.poppins(color: Colors.black)),
    );
  }

  // Fungsi untuk filter produk berdasarkan pencarian
  void _filterProduk(String query) {
    setState(() {
      searchQuery = query;
      if (query.isEmpty) {
        filteredProduk =
            produk; // Jika pencarian kosong, tampilkan semua produk
      } else {
        filteredProduk = produk.where((product) {
          final namaProduk = product['nama_produk'].toString().toLowerCase();
          return namaProduk
              .contains(query.toLowerCase()); // Filter produk berdasarkan nama
        }).toList();
      }
    });
  }

  void _logout() {
    Navigator.pushReplacement(
      context,
      MaterialPageRoute(
        builder: (context) => const Login(),
      ),
    );
  }

  // Fungsi untuk menampilkan halaman produk
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFFF6F8FC),
      appBar: AppBar(
        elevation: 0,
        backgroundColor: Colors.transparent,
        automaticallyImplyLeading: false,
        title: Text(
          'Dashboard Produk',
          style: GoogleFonts.poppins(
            fontSize: 24,
            fontWeight: FontWeight.w600,
            color: const Color(0xFF000957),
          ),
        ),
        actions: [
          Padding(
            padding: const EdgeInsets.only(right: 16),
            child: Container(
              width: 180,
              height: 40,
              decoration: BoxDecoration(
                color: Colors.white,
                borderRadius: BorderRadius.circular(10),
                boxShadow: [
                  BoxShadow(
                    color: Colors.grey.withOpacity(0.2),
                    blurRadius: 6,
                    spreadRadius: 2,
                  ),
                ],
              ),
              child: TextField(
                onChanged: _filterProduk,
                style: GoogleFonts.poppins(fontSize: 14, color: Colors.black),
                decoration: InputDecoration(
                  hintText: 'Cari produk...',
                  hintStyle:
                      GoogleFonts.poppins(fontSize: 14, color: Colors.grey),
                  prefixIcon:
                      const Icon(Icons.search, color: Color(0xFF074799)),
                  border: InputBorder.none,
                  contentPadding: const EdgeInsets.symmetric(vertical: 8.0),
                ),
              ),
            ),
          ),
          IconButton(
            icon: const Icon(Icons.logout_rounded),
            color: const Color(0xFF074799),
            onPressed: _logout,
          ),
        ],
      ),
      body: ListView.builder(
        padding: const EdgeInsets.all(16),
        itemCount: filteredProduk
            .length, // Gunakan filteredProduk untuk daftar produk yang sudah difilter
        itemBuilder: (context, index) {
          final product = filteredProduk[index];
          return _buildProductCard(product);
        },
      ),
      bottomNavigationBar: BottomNavBar(),
      floatingActionButton: FloatingActionButton(
        onPressed: () {
          _showAddProductDialog(); // Panggil dialog untuk menambahkan produk
        },
        backgroundColor: const Color(0xFF074799),
        child: const Icon(Icons.add, color: Colors.white),
      ),
    );
  }

  // Membuat card produk
  Widget _buildProductCard(Map<String, dynamic> product) {
    return Card(
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(10),
      ),
      elevation: 5,
      margin: const EdgeInsets.only(bottom: 16),
      child: Padding(
        padding: const EdgeInsets.all(12.0),
        child: Row(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            const SizedBox(width: 16),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    '${product['nama_produk'] ?? 'N/A'}',
                    style: GoogleFonts.poppins(
                      fontWeight: FontWeight.bold,
                      fontSize: 16,
                      color: const Color.fromARGB(255, 65, 86, 112),
                    ),
                  ),
                  Text(
                    'Harga: Rp${product['harga'] ?? 'N/A'}',
                    style: GoogleFonts.poppins(
                      fontSize: 16,
                      color: const Color(0xFF074799),
                    ),
                  ),
                  Text(
                    'Stok: ${product['stok'] ?? 'N/A'}',
                    style: GoogleFonts.poppins(
                      fontSize: 16,
                      color: const Color(0xFF074799),
                    ),
                  ),
                ],
              ),
            ),
            IconButton(
              icon: const Icon(Icons.edit, color: Color(0xFF074799)),
              onPressed: () {
                _showEditDialog(product); // Buka dialog edit
              },
            ),
            IconButton(
              icon: const Icon(Icons.delete, color: Color(0xFF074799)),
              onPressed: () {
                _showDeleteConfirmationDialog(product['produk_id']);
              },
            ),
          ],
        ),
      ),
    );
  }

//   Future<bool> _isUserPetugas() async {
//     final user = supabase.auth.currentUser;
//     if (user != null) {
//       final response = await supabase
//           .from('petugas')
//           .select('userID')
//           .eq('userID', user.id)
//           .single();

//       if (response != null) {
//         return true; // Pengguna ditemukan di tabel petugas
//       }
//     }
//     return false; // Pengguna tidak ditemukan di tabel petugas
//   }

// FutureBuilder<bool> _buildBottomNavBar() {
//   return FutureBuilder<bool>(
//     future: _isUserPetugas(),  // Mengecek apakah user adalah petugas
//     builder: (context, snapshot) {
//       if (snapshot.connectionState == ConnectionState.waiting) {
//         return const Center(child: CircularProgressIndicator());
//       }

//       bool isPetugas = snapshot.data ?? false;
//       List<BottomNavigationBarItem> items = [
//         BottomNavigationBarItem(
//           icon: const Icon(Icons.store_mall_directory_outlined),
//           label: 'Produk',
//         ),
//         if (isPetugas) ...[  // Menampilkan Pesanan dan Riwayat hanya jika petugas
//           BottomNavigationBarItem(
//             icon: const Icon(Icons.shopping_bag_outlined),
//             label: 'Pesanan',
//           ),
//           BottomNavigationBarItem(
//             icon: const Icon(Icons.history_outlined),
//             label: 'Riwayat',
//           ),
//         ],
//         if (!isPetugas)  // Menampilkan Profil hanya jika bukan petugas
//           BottomNavigationBarItem(
//             icon: const Icon(Icons.person_outline),
//             label: 'Profil',
//           ),
//       ];

//       return BottomNavigationBar(
//         currentIndex: _selectedIndex,
//         onTap: (index) {
//           setState(() {
//             _selectedIndex = index;
//           });
//           switch (index) {
//             case 0: // Produk
//               Navigator.pushReplacement(
//                   context,
//                   MaterialPageRoute(builder: (context) => const Produk()),
//                 );
//               break;
//             case 1: // Pesanan (tampil hanya jika petugas)
//               if (isPetugas) {
//                 Navigator.pushReplacement(
//                   context,
//                   MaterialPageRoute(builder: (context) => const Pesanan()),
//                 );
//               }
//               break;
//             case 2: // Riwayat (tampil hanya jika petugas)
//               if (isPetugas) {
//                 Navigator.pushReplacement(
//                   context,
//                   MaterialPageRoute(builder: (context) => const Riwayat()),
//                 );
//               }
//               break;
//             case 3: // Profil (tampil hanya jika bukan petugas)
//               if (!isPetugas) {
//                 Navigator.pushReplacement(
//                   context,
//                   MaterialPageRoute(builder: (context) => const ProfilPage()),
//                 );
//               }
//               break;
//           }
//         },
//         selectedItemColor: const Color(0xFF074799),
//         unselectedItemColor: Colors.grey,
//         items: items,
//       );
//     },
//   );
}
