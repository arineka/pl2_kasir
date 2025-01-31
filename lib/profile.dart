import 'package:flutter/material.dart';
import 'package:supabase_flutter/supabase_flutter.dart';
import 'login.dart';
import 'produk.dart';
import 'pesanan.dart';
import 'history.dart';

class ProfilPage extends StatefulWidget {
  const ProfilPage({super.key});

  @override
  State<ProfilPage> createState() => _ProfilPageState();
}

class _ProfilPageState extends State<ProfilPage> {
  int _selectedIndex = 3;
  List<Map<String, dynamic>> _pelangganList = [];

  @override
  void initState() {
    super.initState();
    _fetchPelangganData();
  }

  Future<void> _fetchPelangganData() async {
    final supabase = Supabase.instance.client;

    try {
      final List<Map<String, dynamic>> data = await supabase
          .from('pelanggan')
          .select()
          .order('id_pelanggan', ascending: true);

      setState(() {
        _pelangganList = data;
      });
    } catch (error) {
      print('Error fetching data: $error');
    }
  }

  Future<void> _deletePelanggan(int id) async {
    final supabase = Supabase.instance.client;
    await supabase.from('pelanggan').delete().eq('id_pelanggan', id);

    // Perbarui tampilan setelah penghapusan
    setState(() {
      _pelangganList
          .removeWhere((pelanggan) => pelanggan['id_pelanggan'] == id);
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

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFFF6F8FC),
      appBar: AppBar(
        automaticallyImplyLeading: false,
        title: const Text(
          'Profil',
          style: TextStyle(
            fontSize: 24,
            fontWeight: FontWeight.w600,
            fontFamily: 'Poppins', // Menambahkan font Poppins
            color: Color(0xFF074799),
          ),
        ),
        actions: [
          IconButton(
            icon: const Icon(Icons.logout_rounded),
            color: const Color(0xFF074799),
            onPressed: _logout,
          ),
        ],
      ),
      body: _pelangganList.isEmpty
          ? const Center(child: CircularProgressIndicator())
          : Padding(
              padding: const EdgeInsets.all(16.0),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  // Menambahkan teks "Daftar Pelanggan"
                  const Text(
                    'Daftar Pelanggan',
                    style: TextStyle(
                      fontSize: 20,
                      fontWeight: FontWeight.bold,
                      fontFamily: 'Poppins',
                      color: Color(0xFF074799), // Sesuaikan warna dengan tema
                    ),
                  ),
                  const SizedBox(
                      height: 16), // Memberikan jarak antara teks dan daftar
                  // Daftar pelanggan
                  Expanded(
                    child: ListView.builder(
                      padding: const EdgeInsets.all(0),
                      itemCount: _pelangganList.length,
                      itemBuilder: (context, index) {
                        final pelanggan = _pelangganList[index];
                        return Card(
                          margin: const EdgeInsets.only(bottom: 10),
                          elevation: 2,
                          shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(12),
                          ),
                          child: ListTile(
                            title: Text(
                              pelanggan['nama_pelanggan'],
                              style: const TextStyle(
                                fontWeight: FontWeight.bold,
                                fontFamily:
                                    'Poppins', // Menambahkan font Poppins
                              ),
                            ),
                            subtitle: Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                Text('Alamat: ${pelanggan['alamat']}',
                                    style:
                                        const TextStyle(fontFamily: 'Poppins')),
                                Text('No. Telepon: ${pelanggan['no_tlp']}',
                                    style:
                                        const TextStyle(fontFamily: 'Poppins')),
                              ],
                            ),
                            trailing: IconButton(
                              icon: const Icon(Icons.delete, color: Colors.red),
                              onPressed: () =>
                                  _deletePelanggan(pelanggan['id_pelanggan']),
                            ),
                          ),
                        );
                      },
                    ),
                  ),
                ],
              ),
            ),
      bottomNavigationBar: _buildBottomNavBar(),
    );
  }

  BottomNavigationBar _buildBottomNavBar() {
    return BottomNavigationBar(
      currentIndex: _selectedIndex,
      onTap: (index) {
        setState(() {
          _selectedIndex = index;
        });
        switch (index) {
          case 0:
            Navigator.pushReplacement(
              context,
              MaterialPageRoute(builder: (context) => const Produk()),
            );
            break;
          case 1:
            Navigator.pushReplacement(
              context,
              MaterialPageRoute(builder: (context) => const Pesanan()),
            );
            break;
          case 2:
            Navigator.pushReplacement(
              context,
              MaterialPageRoute(builder: (context) => const Riwayat()),
            );
            break;
          case 3:
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
          icon: Icon(Icons.history_outlined),
          label: 'Riwayat',
        ),
        BottomNavigationBarItem(
          icon: Icon(Icons.person_outline),
          label: 'Profil',
        ),
      ],
    );
  }
}
