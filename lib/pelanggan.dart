import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:supabase_flutter/supabase_flutter.dart';

class AddPelanggan extends StatefulWidget {
  const AddPelanggan({Key? key}) : super(key: key);

  @override
  State<AddPelanggan> createState() => _AddPelangganState();
}

class _AddPelangganState extends State<AddPelanggan> {
  final SupabaseClient supabase = Supabase.instance.client;

  // Text editing controllers untuk input field
  final TextEditingController _idController = TextEditingController();
  final TextEditingController _namaController = TextEditingController();
  final TextEditingController _alamatController = TextEditingController();
  final TextEditingController _nomorTeleponController = TextEditingController();

  List<Map<String, dynamic>> pelangganList = []; // Tambahkan pelangganList
  bool _isLoading = false;

  void _showSnackBar(String message) {
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text(message),
        duration: const Duration(seconds: 2),
      ),
    );
  }

  // Fungsi untuk menambahkan pelanggan ke Supabase
  Future<void> _addPelanggan() async {
    final String id = _idController.text.trim();
    final String nama = _namaController.text.trim();
    final String alamat = _alamatController.text.trim();
    final String nomorTelepon = _nomorTeleponController.text.trim();

    if (id.isEmpty || nama.isEmpty || alamat.isEmpty || nomorTelepon.isEmpty) {
      _showSnackBar('Semua field harus diisi.');
      return;
    }

    final int? idParsed = int.tryParse(id);
    if (idParsed == null) {
      _showSnackBar('ID harus berupa angka.');
      return;
    }

    setState(() {
      _isLoading = true;
    });

    try {
      final List<dynamic> existing = await supabase
          .from('pelanggan')
          .select()
          .eq('id_pelanggan', idParsed);

      if (existing.isNotEmpty) {
        _showSnackBar('ID pelanggan sudah ada. Gunakan ID lain.');
        return;
      }

      final List<dynamic> response = await supabase.from('pelanggan').insert([
        {
          'id_pelanggan': idParsed,
          'nama_pelanggan': nama,
          'alamat': alamat,
          'no_tlp': nomorTelepon,
        }
      ]).select();

      if (response.isNotEmpty) {
        _showSnackBar('Data pelanggan berhasil ditambahkan.');
        Navigator.pop(
            context, true); // Kembali ke halaman sebelumnya dengan nilai true
        _getAllPelanggan(); // Update data pelanggan untuk dropdown
      } else {
        _showSnackBar('Gagal menambahkan pelanggan: Data kosong.');
      }
    } catch (e) {
      _showSnackBar('Terjadi kesalahan: $e');
    } finally {
      setState(() {
        _isLoading = false;
      });
    }
  }

  void _getAllPelanggan() async {
    try {
      final response = await supabase.from('pelanggan').select();
      if (response.isNotEmpty) {
        setState(() {
          pelangganList = response
              .map((e) => {
                    'id': e['id_pelanggan'],
                    'nama': e['nama_pelanggan'],
                  })
              .toList();
        });
      }
    } catch (e) {
      _showSnackBar('Terjadi kesalahan mengambil data pelanggan: $e');
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        elevation: 0,
        backgroundColor: Colors.transparent,
        automaticallyImplyLeading: true,
        title: Text(
          'Tambah Pelanggan',
          style: GoogleFonts.poppins(
            fontSize: 24,
            fontWeight: FontWeight.w600,
            color: const Color(0xFF074799),
          ),
        ),
      ),
      body: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            TextField(
              controller: _idController,
              keyboardType: TextInputType.number,
              decoration: InputDecoration(
                labelText: 'ID Pelanggan',
                labelStyle: GoogleFonts.poppins(),
                border: const OutlineInputBorder(),
              ),
            ),
            const SizedBox(height: 16),
            TextField(
              controller: _namaController,
              decoration: InputDecoration(
                labelText: 'Nama Pelanggan',
                labelStyle: GoogleFonts.poppins(),
                border: const OutlineInputBorder(),
              ),
            ),
            const SizedBox(height: 16),
            TextField(
              controller: _alamatController,
              decoration: InputDecoration(
                labelText: 'Alamat',
                labelStyle: GoogleFonts.poppins(),
                border: const OutlineInputBorder(),
              ),
            ),
            const SizedBox(height: 16),
            TextField(
              controller: _nomorTeleponController,
              keyboardType: TextInputType.phone,
              decoration: InputDecoration(
                labelText: 'Nomor Telepon',
                labelStyle: GoogleFonts.poppins(),
                border: const OutlineInputBorder(),
              ),
            ),
            const SizedBox(height: 24),
            SizedBox(
              width: double.infinity,
              child: ElevatedButton(
                onPressed: _isLoading ? null : _addPelanggan,
                style: ElevatedButton.styleFrom(
                  backgroundColor: const Color(0xFF074799),
                  padding: const EdgeInsets.symmetric(vertical: 16),
                ),
                child: _isLoading
                    ? const CircularProgressIndicator(color: Colors.white)
                    : Text(
                        'Simpan',
                        style: GoogleFonts.poppins(
                          fontSize: 18,
                          fontWeight: FontWeight.bold,
                          color: Colors.white,
                        ),
                      ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}
