import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart'; // Untuk menggunakan font khusus dari Google Fonts.
import 'package:supabase_flutter/supabase_flutter.dart'; // Library Supabase untuk autentikasi.
import 'package:ukk_coba/produk.dart'; // Halaman yang akan dituju setelah login berhasil.

class Login extends StatefulWidget {
  const Login({super.key});

  @override
  State<Login> createState() => _LoginState();
}

class _LoginState extends State<Login> {
  // Controller untuk mengelola input email dan password
  final TextEditingController _emailController = TextEditingController();
  final TextEditingController _passwordController = TextEditingController();

  bool _isLoading = false; // Status untuk menunjukkan loading ketika login.
  bool _isPasswordVisible =
      false; // Status untuk mengontrol visibilitas password.

  // Fungsi untuk menangani proses login
  Future<void> _login() async {
    setState(() {
      _isLoading =
          true; // Tampilkan indikator loading saat proses login berjalan.
    });

    // Mengambil teks dari input email dan password.
    final email = _emailController.text.trim();
    final password = _passwordController.text;

    // Validasi awal, pastikan input tidak kosong.
    if (email.isEmpty || password.isEmpty) {
      _showSnackBar('Email dan Password wajib diisi!');
      setState(() {
        _isLoading = false; // Hentikan loading jika input tidak valid.
      });
      return;
    }

    try {
      // Proses autentikasi menggunakan Supabase.
      final response = await Supabase.instance.client.auth.signInWithPassword(
        email: email,
        password: password,
      );

      if (response.session != null) {
        // Jika login berhasil, tampilkan pesan sukses.
        _showSnackBar('Login berhasil!');
        // Arahkan pengguna ke halaman Produk.
        Navigator.of(context).pushReplacement(
          MaterialPageRoute(builder: (context) => Produk()),
        );
      } else {
        // Jika gagal, tampilkan pesan kesalahan.
        _showSnackBar('Login gagal. Periksa email dan password Anda!');
      }
    } catch (error) {
      // Jika ada error dalam proses login, tampilkan pesan error.
      _showSnackBar('Error: ${error.toString()}');
    } finally {
      // Hentikan indikator loading setelah proses selesai.
      setState(() {
        _isLoading = false;
      });
    }
  }

  // Fungsi untuk menampilkan SnackBar dengan pesan tertentu.
  void _showSnackBar(String message) {
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(content: Text(message)),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.white, // Warna latar belakang layar.
      body: SafeArea(
        child: Padding(
          padding: const EdgeInsets.all(24.0), // Jarak konten dari tepi layar.
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              const SizedBox(height: 50),
              // Teks judul halaman login.
              Text(
                "Selamat Datang",
                style: GoogleFonts.poppins(
                  fontSize: 28,
                  fontWeight: FontWeight.bold,
                  color: const Color(0xFF074799),
                ),
              ),
              const SizedBox(height: 5),
              // Penjelasan singkat tentang halaman login.
              RichText(
                //agar teks bisa berwarna
                text: TextSpan(
                  children: <InlineSpan>[
                    TextSpan(
                      text: 'Halaman Login ',
                      style: GoogleFonts.poppins(
                        fontSize: 14,
                        fontWeight: FontWeight.w400,
                        color: Colors.grey,
                      ),
                    ),
                    TextSpan(
                      text: 'Kasir',
                      style: GoogleFonts.poppins(
                        fontSize: 14,
                        fontWeight: FontWeight.bold,
                        color: Colors.black,
                      ),
                    ),
                  ],
                ),
              ),
              const SizedBox(height: 50),
              // Label untuk input username.
              Text(
                "Email",
                style: GoogleFonts.poppins(
                  fontSize: 15,
                  fontWeight: FontWeight.w500,
                  color: const Color(0xFF074799),
                ),
              ),
              // Input field untuk username.
              TextField(
                controller:
                    _emailController, // Menggunakan controller untuk input email.
                decoration: InputDecoration(
                  prefixIcon: const Icon(
                    Icons.person,
                    color: Color(0xFF074799),
                  ), // Ikon di sebelah kiri input.
                  hintText: "masukkan email", // Placeholder untuk input.
                  hintStyle: GoogleFonts.poppins(
                    fontSize: 14,
                    fontWeight: FontWeight.w400,
                    color: Colors.grey,
                  ),
                  border: const UnderlineInputBorder(
                    //garis dibawah input username
                    borderSide: BorderSide(color: Colors.grey),
                  ),
                  contentPadding: const EdgeInsets.symmetric(
                    horizontal: 16,
                    vertical: 12,
                  ),
                ),
              ),
              const SizedBox(height: 20),
              // Label untuk input password.
              Text(
                "Password",
                style: GoogleFonts.poppins(
                  fontSize: 15,
                  fontWeight: FontWeight.w500,
                  color: const Color(0xFF074799),
                ),
              ),
              // Input field untuk password.
              TextField(
                controller:
                    _passwordController, // Menggunakan controller untuk input password.
                obscureText:
                    !_isPasswordVisible, // Mengontrol visibilitas teks password.
                decoration: InputDecoration(
                  prefixIcon: const Icon(
                    Icons.lock,
                    color: Color(0xFF074799),
                  ), // Ikon di sebelah kiri input.
                  suffixIcon: IconButton(
                    icon: Icon(
                      _isPasswordVisible
                          ? Icons.visibility
                          : Icons
                              .visibility_off, // Ikon mata untuk visibilitas password.
                      color: const Color(0xFF074799),
                    ),
                    onPressed: () {
                      setState(() {
                        _isPasswordVisible =
                            !_isPasswordVisible; // Toggle visibilitas password.
                      });
                    },
                  ),
                  hintText: "masukkan password", // Placeholder untuk input.
                  hintStyle: GoogleFonts.poppins(
                    fontSize: 14,
                    fontWeight: FontWeight.w400,
                    color: Colors.grey,
                  ),
                  border: const UnderlineInputBorder(
                    //garis dibawah input password
                    borderSide: BorderSide(color: Colors.grey),
                  ),
                  contentPadding: const EdgeInsets.symmetric(
                    horizontal: 16,
                    vertical: 12,
                  ),
                ),
              ),
              const SizedBox(height: 70),
              // Tombol login.
              SizedBox(
                width: double.infinity, // Membuat tombol memenuhi lebar layar.
                child: ElevatedButton(
                  onPressed: _isLoading
                      ? null
                      : () =>
                          _login(), // Jalankan fungsi login jika tidak loading.
                  style: ElevatedButton.styleFrom(
                    backgroundColor: const Color(0xFF074799),
                    padding: const EdgeInsets.symmetric(vertical: 20),
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(
                          28), // Membuat tombol melengkung.
                    ),
                  ),
                  child: _isLoading
                      ? CircularProgressIndicator(
                          color: Colors.white) // Indikator loading.
                      : Text(
                          "Login",
                          style: GoogleFonts.poppins(
                            fontSize: 24,
                            fontWeight: FontWeight.w500,
                            color: Colors.white,
                          ),
                        ),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  @override
  void dispose() {
    // Membersihkan controller untuk menghindari kebocoran memori.
    _emailController.dispose();
    _passwordController.dispose();
    super.dispose();
  }
}
