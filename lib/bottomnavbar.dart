// import 'package:flutter/material.dart';
// import 'produk.dart';
// import 'pesanan.dart';
// import 'history.dart';
// import 'profile.dart';
// import 'AkunPage.dart'; // Tambahkan import untuk halaman Akun

// class BottomNavBar extends StatefulWidget {
//   const BottomNavBar({super.key});

//   @override
//   _BottomNavBarState createState() => _BottomNavBarState();
// }

// class _BottomNavBarState extends State<BottomNavBar> {
//   int _selectedIndex = 0;

//   @override
//   Widget build(BuildContext context) {
//     // Daftar item untuk BottomNavigationBar yang selalu ada
//     List<BottomNavigationBarItem> items = [
//       const BottomNavigationBarItem(
//         icon: Icon(Icons.store_mall_directory_outlined),
//         label: 'Produk',
//       ),
//       const BottomNavigationBarItem(
//         icon: Icon(Icons.shopping_bag_outlined),
//         label: 'Pesanan',
//       ),
//       const BottomNavigationBarItem(
//         icon: Icon(Icons.history_outlined),
//         label: 'Riwayat',
//       ),
//       const BottomNavigationBarItem(
//         icon: Icon(Icons.person_outline),
//         label: 'Profil',
//       ),
//       const BottomNavigationBarItem(
//         icon: Icon(Icons.account_circle_outlined), // Ikon untuk Akun
//         label: 'Akun', // Label untuk Akun
//       ),
//     ];

//     return BottomNavigationBar(
//       currentIndex: _selectedIndex,
//       onTap: (index) {
//         setState(() {
//           _selectedIndex = index; // Mengupdate currentIndex untuk highlight
//         });

//         // Arahkan ke halaman yang sesuai berdasarkan pilihan menu
//         switch (index) {
//           case 0: // Produk
//             Navigator.pushReplacement(
//               context,
//               MaterialPageRoute(builder: (context) => const Produk()),
//             );
//             break;
//           case 1: // Pesanan
//             Navigator.pushReplacement(
//               context,
//               MaterialPageRoute(builder: (context) => const Pesanan()),
//             );
//             break;
//           case 2: // Riwayat
//             Navigator.pushReplacement(
//               context,
//               MaterialPageRoute(builder: (context) => const Riwayat()),
//             );
//             break;
//           case 3: // Profil
//             Navigator.pushReplacement(
//               context,
//               MaterialPageRoute(builder: (context) => const ProfilPage()),
//             );
//             break;
//           case 4: // Akun
//             Navigator.pushReplacement(
//               context,
//               MaterialPageRoute(builder: (context) => const AkunPage()), // Pastikan AkunPage sudah dibuat
//             );
//             break;
//         }
//       },
//       selectedItemColor: const Color(0xFF074799),
//       unselectedItemColor: Colors.grey,
//       items: items,
//     );
//   }
// }
