import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:supabase_flutter/supabase_flutter.dart';
import 'produk.dart';
import 'pesanan.dart';
import 'history.dart';
import 'profile.dart';
import 'AkunPage.dart';
import 'login.dart'; // Jika diperlukan

// Fungsi utama aplikasi.
Future<void> main() async {
  WidgetsFlutterBinding.ensureInitialized(); // Inisialisasi Flutter.

  // Inisialisasi Supabase.
  await Supabase.initialize(
    url: 'https://rboyfzrwbznmltknjjtv.supabase.co',
    anonKey:
        'eyJhbGciOiJIUzI1NiIsInR5cCI6IkpXVCJ9.eyJpc3MiOiJzdXBhYmFzZSIsInJlZiI6InJib3lmenJ3YnpubWx0a25qanR2Iiwicm9sZSI6ImFub24iLCJpYXQiOjE3MzYxMjk3MzIsImV4cCI6MjA1MTcwNTczMn0.GV01DAMYB6txz7dK-q2ERwRu5jeHfnzRrBaL3qvrAH4',
  );

  runApp(const MyApp()); // Menjalankan aplikasi.
}

// Kelas utama aplikasi.
class MyApp extends StatelessWidget {
  const MyApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'Aplikasi Kasir',
      theme: ThemeData(
        textTheme: GoogleFonts.poppinsTextTheme(
            Theme.of(context).textTheme), // Menetapkan font secara global
        colorScheme: ColorScheme.fromSeed(seedColor: Colors.deepPurple),
        useMaterial3: false,
      ),
      debugShowCheckedModeBanner: false,
      home: const MainPage(), // Halaman utama langsung
    );
  }
}

class MainPage extends StatefulWidget {
  const MainPage({super.key});

  @override
  _MainPageState createState() => _MainPageState();
}

class _MainPageState extends State<MainPage> {
  int _currentIndex = 0;
  String? role;

  @override
  void initState() {
    super.initState();
    _loadRole();
  }

  Future<void> _loadRole() async {
    final prefs = await SharedPreferences.getInstance();
    setState(() {
      role = prefs.getString('role');
    });
  }

  final List<Widget> _adminPages = [
    const Produk(),
    const ProfilPage(),
    const AkunPage(),
  ];

  final List<Widget> _petugasPages = [
    const Produk(),
    const Pesanan(),
    const Riwayat(),
  ];

  void _onTap(int index) {
    setState(() {
      _currentIndex = index;
    });
  }

  Future<void> _logout() async {
    await Supabase.instance.client.auth.signOut();
    final prefs = await SharedPreferences.getInstance();
    await prefs.clear();

    // Pindahkan user ke halaman login setelah logout
    Navigator.of(context).pushReplacement(
      MaterialPageRoute(
        builder: (context) => const Login(),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    // Pastikan role sudah dimuat dengan benar
    if (role == null) {
      return const Login(); // Jika role belum ada, tampilkan halaman login
    }

    final pages = role == 'admin' ? _adminPages : _petugasPages;
    final titles = role == 'admin'
        ? ['Produk - Kasir Admin', 'Pelanggan', 'Regristasi Akun Petugas']
        : ['Produk - Kasir Petugas', 'Penjualan', 'Riwayat Pembelian'];

    return Scaffold(
      appBar: AppBar(
        title: Text(titles[_currentIndex],
            style: GoogleFonts.poppins(
                fontSize: 20,
                fontWeight: FontWeight.bold,
                color: Colors.blue)), // Menampilkan judul halaman sesuai index
        actions: [
          IconButton(
            icon: const Icon(Icons.logout, color: Colors.red),
            onPressed: _logout,
          ),
        ],
        backgroundColor: Colors.transparent,
        elevation: 0,
      ),
      body: IndexedStack(
        index: _currentIndex,
        children: pages,
      ),
      bottomNavigationBar: BottomNavigationBar(
        currentIndex: _currentIndex,
        selectedItemColor: Colors.blue,
        unselectedItemColor: Colors.grey,
        onTap: (index) {
          setState(() {
            _currentIndex = index;
          });
        },
        items: role == 'admin'
            ? const [
                BottomNavigationBarItem(
                  icon: Icon(Icons.shopping_bag_outlined),
                  label: 'Produk',
                ),
                BottomNavigationBarItem(
                  icon: Icon(Icons.person),
                  label: 'Pelanggan',
                ),
                BottomNavigationBarItem(
                  icon: Icon(Icons.person_add_alt_1_outlined),
                  label: 'Regristasi',
                ),
              ]
            : const [
                BottomNavigationBarItem(
                  icon: Icon(Icons.shopping_bag_outlined),
                  label: 'Produk',
                ),
                BottomNavigationBarItem(
                  icon: Icon(Icons.receipt_long),
                  label: 'Penjualan',
                ),
                BottomNavigationBarItem(
                  icon: Icon(Icons.history_outlined),
                  label: 'Riwayat',
                ),
              ],
        selectedLabelStyle:
            GoogleFonts.poppins(fontSize: 14, fontWeight: FontWeight.bold),
        unselectedLabelStyle: GoogleFonts.poppins(fontSize: 12),
      ),
    );
  }
}
