import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:supabase_flutter/supabase_flutter.dart';
import 'produk.dart'; // Pastikan Anda telah mengimpor halaman Produk
import 'profile.dart'; // Pastikan Anda telah mengimpor halaman Profil

class Pesanan extends StatefulWidget {
  const Pesanan({super.key});

  @override
  State<Pesanan> createState() => _PesananState();
}

class _PesananState extends State<Pesanan> {
  final SupabaseClient supabase = Supabase.instance.client;
  List<Map<String, dynamic>> pesanan = [];
  int _selectedIndex = 1; // Pesanan sebagai tab aktif

  @override
  void initState() {
    super.initState();
    // Jika ada data pesanan yang perlu dimuat, tambahkan logika di sini.
  }

  void _onItemTapped(int index) {
    setState(() {
      _selectedIndex = index;
    });

    // Navigasi berdasarkan tab yang dipilih
    switch (index) {
      case 0: // Produk
        Navigator.pushReplacement(
          context,
          MaterialPageRoute(builder: (context) => const Produk()),
        );
        break;
      case 1: // Pesanan
        // Tetap di halaman ini
        break;
      case 2: // Profil
        Navigator.pushReplacement(
          context,
          MaterialPageRoute(builder: (context) => const ProfilPage()),
        );
        break;
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFFF6F8FC),
      appBar: AppBar(
        elevation: 0,
        backgroundColor: Colors.transparent,
        automaticallyImplyLeading: false,
        title: Text(
          'Daftar Pesanan',
          style: GoogleFonts.poppins(
            fontSize: 24,
            fontWeight: FontWeight.w600,
            color: const Color(0xFF074799),
          ),
        ),
      ),
      body: pesanan.isEmpty
          ? Center(
              child: Text(
                'Belum ada pesanan.',
                style: GoogleFonts.poppins(
                  fontSize: 18,
                  color: Colors.grey,
                ),
              ),
            )
          : ListView.builder(
              padding: const EdgeInsets.all(16),
              itemCount: pesanan.length,
              itemBuilder: (context, index) {
                final order = pesanan[index];
                return _buildPesananCard(order);
              },
            ),
      bottomNavigationBar: _buildBottomNavBar(),
    );
  }

  Widget _buildPesananCard(Map<String, dynamic> order) {
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
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    'Nama: ${order['nama_produk'] ?? 'N/A'}',
                    style: GoogleFonts.poppins(
                      fontWeight: FontWeight.bold,
                      fontSize: 16,
                      color: const Color(0xFF074799),
                    ),
                  ),
                  Text(
                    'Harga: Rp${order['harga'] ?? 'N/A'}',
                    style: GoogleFonts.poppins(
                      fontSize: 16,
                      color: const Color(0xFF074799),
                    ),
                  ),
                  Text(
                    'Jumlah: ${order['stok'] ?? 'N/A'}',
                    style: GoogleFonts.poppins(
                      fontSize: 16,
                      color: const Color(0xFF074799),
                    ),
                  ),
                ],
              ),
            ),
            IconButton(
              icon: const Icon(Icons.delete, color: Colors.red),
              onPressed: () {
                _showDeleteConfirmationDialog(order['id']);
              },
            ),
          ],
        ),
      ),
    );
  }

  void _showDeleteConfirmationDialog(int id) {
    showDialog(
      context: context,
      builder: (context) {
        return AlertDialog(
          title: Text(
            'Konfirmasi Hapus Pesanan',
            style: GoogleFonts.poppins(
              fontWeight: FontWeight.bold,
              fontSize: 18,
              color: const Color(0xFF074799),
            ),
          ),
          content: Text(
            'Apakah Anda yakin ingin menghapus pesanan ini?',
            style: GoogleFonts.poppins(fontSize: 16),
          ),
          actions: [
            TextButton(
              onPressed: () {
                Navigator.pop(context);
              },
              child: Text(
                'Batal',
                style: GoogleFonts.poppins(color: Colors.black),
              ),
            ),
            TextButton(
              onPressed: () {
                Navigator.pop(context);
              },
              child: Text(
                'Hapus',
                style: GoogleFonts.poppins(color: Colors.red),
              ),
            ),
          ],
        );
      },
    );
  }

  Widget _buildBottomNavBar() {
    return BottomNavigationBar(
      currentIndex: _selectedIndex,
      onTap: _onItemTapped,
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
