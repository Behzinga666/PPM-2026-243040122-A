import 'package:flutter/material.dart';

void main() {
  runApp(MaterialApp(
    debugShowCheckedModeBanner: false,
    home: Scaffold(
      appBar: AppBar(
        title: const Text('Latihan Icon'),
        backgroundColor: Colors.red, // Konsisten dengan tema merah pertemuan_1
        foregroundColor: Colors.white,
      ),
      body: const Center(
        child: Text('Lihat ikon-ikon di bawah 👇'),
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
  ));
}
