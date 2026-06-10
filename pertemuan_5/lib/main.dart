import 'package:flutter/material.dart';
import 'api_client.dart';

void main() {
  runApp(const MyApp());
}

// ==========================================
// 1. MODEL DATA (SESUAI MODUL)
// ==========================================
class Catatan {
  final int? id;
  final String judul;
  final String isi;
  final String kategori;
  final DateTime dibuatPada;

  Catatan({
    this.id,
    required this.judul,
    required this.isi,
    required this.kategori,
    required this.dibuatPada,
  });

  Map<String, dynamic> toJson() => {
        if (id != null) 'id': id,
        'judul': judul,
        'isi': isi,
        'kategori': kategori,
        'dibuat_pada': dibuatPada.toUtc().toIso8601String(),
      };

  static Catatan fromJson(Map<String, dynamic> m) => Catatan(
        id: m['id'] as int?,
        judul: m['judul'] as String,
        isi: m['isi'] as String,
        kategori: m['kategori'] as String,
        dibuatPada: DateTime.parse(m['dibuat_pada'] as String),
      );

  Catatan copyWith({String? judul, String? isi, String? kategori}) =>
      Catatan(
        id: id,
        judul: judul ?? this.judul,
        isi: isi ?? this.isi,
        kategori: kategori ?? this.kategori,
        dibuatPada: dibuatPada,
      );
}

// ==========================================
// 2. MAIN APPLICATION WIDGET
// ==========================================
class MyApp extends StatelessWidget {
  const MyApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'Catatan Mahasiswa',
      debugShowCheckedModeBanner: false,
      theme: ThemeData(colorSchemeSeed: Colors.indigo, useMaterial3: true),
      home: const HomePage(),
      onGenerateRoute: (settings) {
        switch (settings.name) {
          case '/tambah':
            return MaterialPageRoute(
              builder: (_) => TambahCatatanPage(catatanLama: settings.arguments as Catatan?),
            );
          case '/detail':
            return MaterialPageRoute(
              builder: (_) => DetailCatatanPage(catatan: settings.arguments as Catatan),
            );
        }
        return null;
      },
    );
  }
}

// ==========================================
// 3. HOME PAGE (DENGAN FUTUREBUILDER)
// ==========================================
class HomePage extends StatefulWidget {
  const HomePage({super.key});

  @override
  State<HomePage> createState() => _HomePageState();
}

class _HomePageState extends State<HomePage> {
  String _filterTerpilih = 'Semua';
  final _filterOpsi = const ['Semua', 'Kuliah', 'Tugas', 'Pribadi', 'Lainnya'];
  late Future<List<Catatan>> _futureNotes;

  @override
  void initState() {
    super.initState();
    _refreshData();
  }

  void _refreshData() {
    setState(() {
      _futureNotes = ApiClient.instance.getAll();
    });
  }

  Future<void> _bukaFormCatatan({Catatan? dataLama}) async {
    await Navigator.pushNamed(context, '/tambah', arguments: dataLama);
    _refreshData();
  }

  void _hapusCatatan(Catatan c) async {
    bool? yakin = await showDialog<bool>(
      context: context,
      builder: (ctx) => AlertDialog(
        title: const Text('Hapus Catatan'),
        content: Text('Yakin ingin menghapus "${c.judul}"?'),
        actions: [
          TextButton(onPressed: () => Navigator.pop(ctx, false), child: const Text('Batal')),
          TextButton(onPressed: () => Navigator.pop(ctx, true), child: const Text('Hapus', style: TextStyle(color: Colors.red))),
        ],
      ),
    );

    if (yakin == true) {
      try {
        await ApiClient.instance.delete(c.id!);
        if (!mounted) return;
        _refreshData();
        ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text('Catatan "${c.judul}" dihapus')));
      } on ApiException catch (e) {
        if (!mounted) return;
        ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text('Gagal: ${e.message}')));
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Catatan Mahasiswa'),
        backgroundColor: Theme.of(context).colorScheme.inversePrimary,
        actions: [
          DropdownButton<String>(
            value: _filterTerpilih,
            underline: const SizedBox(),
            items: _filterOpsi.map((f) => DropdownMenuItem(value: f, child: Text(f))).toList(),
            onChanged: (v) => setState(() => _filterTerpilih = v!),
          ),
          IconButton(icon: const Icon(Icons.refresh), onPressed: _refreshData),
        ],
      ),
      body: FutureBuilder<List<Catatan>>(
        future: _futureNotes,
        builder: (context, snapshot) {
          if (snapshot.connectionState == ConnectionState.waiting) {
            return const Center(child: CircularProgressIndicator());
          }
          if (snapshot.hasError) {
            final e = snapshot.error;
            final pesan = e is ApiException ? e.message : 'Terjadi kesalahan: $e';
            return Center(
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  const Icon(Icons.error_outline, size: 48),
                  const SizedBox(height: 8),
                  Text(pesan, textAlign: TextAlign.center),
                  const SizedBox(height: 12),
                  FilledButton(onPressed: _refreshData, child: const Text('Coba lagi')),
                ],
              ),
            );
          }
          
          final data = snapshot.data ?? [];
          final filtered = _filterTerpilih == 'Semua' 
              ? data 
              : data.where((c) => c.kategori == _filterTerpilih).toList();

          if (filtered.isEmpty) {
            return const Center(child: Text('Tidak ada catatan.'));
          }

          return RefreshIndicator(
            onRefresh: () async => _refreshData(),
            child: ListView.builder(
              itemCount: filtered.length,
              itemBuilder: (context, i) {
                final c = filtered[i];
                return Card(
                  margin: const EdgeInsets.symmetric(horizontal: 16, vertical: 6),
                  child: ListTile(
                    leading: const CircleAvatar(child: Icon(Icons.note)),
                    title: Text(c.judul),
                    subtitle: Text(c.kategori),
                    trailing: IconButton(
                      icon: const Icon(Icons.delete_outline, color: Colors.red),
                      onPressed: () => _hapusCatatan(c),
                    ),
                    onTap: () async {
                      final edit = await Navigator.pushNamed(context, '/detail', arguments: c);
                      if (edit == true) _bukaFormCatatan(dataLama: c);
                    },
                  ),
                );
              },
            ),
          );
        },
      ),
      floatingActionButton: FloatingActionButton(
        onPressed: () => _bukaFormCatatan(),
        child: const Icon(Icons.add),
      ),
    );
  }
}

