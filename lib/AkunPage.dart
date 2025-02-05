import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:supabase_flutter/supabase_flutter.dart';
import 'package:shared_preferences/shared_preferences.dart';
// import 'package:ukk_coba/bottomnavbar.dart';

class AkunPage extends StatefulWidget {
  const AkunPage({super.key});

  @override
  _AkunPageState createState() => _AkunPageState();
}

class _AkunPageState extends State<AkunPage> {
  String username = '';
  String role = '';
  List<Map<String, String>> userDataList = [];

  @override
  void initState() {
    super.initState();
    _loadUsernameAndRole();
  }

  // Ambil username dari SharedPreferences dan role dari Supabase
  Future<void> _loadUsernameAndRole() async {
    final prefs = await SharedPreferences.getInstance();
    final savedUsername = prefs.getString('username') ?? '';

    if (savedUsername.isNotEmpty) {
      final response = await Supabase.instance.client
          .from('users')
          .select('username, role')
          .eq('username', savedUsername)
          .single();

      if (response != null) {
        setState(() {
          username = response['username'];
          role = response['role'] ?? 'Tidak ada role';
          // Menambahkan data ke list
          userDataList = [
            {'username': username, 'role': role},
          ];
        });
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFFF6F8FC),
      // appBar: AppBar(
      //   automaticallyImplyLeading: false,
      //   title: const Text(
      //     'Akun',
      //     style: TextStyle(
      //       fontSize: 24,
      //       fontWeight: FontWeight.w600,
      //       fontFamily: 'Poppins',
      //       color: Color(0xFF074799),
      //     ),
      //   ),
      // ),
      body: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            const SizedBox(height: 16),
            userDataList.isEmpty
                ? const Expanded(
                    child: Center(
                      child: Text(
                        'Belum ada data akun',
                        style: TextStyle(
                          fontSize: 16,
                          fontFamily: 'Poppins',
                          color: Colors.grey,
                        ),
                      ),
                    ),
                  )
                : Expanded(
                    child: ListView.builder(
                      padding: const EdgeInsets.all(0),
                      itemCount: userDataList.length,
                      itemBuilder: (context, index) {
                        final user = userDataList[index];
                        return Card(
                          margin: const EdgeInsets.only(bottom: 10),
                          elevation: 2,
                          shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(12),
                          ),
                          child: ListTile(
                            title: Text(
                              user['username'] ?? 'Tidak ada username',
                              style: const TextStyle(
                                fontWeight: FontWeight.bold,
                                fontFamily: 'Poppins',
                              ),
                            ),
                            subtitle: Text(
                              'Role: ${user['role'] ?? 'Tidak ada role'}',
                              style: const TextStyle(fontFamily: 'Poppins'),
                            ),
                            trailing: Row(
                              mainAxisSize: MainAxisSize.min,
                              children: [
                                IconButton(
                                  icon: const Icon(Icons.edit, color: Colors.blue),
                                  onPressed: () {
                                    // Tindakan untuk mengedit akun
                                  },
                                ),
                                IconButton(
                                  icon: const Icon(Icons.delete, color: Colors.red),
                                  onPressed: () {
                                    // Tindakan untuk menghapus akun
                                  },
                                ),
                              ],
                            ),
                          ),
                        );
                      },
                    ),
                  ),
          ],
        ),
      ),
      // bottomNavigationBar: BottomNavBar(),
      floatingActionButton: FloatingActionButton(
        onPressed: () {
          // Tindakan untuk menambah akun
        },
        child: const Icon(Icons.add, color: Colors.white),
        backgroundColor: const Color(0xFF074799),
      ),
    );
  }
}
