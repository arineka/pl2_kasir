import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
// import 'package:ukk_coba/regristasi.dart';
// import 'package:flutter/gestures.dart';

class Dashboard extends StatefulWidget {
  const Dashboard({super.key});

  @override
  State<Dashboard> createState() => _DashboardState();
}

class _DashboardState extends State<Dashboard> {
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.white,
      body: SafeArea(
        child: Padding(
          padding: const EdgeInsets.all(24.0),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              // const SizedBox(
              //   height: 8,
              // ),
              Text(
                "hi, asep",
                style: GoogleFonts.poppins(
                    fontSize: 18,
                    fontWeight: FontWeight.w500,
                    color: Colors.blue),
              )
              
            ],
          ),
        ),
      ),
    );
  }
}
