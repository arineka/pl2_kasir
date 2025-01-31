import 'package:flutter/material.dart';
import 'package:ukk_coba/login.dart';
import 'package:ukk_coba/pesanan.dart';
import 'package:ukk_coba/produk.dart';
// import 'package:ukk_coba/registrasi_admin.dart'; // Pastikan halaman ini ada
import 'package:google_fonts/google_fonts.dart';

class ProfilPage extends StatefulWidget {
  const ProfilPage({super.key});

  @override
  State<ProfilPage> createState() => _ProfilPageState();
}

class _ProfilPageState extends State<ProfilPage> {
  int _selectedIndex = 2; // Profil adalah index ke-2

  void _onItemTapped(int index) {
    if (index == _selectedIndex) return;

    if (index == 0) {
      // Navigasi ke halaman Dashboard (Beranda/Produk)
      Navigator.pushReplacement(
        context,
        MaterialPageRoute(builder: (context) => const Produk()),
      );
    } else if (index == 1) {
      // Navigasi ke halaman produk
      Navigator.pushReplacement(
        context,
        MaterialPageRoute(
            builder: (context) =>
                const Pesanan()), // Ganti jika ada halaman produk
      );
    } else if (index == 2) {
      // Tetap di halaman Profil
      return;
    }
  }

  void _logout() {
    // Tambahkan logika logout di sini, seperti menghapus token atau sesi pengguna
    Navigator.pushReplacement(
      context,
      MaterialPageRoute(
        builder: (context) => const Login(), // Kembali ke halaman utama setelah logout
      ),
    );
  }

  // void _navigateToRegistrasiAdmin() {
  //   Navigator.push(
  //     context,
  //     MaterialPageRoute(
  //       builder: (context) => const RegistrasiAdmin(),
  //     ),
  //   );
  // }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFFF6F8FC),
      appBar: AppBar(
        automaticallyImplyLeading:
            false, // Tidak menampilkan ikon panah kembali
        title: Text(
          'Profil',
          style: GoogleFonts.poppins(
            fontSize: 24,
            fontWeight: FontWeight.w600,
            color: const Color(0xFF074799),
          ),
        ),
        actions: [
          IconButton(
            icon: const Icon(Icons.logout_rounded),
            color: const Color(0xFF074799),
            onPressed: _logout, // Fungsi logout
          ),
        ],
      ),
      body: Padding(
        padding: const EdgeInsets.all(20.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            ListTile(
              leading: const Icon(Icons.admin_panel_settings_outlined, color: Color(0xFF074799),),
              title: Text(
                'Registrasi Admin',
                style: GoogleFonts.poppins(
                  fontSize: 16,
                  fontWeight: FontWeight.w500,
                  color: const Color(0xFF074799),
                ),
              ),
              // onTap: _navigateToRegistrasiAdmin, // Navigasi ke halaman registrasi admin
            ),
           const Divider(),
            // Tambahkan widget lainnya sesuai kebutuhan
          ],
        ),
      ),
      bottomNavigationBar:
          _buildBottomNavBar(), // Menambahkan BottomNavigationBar
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
