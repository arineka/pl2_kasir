import 'package:flutter/material.dart'; // Library Flutter.
import 'package:supabase_flutter/supabase_flutter.dart'; // Library Supabase.
import 'package:ukk_coba/login.dart';
import 'package:ukk_coba/produk.dart';
import 'package:ukk_coba/profile.dart'; // Halaman produk.

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
    return const MaterialApp(
      debugShowCheckedModeBanner: false, // Menyembunyikan banner debug.
      title: 'Flutter Demo', // Judul aplikasi.
      home: Produk(), // Halaman awal aplikasi.
    );
  }
}
