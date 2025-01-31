import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:supabase_flutter/supabase_flutter.dart';
import 'add_produk.dart'; // Pastikan untuk mengimpor halaman lain jika diperlukan
import 'pesanan.dart'; // Pastikan untuk mengimpor halaman lain jika diperlukan
import 'profile.dart'; // Pastikan untuk mengimpor halaman lain jika diperlukan

class Produk extends StatefulWidget {
  const Produk({super.key});

  @override
  State<Produk> createState() => _ProdukState();
}

class _ProdukState extends State<Produk> {
  int _selectedIndex = 0;
  final SupabaseClient supabase = Supabase.instance.client;
  List<Map<String, dynamic>> produk = [];

  @override
  void initState() {
    super.initState();
    _fetchProduk();
  }

  Future<void> _fetchProduk() async {
    try {
      final response = await supabase
          .from('produk')
          .select('*')
          .order('produk_id', ascending: true);

      print('Fetch Produk Response: $response'); // Debugging

      if (response != null) {
        setState(() {
          produk = List<Map<String, dynamic>>.from(response);
          // Pastikan data produk tetap terurut berdasarkan ID
          produk.sort((a, b) => a['produk_id'].compareTo(b['produk_id']));
        });
      } else {
        _showSnackBar('Gagal memuat data produk.');
      }
    } catch (e) {
      _showSnackBar('Terjadi kesalahan: $e');
    }
  }

  Future<void> _editProduk(int id, String nama, double harga, int stok) async {
    try {
      final response = await supabase.from('produk').update({
        'nama_produk': nama,
        'harga': harga,
        'stok': stok,
      }).eq('produk_id', id);

      print('Edit Produk Response: $response'); // Debugging

      if (response == null ) {
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
      } else {
        _showSnackBar('Gagal memperbarui produk.');
      }
    } catch (e) {
      _showSnackBar('Terjadi kesalahan: $e');
    }
  }

  Future<void> _deleteProduk(int id) async {
    try {
      final response =
          await supabase.from('produk').delete().eq('produk_id', id);

      print('Delete Produk Response: $response'); // Debugging

      if (response == null ) {
        setState(() {
          produk.removeWhere((p) => p['produk_id'] == id);
        });
        _showSnackBar('Produk berhasil dihapus!');
      } else {
        _showSnackBar('Gagal menghapus produk.');
      }
    } catch (e) {
      _showSnackBar('Terjadi kesalahan: $e');
    }
  }

  void _showSnackBar(String message) {
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text(message),
        duration: const Duration(seconds: 2),
      ),
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
            _buildDialogButton('Hapus', () {
              Navigator.pop(context);
              _deleteProduk(product['produk_id'])
                  .then((_) => _fetchProduk()); // Tambahkan di sini
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
            color: const Color(0xFF074799),
          ),
        ),
        actions: [
          IconButton(
            icon: const Icon(Icons.notifications_outlined,
                color: Color(0xFF074799)),
            onPressed: () {
              // Aksi notifikasi
            },
          ),
        ],
      ),
      body: ListView.builder(
        padding: const EdgeInsets.all(16),
        itemCount: produk.length,
        itemBuilder: (context, index) {
          final product = produk[index];
          return _buildProductCard(product);
        },
      ),
      bottomNavigationBar: _buildBottomNavBar(),
      floatingActionButton: FloatingActionButton(
        onPressed: () async {
          // Navigasi ke halaman AddProduk
          await Navigator.push(
            context,
            MaterialPageRoute(builder: (context) => const AddProduk()),
          );

          // Panggil ulang fetchProduk setelah kembali
          _fetchProduk();
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
                    'Nama: ${product['nama_produk'] ?? 'N/A'}',
                    style: GoogleFonts.poppins(
                      fontWeight: FontWeight.bold,
                      fontSize: 16,
                      color: const Color(0xFF074799),
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
          ],
        ),
      ),
    );
  }

  // Fungsi bottom navigation bar
  BottomNavigationBar _buildBottomNavBar() {
    return BottomNavigationBar(
      currentIndex: _selectedIndex,
      onTap: (index) {
        setState(() {
          _selectedIndex = index;
        });
        switch (index) {
          case 0: // Produk
            // Tetap di halaman ini
            break;
          case 1: // Pesanan
            Navigator.pushReplacement(
              context,
              MaterialPageRoute(builder: (context) => const Pesanan()),
            );
            break;
          case 2: // Profil
            Navigator.pushReplacement(
              context,
              MaterialPageRoute(builder: (context) => const ProfilPage()),
            );
            break;
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
          icon: Icon(Icons.person_outline),
          label: 'Profil',
        ),
      ],
    );
  }
}