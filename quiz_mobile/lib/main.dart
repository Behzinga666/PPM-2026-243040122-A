import 'package:flutter/foundation.dart' show kIsWeb;
import 'package:flutter/material.dart';
import 'package:image_picker/image_picker.dart';
import 'dart:io' show File; // Tetap simpan untuk mobile kalau perlu

void main() {
  runApp(const QuizApp());
}

class QuizApp extends StatelessWidget {
  const QuizApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      debugShowCheckedModeBanner: false,
      title: 'Quiz Mobile',
      theme: ThemeData(
        useMaterial3: true,
        colorScheme: ColorScheme.fromSeed(seedColor: const Color(0xFF800000)),
      ),
      home: const MainProfilePage(),
    );
  }
}

// ==========================================
// 1. MODELS
// ==========================================
class ProfileData {
  String name;
  String role;
  String bio;
  String pendidikan;
  String lokasi;
  String kontak;
  String skills;
  XFile? profileImage;

  ProfileData({
    this.name = 'Rizqy Ramadhan',
    this.role = 'Mahasiswa Teknik Informatika',
    this.bio = 'Belajar Flutter!',
    this.pendidikan = 'Teknik Informatika - Semester 5',
    this.lokasi = 'Bandung, Jawa Barat',
    this.kontak = 'rizqyrmdhn@student.ac.id',
    this.skills = 'Flutter, Dart, Java, Python, Git, C*',
    this.profileImage,
  });
}

class ExperienceData {
  String title;
  String description;
  XFile? image;

  ExperienceData({
    this.title = '',
    this.description = '',
    this.image,
  });
}

// ==========================================
// 2. MAIN PROFILE PAGE
// ==========================================
class MainProfilePage extends StatefulWidget {
  const MainProfilePage({super.key});

  @override
  State<MainProfilePage> createState() => _MainProfilePageState();
}

