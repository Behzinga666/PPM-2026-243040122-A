import 'package:flutter/material.dart';

void main() {
  runApp(const MyApp());
}

class MyApp extends StatelessWidget {
  const MyApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      debugShowCheckedModeBanner: false,
      home: Scaffold(
        appBar: AppBar(
          title: const Text('Hello Flutter'),
          backgroundColor: Colors.red,
          foregroundColor: Colors.white,
        ),
        body: Center(
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              const Text('👋', style: TextStyle(fontSize: 64)),
              const SizedBox(height: 16),
              const Text(
                'Halo, Rizqy Ramadhan!',
                style: TextStyle(fontSize: 24, fontWeight: FontWeight.bold),
              ),
              const SizedBox(height: 8),
              const Text(
                'Selamat datang di ujung Dunia.',
                style: TextStyle(fontSize: 14, color: Colors.grey),
              ),
              const SizedBox(height: 24),
              Container(
                margin: const EdgeInsets.symmetric(horizontal: 32),
                padding: const EdgeInsets.all(20),
                decoration: BoxDecoration(
                  color: Colors.blue.shade50,
                  borderRadius: BorderRadius.circular(16),
                  border: Border.all(color: Colors.blue.shade200),
                ),
                child: const Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text('NIM: 243040122', style: TextStyle(fontSize: 16)),
                    SizedBox(height: 4),
                    Text('Prodi: Teknik Informatika', style: TextStyle(fontSize: 16)),
                    SizedBox(height: 4),
                    Text('Semester: 5', style: TextStyle(fontSize: 16)),
                  ],
                ),
              ),
              const SizedBox(height: 24),
              ElevatedButton(
                onPressed: () {
                  // Belum dipakai — akan dipelajari di praktikum berikutnya
                },
                child: const Text('Tap Saya'),
              ),
            ],
          ),
        ),
        bottomNavigationBar: Container(
          padding: const EdgeInsets.symmetric(vertical: 12),
          color: Colors.grey.shade100,
          child: const Row(
            mainAxisAlignment: MainAxisAlignment.spaceEvenly,
            children: [
              Icon(Icons.home, size: 32, color: Colors.red),
              Icon(Icons.add, size: 32, color: Colors.grey),
              Icon(Icons.leaderboard, size: 32, color: Colors.grey),
              Icon(Icons.person, size: 32, color: Colors.grey),
            ],
          ),
        ),
      ),
    );
  }
}