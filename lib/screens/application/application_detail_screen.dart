import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:intl/intl.dart';
import 'package:jobhub_app/screens/chat/chat_screen.dart';

class ApplicationDetailScreen extends StatelessWidget {
  final String applicationId;

  const ApplicationDetailScreen({super.key, required this.applicationId});

  Future<Map<String, dynamic>?> fetchApplicationData() async {
    final doc = await FirebaseFirestore.instance
        .collection('applications')
        .doc(applicationId)
        .get();

    if (!doc.exists) return null;

    final data = doc.data()!;
    data['id'] = doc.id;

    // Загружаем вакансию
    if (data['jobId'] != null) {
      final jobSnap = await FirebaseFirestore.instance.collection('jobs').doc(data['jobId']).get();
      if (jobSnap.exists) data['job'] = jobSnap.data();
    }

    // Загружаем пользователя
    if (data['userId'] != null) {
      final userSnap = await FirebaseFirestore.instance.collection('users').doc(data['userId']).get();
      if (userSnap.exists) data['user'] = userSnap.data();
    }

    return data;
  }

  @override
  Widget build(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;

    return Scaffold(
      appBar: AppBar(title: const Text('Детали отклика')),
      body: FutureBuilder<Map<String, dynamic>?>(
        future: fetchApplicationData(),
        builder: (context, snapshot) {
          if (snapshot.connectionState == ConnectionState.waiting) return const Center(child: CircularProgressIndicator());
          if (!snapshot.hasData || snapshot.data == null) return const Center(child: Text('Отклик не найден'));

          final data = snapshot.data!;
          final job = data['job'] ?? {};
          final user = data['user'] ?? {};
          final appliedAt = data['appliedAt'] != null
              ? DateFormat('dd.MM.yyyy').format((data['appliedAt'] as Timestamp).toDate())
              : 'Не указано';

          return ListView(
            padding: const EdgeInsets.all(16),
            children: [
              _buildSection('Вакансия', [
                _buildTile('Название', job['title']),
                _buildTile('Компания', job['company']),
                _buildTile('Локация', job['location']),
                _buildTile('Зарплата', job['salary']?.toString()),
              ]),
              const SizedBox(height: 12),
              _buildSection('Соискатель', [
                _buildTile('Имя', user['name']),
                _buildTile('Email', user['email']),
                _buildTile('Телефон', user['phone']),
                _buildTile('О себе', user['bio']),
              ]),
              const SizedBox(height: 12),
              _buildSection('Отклик', [
                _buildTile('Дата отклика', appliedAt),
                _buildTile('Статус', data['status'] ?? 'На рассмотрении'),
              ]),
              const SizedBox(height: 24),
              ElevatedButton.icon(
                icon: const Icon(Icons.message),
                label: const Text('Написать сообщение'),
                onPressed: () async {
  final currentUser = FirebaseAuth.instance.currentUser!;
  final employerId = data['job']?['employerId'];
  final isEmployer = employerId == currentUser.uid;
  final otherUserId = isEmployer ? data['userId'] : employerId;

  if (otherUserId == null || otherUserId == currentUser.uid) {
    ScaffoldMessenger.of(context).showSnackBar(
      const SnackBar(content: Text('Ошибка: некорректный получатель')),
    );
    return;
  }

  final otherUserName = isEmployer
      ? (user['name'] ?? 'Соискатель')
      : (job['company'] ?? 'Компания');

  final chatsRef = FirebaseFirestore.instance.collection('chats');
  final existingChatQuery = await chatsRef
      .where('participants', arrayContains: currentUser.uid)
      .get();

  String? existingChatId;

  for (var doc in existingChatQuery.docs) {
    final participants = List.from(doc['participants']);
    if (participants.contains(otherUserId)) {
      existingChatId = doc.id;
      break;
    }
  }

  if (existingChatId == null) {
    final chatDoc = await chatsRef.add({
      'participants': [currentUser.uid, otherUserId],
      'participantNames': {
        currentUser.uid: currentUser.displayName ?? 'Вы',
        otherUserId: otherUserName,
      },
      'lastMessage': '',
      'lastMessageTime': FieldValue.serverTimestamp(),
    });
    existingChatId = chatDoc.id;
  }

  Navigator.push(
    context,
    MaterialPageRoute(
      builder: (_) => ChatScreen(chatId: existingChatId!),
    ),
  );
}

              ),
            ],
          );
        },
      ),
    );
  }

  Widget _buildSection(String title, List<Widget> tiles) {
    return Card(
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
      child: Padding(
        padding: const EdgeInsets.symmetric(vertical: 10),
        child: Column(
          children: [
            ListTile(title: Text(title, style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 16))),
            const Divider(),
            ...tiles,
          ],
        ),
      ),
    );
  }

  Widget _buildTile(String label, String? value) {
    if (value == null || value.isEmpty) return const SizedBox();
    return ListTile(
      title: Text(label),
      subtitle: Text(value),
    );
  }
}