class _MainProfilePageState extends State<MainProfilePage> {
  ProfileData profile = ProfileData();
  List<ExperienceData> experiences = [];

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Profil Saya'),
        actions: [IconButton(icon: const Icon(Icons.search), onPressed: () {})],
      ),
      drawer: Drawer(
        child: Column(
          children: [
            UserAccountsDrawerHeader(
              accountName: Text(profile.name),
              accountEmail: Text(profile.kontak),
              currentAccountPicture: CircleAvatar(
                backgroundImage: profile.profileImage != null 
                    ? (kIsWeb ? NetworkImage(profile.profileImage!.path) : FileImage(File(profile.profileImage!.path))) as ImageProvider
                    : null,
                child: profile.profileImage == null ? const Icon(Icons.person) : null,
              ),
              decoration: const BoxDecoration(color: Color(0xFF800000)),
            ),
            ListTile(
              leading: const Icon(Icons.person),
              title: const Text('Profil'),
              onTap: () => Navigator.pop(context),
            ),
            ListTile(
              leading: const Icon(Icons.grid_view),
              title: const Text('Widget Gallery'),
              onTap: () {},
            ),
            ListTile(
              leading: const Icon(Icons.upload_file),
              title: const Text('Upload Pengalaman'),
              onTap: () async {
                Navigator.pop(context);
                final result = await Navigator.push(
                  context,
                  MaterialPageRoute(builder: (_) => const EditExperiencePage()),
                );
                if (result != null) setState(() => experiences.add(result));
              },
            ),
            ListTile(
              leading: const Icon(Icons.settings),
              title: const Text('Pengaturan'),
              onTap: () {},
            ),
          ],
        ),
      ),
      body: SingleChildScrollView(
        child: Column(
          children: [
            const SizedBox(height: 20),
            // Avatar & Name
            CircleAvatar(
              radius: 50,
              backgroundImage: profile.profileImage != null 
                  ? (kIsWeb ? NetworkImage(profile.profileImage!.path) : FileImage(File(profile.profileImage!.path))) as ImageProvider
                  : null,
              child: profile.profileImage == null ? const Icon(Icons.person, size: 50) : null,
            ),
            const SizedBox(height: 10),
            Text(profile.name, style: const TextStyle(fontSize: 20, fontWeight: FontWeight.bold)),
            Text(profile.role, style: const TextStyle(color: Colors.grey)),
            const SizedBox(height: 20),
            // Stats
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceEvenly,
              children: const [
                _StatItem(label: 'Post', value: '6'),
                _StatItem(label: 'Teman', value: '6'),
                _StatItem(label: 'Like', value: '6'),
              ],
            ),
            const SizedBox(height: 20),
            // Sections
            _InfoSection(icon: Icons.info, title: 'Tentang', content: profile.bio),
            _InfoSection(icon: Icons.school, title: 'Pendidikan', content: profile.pendidikan),
            _InfoSection(icon: Icons.location_on, title: 'Lokasi', content: profile.lokasi),
            _InfoSection(icon: Icons.email, title: 'Kontak', content: profile.kontak),
            _InfoSection(
              icon: Icons.star, 
              title: 'Skills', 
              content: profile.skills,
              isChips: true,
            ),
            // Experience Section (BONUS)
            if (experiences.isNotEmpty)
              Padding(
                padding: const EdgeInsets.all(16.0),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    const Row(
                      children: [
                        Icon(Icons.work, color: Color(0xFF800000)),
                        SizedBox(width: 10),
                        Text('Pengalaman', style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold)),
                      ],
                    ),
                    const SizedBox(height: 10),
                    ...experiences.map((exp) => Card(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          if (exp.image != null)
                            kIsWeb 
                              ? Image.network(exp.image!.path, width: double.infinity, height: 150, fit: BoxFit.cover)
                              : Image.file(File(exp.image!.path), width: double.infinity, height: 150, fit: BoxFit.cover),
                          Padding(
                            padding: const EdgeInsets.all(12.0),
                            child: Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                Text(exp.title, style: const TextStyle(fontWeight: FontWeight.bold)),
                                Text(exp.description),
                              ],
                            ),
                          ),
                        ],
                      ),
                    )),
                  ],
                ),
              ),
          ],
        ),
      ),
      floatingActionButton: FloatingActionButton.extended(
        onPressed: () async {
          final result = await Navigator.push(
            context,
            MaterialPageRoute(builder: (_) => EditProfilePage(profile: profile)),
          );
          if (result != null) setState(() => profile = result);
        },
        label: const Text('Edit Profil'),
        icon: const Icon(Icons.edit),
      ),
    );
  }
}

// ==========================================
// 3. EDIT PROFILE PAGE
// ==========================================
class EditProfilePage extends StatefulWidget {
  final ProfileData profile;
  const EditProfilePage({super.key, required this.profile});

  @override
  State<EditProfilePage> createState() => _EditProfilePageState();
}

class _EditProfilePageState extends State<EditProfilePage> {
  late TextEditingController _nameCtrl, _roleCtrl, _bioCtrl, _eduCtrl, _locCtrl, _kontakCtrl, _skillsCtrl;
  XFile? _image;

  @override
  void initState() {
    super.initState();
    _nameCtrl = TextEditingController(text: widget.profile.name);
    _roleCtrl = TextEditingController(text: widget.profile.role);
    _bioCtrl = TextEditingController(text: widget.profile.bio);
    _eduCtrl = TextEditingController(text: widget.profile.pendidikan);
    _locCtrl = TextEditingController(text: widget.profile.lokasi);
    _kontakCtrl = TextEditingController(text: widget.profile.kontak);
    _skillsCtrl = TextEditingController(text: widget.profile.skills);
    _image = widget.profile.profileImage;
  }

  @override
  void dispose() {
    _nameCtrl.dispose();
    _roleCtrl.dispose();
    _bioCtrl.dispose();
    _eduCtrl.dispose();
    _locCtrl.dispose();
    _kontakCtrl.dispose();
    _skillsCtrl.dispose();
    super.dispose();
  }