// ==========================================
// 4. FORM PAGE (TAMBAH & EDIT)
// ==========================================
class TambahCatatanPage extends StatefulWidget {
  final Catatan? catatanLama;
  const TambahCatatanPage({super.key, this.catatanLama});

  @override
  State<TambahCatatanPage> createState() => _TambahCatatanPageState();
}

class _TambahCatatanPageState extends State<TambahCatatanPage> {
  final _formKey = GlobalKey<FormState>();
  late TextEditingController _judulCtrl, _isiCtrl;
  String _kategori = 'Kuliah';
  bool _isLoading = false;

  @override
  void initState() {
    super.initState();
    _judulCtrl = TextEditingController(text: widget.catatanLama?.judul ?? '');
    _isiCtrl = TextEditingController(text: widget.catatanLama?.isi ?? '');
    _kategori = widget.catatanLama?.kategori ?? 'Kuliah';
  }

  void _simpan() async {
    if (!_formKey.currentState!.validate()) return;
    setState(() => _isLoading = true);

    try {
      if (widget.catatanLama == null) {
        final baru = Catatan(
          judul: _judulCtrl.text.trim(),
          isi: _isiCtrl.text.trim(),
          kategori: _kategori,
          dibuatPada: DateTime.now(),
        );
        await ApiClient.instance.insert(baru);
      } else {
        final updated = widget.catatanLama!.copyWith(
          judul: _judulCtrl.text.trim(),
          isi: _isiCtrl.text.trim(),
          kategori: _kategori,
        );
        await ApiClient.instance.update(updated);
      }
      if (!mounted) return;
      Navigator.pop(context);
    } on ApiException catch (e) {
      if (!mounted) return;
      ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text('Gagal: ${e.message}')));
    } finally {
      if (mounted) setState(() => _isLoading = false);
    }
  }

  @override
  Widget build(BuildContext context) {
    bool isEdit = widget.catatanLama != null;
    return Scaffold(
      appBar: AppBar(title: Text(isEdit ? 'Edit Catatan' : 'Tambah Catatan')),
      body: _isLoading 
          ? const Center(child: CircularProgressIndicator())
          : Form(
              key: _formKey,
              child: ListView(
                padding: const EdgeInsets.all(16),
                children: [
                  TextFormField(
                    controller: _judulCtrl, 
                    decoration: const InputDecoration(labelText: 'Judul'),
                    validator: (v) => v!.isEmpty ? 'Judul tidak boleh kosong' : null,
                  ),
                  DropdownButtonFormField<String>(
                    value: _kategori,
                    items: ['Kuliah', 'Tugas', 'Pribadi', 'Lainnya'].map((e) => DropdownMenuItem(value: e, child: Text(e))).toList(),
                    onChanged: (v) => setState(() => _kategori = v!),
                  ),
                  TextFormField(
                    controller: _isiCtrl, 
                    maxLines: 3, 
                    decoration: const InputDecoration(labelText: 'Isi'),
                    validator: (v) => v!.isEmpty ? 'Isi tidak boleh kosong' : null,
                  ),
                  const SizedBox(height: 20),
                  ElevatedButton(onPressed: _simpan, child: const Text('Simpan')),
                ],
              ),
            ),
    );
  }
}

// ==========================================
// 5. DETAIL PAGE
// ==========================================
class DetailCatatanPage extends StatelessWidget {
  final Catatan catatan;
  const DetailCatatanPage({super.key, required this.catatan});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Detail'),
        actions: [IconButton(icon: const Icon(Icons.edit), onPressed: () => Navigator.pop(context, true))],
      ),
      body: Padding(
        padding: const EdgeInsets.all(20),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(catatan.judul, style: const TextStyle(fontSize: 24, fontWeight: FontWeight.bold)),
            const SizedBox(height: 10),
            Text('Kategori: ${catatan.kategori}'),
            const Divider(),
            Text(catatan.isi, style: const TextStyle(fontSize: 16)),
          ],
        ),
      ),
    );
  }
}
