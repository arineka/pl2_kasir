import 'package:flutter/material.dart';
import 'package:supabase_flutter/supabase_flutter.dart';
import 'package:ukk_coba/dashboard.dart';
import 'package:ukk_coba/login.dart';

Future<void> main() async {
  await Supabase.initialize(
    url: 'https://rboyfzrwbznmltknjjtv.supabase.co',
    anonKey: 'eyJhbGciOiJIUzI1NiIsInR5cCI6IkpXVCJ9.eyJpc3MiOiJzdXBhYmFzZSIsInJlZiI6InJib3lmenJ3YnpubWx0a25qanR2Iiwicm9sZSI6ImFub24iLCJpYXQiOjE3MzYxMjk3MzIsImV4cCI6MjA1MTcwNTczMn0.GV01DAMYB6txz7dK-q2ERwRu5jeHfnzRrBaL3qvrAH4',
  );
  runApp(MyApp());
}

class MyApp extends StatelessWidget {
  const MyApp({super.key});

  // This widget is the root of your application.
  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      debugShowCheckedModeBanner: false,
      title: 'Flutter Demo',
      home: Login(),
    );
  }
}
        