  Future<void> _pickImage() async {
    final picker = ImagePicker();
    final pickedFile = await picker.pickImage(source: ImageSource.gallery);
    if (pickedFile != null) setState(() => _image = pickedFile);
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Edit Profil'),
        actions: [
          TextButton(
            onPressed: () {
              widget.profile.name = _nameCtrl.text;
              widget.profile.role = _roleCtrl.text;
              widget.profile.bio = _bioCtrl.text;
              widget.profile.pendidikan = _eduCtrl.text;
              widget.profile.lokasi = _locCtrl.text;
              widget.profile.kontak = _kontakCtrl.text;
              widget.profile.skills = _skillsCtrl.text;
              widget.profile.profileImage = _image;
              Navigator.pop(context, widget.profile);
            },
            child: const Text('Simpan'),
          )
        ],
      ),
      body: ListView(
        padding: const EdgeInsets.all(16),
        children: [
          Center(
            child: Column(
              children: [
                const Text('Foto Profil', style: TextStyle(color: Colors.blue, fontWeight: FontWeight.bold)),
                const SizedBox(height: 10),
                Stack(
                  children: [
                    CircleAvatar(
                      radius: 50,
                      backgroundImage: _image != null 
                          ? (kIsWeb ? NetworkImage(_image!.path) : FileImage(File(_image!.path))) as ImageProvider
                          : null,
                      child: _image == null ? const Icon(Icons.person, size: 50) : null,
                    ),
                    Positioned(
                      bottom: 0,
                      right: 0,
                      child: GestureDetector(
                        onTap: _pickImage,
                        child: const CircleAvatar(
                          radius: 18,
                          backgroundColor: Colors.blue,
                          child: Icon(Icons.camera_alt, color: Colors.white, size: 18),
                        ),
                      ),
                    ),
                  ],
                ),
                TextButton.icon(
                  onPressed: _pickImage,
                  icon: const Icon(Icons.image),
                  label: const Text('Ganti Foto dari Galeri'),
                ),
              ],
            ),
          ),
          const Divider(),
          const Text('Informasi Profil', style: TextStyle(color: Colors.blue, fontWeight: FontWeight.bold)),
          const SizedBox(height: 10),
          _buildTextField('Nama Lengkap *', _nameCtrl, Icons.person_outline),
          _buildTextField('Role / Pekerjaan', _roleCtrl, Icons.work_outline),
          _buildTextField('Bio / Tentang', _bioCtrl, Icons.info_outline, maxLines: 3),
          _buildTextField('Pendidikan', _eduCtrl, Icons.school_outlined),
          _buildTextField('Lokasi', _locCtrl, Icons.location_on_outlined),
          _buildTextField('Kontak / Email', _kontakCtrl, Icons.email_outlined),
          _buildTextField('Skills (pisahkan dengan koma)', _skillsCtrl, Icons.star_outline),
          const SizedBox(height: 20),
          ElevatedButton.icon(
            onPressed: () {
              widget.profile.name = _nameCtrl.text;
              widget.profile.role = _roleCtrl.text;
              widget.profile.bio = _bioCtrl.text;
              widget.profile.pendidikan = _eduCtrl.text;
              widget.profile.lokasi = _locCtrl.text;
              widget.profile.kontak = _kontakCtrl.text;
              widget.profile.skills = _skillsCtrl.text;
              widget.profile.profileImage = _image;
              Navigator.pop(context, widget.profile);
            },
            icon: const Icon(Icons.save),
            label: const Text('Simpan Perubahan'),
            style: ElevatedButton.styleFrom(
              minimumSize: const Size(double.infinity, 50),
              backgroundColor: const Color(0xFF800000),
              foregroundColor: Colors.white,
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildTextField(String label, TextEditingController ctrl, IconData icon, {int maxLines = 1}) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 15),
      child: TextField(
        controller: ctrl,
        maxLines: maxLines,
        decoration: InputDecoration(
          labelText: label,
          prefixIcon: Icon(icon),
          border: const OutlineInputBorder(),
        ),
      ),
    );
  }
}

// ==========================================
// 4. EDIT EXPERIENCE PAGE (BONUS)
// ==========================================
class EditExperiencePage extends StatefulWidget {
  const EditExperiencePage({super.key});

  @override
  State<EditExperiencePage> createState() => _EditExperiencePageState();
}

class _EditExperiencePageState extends State<EditExperiencePage> {
  final _titleCtrl = TextEditingController();
  final _descCtrl = TextEditingController();
  XFile? _image;

