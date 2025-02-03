import 'package:flutter/material.dart';
import 'package:supabase_flutter/supabase_flutter.dart';

import 'produk.dart';
import 'pesanan.dart';
import 'history.dart';
import 'profile.dart';

class BottomNavBar extends StatefulWidget {
  const BottomNavBar({super.key});

  @override
  _BottomNavBarState createState() => _BottomNavBarState();
}

class _BottomNavBarState extends State<BottomNavBar> {
  int _selectedIndex = 0;

  Future<bool> _isUserPetugas() async {
    final user = Supabase.instance.client.auth.currentUser;
    if (user != null) {
      final response = await Supabase.instance.client
          .from('petugas')
          .select('userID')
          .eq('userID', user.id)
          .single();
          
      if (response != null) {
        return true;  // Pengguna ditemukan di tabel petugas
      }
    }
    return false;  // Pengguna tidak ditemukan di tabel petugas
  }

  @override
  Widget build(BuildContext context) {
    return FutureBuilder<bool>(  // Mengecek apakah user adalah petugas
      future: _isUserPetugas(),
      builder: (context, snapshot) {
        if (snapshot.connectionState == ConnectionState.waiting) {
          return const Center(child: CircularProgressIndicator());
        }

        bool isPetugas = snapshot.data ?? false;

        // Menentukan item yang akan ditampilkan berdasarkan status pengguna
        List<BottomNavigationBarItem> items = [
          const BottomNavigationBarItem(
            icon: Icon(Icons.store_mall_directory_outlined),
            label: 'Produk',
          ),
          if (isPetugas) ...[  // Menampilkan Pesanan dan Riwayat hanya jika petugas
            const BottomNavigationBarItem(
              icon: Icon(Icons.shopping_bag_outlined),
              label: 'Pesanan',
            ),
            const BottomNavigationBarItem(
              icon: Icon(Icons.history_outlined),
              label: 'Riwayat',
            ),
          ],
          if (!isPetugas)  // Menampilkan Profil hanya jika bukan petugas
            const BottomNavigationBarItem(
              icon: Icon(Icons.person_outline),
              label: 'Profil',
            ),
        ];

        return BottomNavigationBar(
          currentIndex: _selectedIndex,
          onTap: (index) {
            setState(() {
              _selectedIndex = index; // Mengupdate currentIndex untuk highlight
            });

            // Arahkan ke halaman yang sesuai berdasarkan pilihan menu
            switch (index) {
              case 0: // Produk
                if (_selectedIndex != 0) {
                  Navigator.pushReplacement(
                    context,
                    MaterialPageRoute(builder: (context) => const Produk()),
                  );
                }
                break;
              case 1: // Pesanan (tampil hanya jika petugas)
                if (isPetugas && _selectedIndex != 1) {
                  Navigator.pushReplacement(
                    context,
                    MaterialPageRoute(builder: (context) => const Pesanan()),
                  );
                }
                break;
              case 2: // Riwayat (tampil hanya jika petugas)
                if (isPetugas && _selectedIndex != 2) {
                  Navigator.pushReplacement(
                    context,
                    MaterialPageRoute(builder: (context) => const Riwayat()),
                  );
                }
                break;
              case 3: // Profil (tampil hanya jika bukan petugas)
                if (!isPetugas && _selectedIndex != 3) {
                  Navigator.pushReplacement(
                    context,
                    MaterialPageRoute(builder: (context) => const ProfilPage()),
                  );
                }
                break;
            }
          },
          selectedItemColor: const Color(0xFF074799),
          unselectedItemColor: Colors.grey,
          items: items,
        );
      },
    );
  }
}
