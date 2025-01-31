// import 'package:flutter/material.dart';
// import 'package:google_fonts/google_fonts.dart';
// import 'package:ukk_coba/history.dart'; // Pastikan ini benar mengarah ke file Riwayat

// class Checkout extends StatelessWidget {
//   final List<Map<String, dynamic>> keranjang; // Data keranjang belanja
//   final Map<String, dynamic> pelanggan; // Data pelanggan
//   final double totalHarga; // Total harga pesanan

//   const Checkout({
//     super.key,
//     required this.keranjang,
//     required this.pelanggan,
//     required this.totalHarga,
//   });

//   @override
//   Widget build(BuildContext context) {
//     return Scaffold(
//       appBar: AppBar(
//         title: Text(
//           'Detail Checkout',
//           style: GoogleFonts.poppins(
//             fontSize: 24,
//             fontWeight: FontWeight.w600,
//             color: const Color(0xFF074799),
//           ),
//         ),
//       ),
//       body: Padding(
//         padding: const EdgeInsets.all(16.0),
//         child: Column(
//           crossAxisAlignment: CrossAxisAlignment.start,
//           children: [
//             // Bagian informasi pelanggan
//             Text(
//               'Pelanggan',
//               style: GoogleFonts.poppins(
//                 fontSize: 16,
//                 fontWeight: FontWeight.bold,
//                 color: Colors.blue.shade800,
//               ),
//             ),
//             const SizedBox(height: 8),
//             Text(
//               'Nama: ${pelanggan['nama_pelanggan']}',
//               style: GoogleFonts.poppins(fontSize: 14),
//             ),
//             Text(
//               'Alamat: ${pelanggan['alamat']}',
//               style: GoogleFonts.poppins(fontSize: 14),
//             ),
//             Text(
//               'No. Telepon: ${pelanggan['no_tlp']}',
//               style: GoogleFonts.poppins(fontSize: 14),
//             ),
//             const Divider(height: 32),
//             // Bagian detail pesanan
//             Text(
//               'Detail Pesanan',
//               style: GoogleFonts.poppins(
//                 fontSize: 16,
//                 fontWeight: FontWeight.bold,
//                 color: Colors.blue.shade800,
//               ),
//             ),
//             const SizedBox(height: 8),
//             Expanded(
//               child: ListView.builder(
//                 itemCount: keranjang.length, // Jumlah item di keranjang
//                 itemBuilder: (context, index) {
//                   final item = keranjang[index]; // Ambil item berdasarkan index
//                   return ListTile(
//                     title: Text(item['nama_produk']), // Nama produk
//                     subtitle: Text(
//                       'Jumlah: ${item['jumlah']} | Subtotal: Rp${item['subtotal']}', // Jumlah dan subtotal produk
//                       style: GoogleFonts.poppins(fontSize: 14),
//                     ),
//                   );
//                 },
//               ),
//             ),
//             const Divider(height: 32),
//             // Bagian Total Harga dan Tombol Aksi
//             Row(
//               mainAxisAlignment: MainAxisAlignment.spaceBetween,
//               children: [
//                 Text(
//                   'Total: Rp$totalHarga', // Menampilkan total harga
//                   style: GoogleFonts.poppins(
//                     fontSize: 20,
//                     fontWeight: FontWeight.bold,
//                   ),
//                 ),
//                 Column(
//                   children: [
//                     ElevatedButton(
//                       onPressed: () {
//                         Navigator.pop(context); // Kembali ke halaman sebelumnya
//                       },
//                       style: ElevatedButton.styleFrom(
//                         backgroundColor: const Color(0xFF074799),
//                         shape: RoundedRectangleBorder(
//                           borderRadius: BorderRadius.circular(8),
//                         ),
//                       ),
//                       child: const Text(
//                         'Kembali',
//                         style: TextStyle(color: Colors.white),
//                       ),
//                     ),
//                     const SizedBox(height: 8),
//                     ElevatedButton(
//                       onPressed: () {
//                         // Aksi setelah menekan 'Ke Riwayat'
//                         Navigator.pushReplacement(
//                           context,
//                           MaterialPageRoute(
//                               builder: (context) => const Riwayat()),
//                         );
//                       },
//                       style: ElevatedButton.styleFrom(
//                         backgroundColor: Colors.green,
//                         shape: RoundedRectangleBorder(
//                           borderRadius: BorderRadius.circular(8),
//                         ),
//                       ),
//                       child: const Text(
//                         'Ke Riwayat',
//                         style: TextStyle(color: Colors.white),
//                       ),
//                     ),
//                   ],
//                 ),
//               ],
//             ),
//           ],
//         ),
//       ),
//     );
//   }
// }