  @override
  void dispose() {
    _titleCtrl.dispose();
    _descCtrl.dispose();
    super.dispose();
  }

  Future<void> _pickImage() async {
    final picker = ImagePicker();
    final pickedFile = await picker.pickImage(source: ImageSource.gallery);
    if (pickedFile != null) setState(() => _image = pickedFile);
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Upload Pengalaman'),
        actions: [
          IconButton(
            icon: const Icon(Icons.save),
            onPressed: () {
              if (_titleCtrl.text.isNotEmpty) {
                Navigator.pop(context, ExperienceData(
                  title: _titleCtrl.text,
                  description: _descCtrl.text,
                  image: _image,
                ));
              }
            },
          )
        ],
      ),
      body: ListView(
        padding: const EdgeInsets.all(16),
        children: [
          GestureDetector(
            onTap: _pickImage,
            child: Container(
              height: 200,
              decoration: BoxDecoration(
                color: const Color(0xFF800000).withAlpha(25),
                borderRadius: BorderRadius.circular(12),
                border: Border.all(color: const Color(0xFF800000).withAlpha(76)),
              ),
              child: _image != null
                  ? ClipRRect(
                      borderRadius: BorderRadius.circular(12),
                      child: kIsWeb 
                          ? Image.network(_image!.path, fit: BoxFit.cover) 
                          : Image.file(File(_image!.path), fit: BoxFit.cover),
                    )
                  : Column(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: const [
                        Icon(Icons.add_photo_alternate_outlined, size: 50, color: Color(0xFF800000)),
                        Text('Ketuk untuk pilih gambar', style: TextStyle(color: Color(0xFF800000))),
                        Text('dari galeri perangkat kamu', style: TextStyle(fontSize: 12, color: Colors.grey)),
                      ],
                    ),
            ),
          ),
          const SizedBox(height: 20),
          const Text('Informasi Pengalaman', style: TextStyle(color: Colors.blue, fontWeight: FontWeight.bold)),
          const SizedBox(height: 10),
          TextField(
            controller: _titleCtrl,
            decoration: const InputDecoration(labelText: 'Judul *', prefixIcon: Icon(Icons.title), border: OutlineInputBorder()),
          ),
          const SizedBox(height: 15),
          TextField(
            controller: _descCtrl,
            maxLines: 4,
            decoration: const InputDecoration(labelText: 'Deskripsi', prefixIcon: Icon(Icons.description), border: OutlineInputBorder()),
          ),
          const SizedBox(height: 20),
          ElevatedButton.icon(
            onPressed: () {
               if (_titleCtrl.text.isNotEmpty) {
                Navigator.pop(context, ExperienceData(
                  title: _titleCtrl.text,
                  description: _descCtrl.text,
                  image: _image,
                ));
              }
            },
            icon: const Icon(Icons.save),
            label: const Text('Simpan Pengalaman'),
            style: ElevatedButton.styleFrom(
              minimumSize: const Size(double.infinity, 50),
              backgroundColor: const Color(0xFF800000),
              foregroundColor: Colors.white,
            ),
          ),
        ],
      ),
    );
  }
}

// ==========================================
// HELPERS
// ==========================================
class _StatItem extends StatelessWidget {
  final String label, value;
  const _StatItem({required this.label, required this.value});

  @override
  Widget build(BuildContext context) {
    return Column(
      children: [
        Text(value, style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 18)),
        Text(label, style: const TextStyle(color: Colors.grey)),
      ],
    );
  }
}

class _InfoSection extends StatelessWidget {
  final IconData icon;
  final String title, content;
  final bool isChips;
  const _InfoSection({required this.icon, required this.title, required this.content, this.isChips = false});

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Icon(icon, color: const Color(0xFF800000), size: 20),
              const SizedBox(width: 10),
              Text(title, style: const TextStyle(fontWeight: FontWeight.bold)),
            ],
          ),
          Padding(
            padding: const EdgeInsets.only(left: 30),
            child: isChips 
              ? Wrap(
                  spacing: 8,
                  children: content.split(',').map((s) => Chip(label: Text(s.trim()))).toList(),
                )
              : Text(content),
          ),
          const Divider(),
        ],
      ),
    );
  }
}
