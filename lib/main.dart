import 'package:flutter/material.dart';
import 'screens/login_screen.dart';
import 'package:supabase_flutter/supabase_flutter.dart';

Future<void> main() async {
  WidgetsFlutterBinding.ensureInitialized();

  await Supabase.initialize(
    url: 'https://hmjhjubqivdhewhlysil.supabase.co',
    anonKey: 'eyJhbGciOiJIUzI1NiIsInR5cCI6IkpXVCJ9.eyJpc3MiOiJzdXBhYmFzZSIsInJlZiI6ImhtamhqdWJxaXZkaGV3aGx5c2lsIiwicm9sZSI6ImFub24iLCJpYXQiOjE3NjQ2MDEyOTEsImV4cCI6MjA4MDE3NzI5MX0.r5BdWCzqSVO7WaiYT3TD5FJizSEWL6ekt_1oChpiUc8',
  );
  runApp(const MyApp());
}

class MyApp extends StatelessWidget {
  const MyApp({super.key}); // pakai super.key (lebih baru & rapi)

  @override
  Widget build(BuildContext context) {
    return const MaterialApp(
      debugShowCheckedModeBanner: false,
      home: LoginScreen(), // halaman awal
    );
  }
}
