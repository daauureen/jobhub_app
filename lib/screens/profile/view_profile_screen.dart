import 'dart:io';
import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:firebase_storage/firebase_storage.dart';
import 'package:image_picker/image_picker.dart';
import 'package:intl/intl.dart';
import '../../utils/theme_manager.dart';

class ViewProfileScreen extends StatefulWidget {
  final String? userId;
  final bool? isEmployer;

  const ViewProfileScreen({this.userId, this.isEmployer, Key? key}) : super(key: key);

  @override
  State<ViewProfileScreen> createState() => _ViewProfileScreenState();
}

class _ViewProfileScreenState extends State<ViewProfileScreen> {
  bool isEmployer = false;
  Map<String, dynamic>? userData;

  Future<void> _uploadFile(String path, String storagePath, String fieldName) async {
    final file = File(path);
    final uid = FirebaseAuth.instance.currentUser!.uid;
    final ref = FirebaseStorage.instance.ref('$uid/$storagePath');
    final task = await ref.putFile(file);
    final url = await task.ref.getDownloadURL();

    await FirebaseFirestore.instance.collection('users').doc(uid).update({
      fieldName: url,
    });

    setState(() {
      userData![fieldName] = url;
    });

    ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text('$fieldName успешно загружен')));
  }

  Future<void> pickAndUploadImage() async {
    final picker = ImagePicker();
    final image = await picker.pickImage(source: ImageSource.gallery);
    if (image != null) {
      await _uploadFile(image.path, 'profile.jpg', 'profileImageUrl');
    }
  }

  Future<void> pickAndUploadResume() async {
    final picker = ImagePicker();
    final file = await picker.pickImage(source: ImageSource.gallery);
    if (file != null) {
      await _uploadFile(file.path, 'resume.pdf', 'resumeUrl');
    }
  }

  @override
  Widget build(BuildContext context) {
    final uid = widget.userId ?? FirebaseAuth.instance.currentUser!.uid;

    return AnimatedBuilder(
      animation: themeNotifier,
      builder: (context, _) {
        final isDarkMode = themeNotifier.value == ThemeMode.dark;

        return Scaffold(
          backgroundColor: isDarkMode ? Colors.black : Colors.grey[100],
          appBar: AppBar(
            backgroundColor: isDarkMode ? Colors.grey[900] : Colors.white,
            iconTheme: IconThemeData(color: isDarkMode ? Colors.white : Colors.black),
            title: Text('Профиль', style: TextStyle(color: isDarkMode ? Colors.white : Colors.black)),
            elevation: 0,
            actions: [
              IconButton(
                icon: const Icon(Icons.edit),
                onPressed: () =>  Navigator.pushNamed(context, '/edit_profile').then((_) {
        setState(() {}); // обновим FutureBuilder
      })
              )
            ],
          ),
          body: _buildBody(uid, isDarkMode),
        );
      },
    );
  }

  Widget _buildBody(String uid, bool isDarkMode) {
    return FutureBuilder<DocumentSnapshot>(
      future: FirebaseFirestore.instance.collection('users').doc(uid).get(),
      builder: (context, snapshot) {
        if (snapshot.connectionState == ConnectionState.waiting)
          return const Center(child: CircularProgressIndicator());

        if (!snapshot.hasData || !snapshot.data!.exists)
          return const Center(child: Text('Пользователь не найден'));

        userData = snapshot.data!.data() as Map<String, dynamic>;
        isEmployer = widget.isEmployer ?? userData!['role'] == 'employer';

        return ListView(
          padding: const EdgeInsets.all(16),
          children: [
            Center(
              child: Stack(
                alignment: Alignment.bottomRight,
                children: [
                  CircleAvatar(
                    radius: 50,
                    backgroundImage: userData!['profileImageUrl'] != null
                        ? NetworkImage(userData!['profileImageUrl'])
                        : null,
                    child: userData!['profileImageUrl'] == null
                        ? const Icon(Icons.person, size: 50, color: Colors.grey)
                        : null,
                  ),
                  IconButton(
                    icon: const Icon(Icons.camera_alt, size: 20),
                    onPressed: pickAndUploadImage,
                  ),
                ],
              ),
            ),
            const SizedBox(height: 16),
            Center(
              child: Text(
                userData!['name'] ?? 'Без имени',
                style: TextStyle(
                    fontSize: 20,
                    fontWeight: FontWeight.bold,
                    color: isDarkMode ? Colors.white : Colors.black),
              ),
            ),
            const SizedBox(height: 24),

            // Тёмная тема
            Card(
              child: SwitchListTile(
                title: const Text('Тёмная тема'),
                value: themeNotifier.value == ThemeMode.dark,
                onChanged: (val) => themeNotifier.value = val ? ThemeMode.dark : ThemeMode.light,
              ),
            ),

            const SizedBox(height: 12),

            _buildSection('Личная информация', [
              _buildField('Email', userData!['email'], isDarkMode),
              _buildField('Телефон', userData!['phone'], isDarkMode),
              _buildField('Дата рождения', formatDate(userData!['birthDate']), isDarkMode),
              _buildField('О себе', userData!['bio'], isDarkMode),
            ]),

            if (isEmployer)
              _buildSection('О компании', [
                _buildField('Компания', userData!['companyName'], isDarkMode),
                _buildField('Контактное лицо', userData!['contactPerson'], isDarkMode),
                _buildField('Адрес', userData!['address'], isDarkMode),
                _buildField('Описание', userData!['companyDescription'], isDarkMode),
                _buildField('Сайт', userData!['website'], isDarkMode),
              ]),

            if (!isEmployer)
              _buildSection('Резюме', [
                ListTile(
                  title: const Text('Файл резюме'),
                  subtitle: Text(
                    userData!['resumeUrl'] != null ? 'Загружено' : 'Не загружено',
                    style: TextStyle(color: userData!['resumeUrl'] != null ? Colors.green : Colors.red),
                  ),
                  trailing: IconButton(
                    icon: const Icon(Icons.upload_file),
                    onPressed: pickAndUploadResume,
                  ),
                )
              ]),

            const SizedBox(height: 24),
            ElevatedButton.icon(
              icon: const Icon(Icons.logout),
              label: const Text('Выйти'),
              style: ElevatedButton.styleFrom(backgroundColor: Colors.red),
              onPressed: () async {
                await FirebaseAuth.instance.signOut();
                Navigator.pushReplacementNamed(context, '/login');
              },
            )
          ],
        );
      },
    );
  }

  Widget _buildSection(String title, List<Widget> children) {
    return Card(
      margin: const EdgeInsets.only(bottom: 16),
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
      child: Padding(
        padding: const EdgeInsets.symmetric(vertical: 10),
        child: Column(
          children: [
            ListTile(
              title: Text(title, style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 16)),
            ),
            const Divider(),
            ...children,
          ],
        ),
      ),
    );
  }

  Widget _buildField(String title, dynamic value, bool isDarkMode) {
    if (value == null || value.toString().isEmpty) return const SizedBox();
    return ListTile(
      title: Text(title),
      subtitle: Text(
        value.toString(),
        style: TextStyle(color: isDarkMode ? Colors.white70 : Colors.black87),
      ),
    );
  }

  String? formatDate(dynamic timestamp) {
    if (timestamp == null) return null;
    try {
      final date = (timestamp as Timestamp).toDate();
      return DateFormat('dd.MM.yyyy').format(date);
    } catch (_) {
      return null;
    }
  }
}
