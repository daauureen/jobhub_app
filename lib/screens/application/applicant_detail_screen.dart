import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import '../chat/chat_screen.dart';

class ApplicantDetailScreen extends StatelessWidget {
  final Map<String, dynamic> application;

  const ApplicantDetailScreen({super.key, required this.application});

  @override
  Widget build(BuildContext context) {
    final user = application['user'];
    final job = application['job'];

    return Scaffold(
      appBar: AppBar(title: const Text('Информация о кандидате')),
      body: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Center(
              child: CircleAvatar(
                radius: 50,
                backgroundImage: user['profileImageUrl'] != null ? NetworkImage(user['profileImageUrl']) : null,
                child: user['profileImageUrl'] == null ? const Icon(Icons.person, size: 50) : null,
              ),
            ),
            const SizedBox(height: 16),
            Text('Имя: ${user['name'] ?? '-'}', style: const TextStyle(fontSize: 18)),
            Text('Телефон: ${user['phone'] ?? '-'}'),
            Text('Email: ${user['email'] ?? '-'}'),
            Text('О себе: ${user['bio'] ?? '-'}'),
            const SizedBox(height: 16),
            const Divider(),
            Text('Вакансия: ${job['title'] ?? '-'}', style: const TextStyle(fontWeight: FontWeight.bold)),
            Text('Компания: ${job['company'] ?? '-'}'),
            Text('Локация: ${job['location'] ?? '-'}'),
            Text('Зарплата: ${job['salary']?.toString() ?? '-'} ₸'),
            const Spacer(),
            ElevatedButton.icon(
              icon: const Icon(Icons.message),
              label: const Text('Написать сообщение'),
              onPressed: () async {
                final currentUser = FirebaseAuth.instance.currentUser!;
                final otherUserId = application['userId'];
                final chatsRef = FirebaseFirestore.instance.collection('chats');

                final existingChat = await chatsRef
                    .where('participants', arrayContains: currentUser.uid)
                    .get();

                String? existingChatId;

                for (var doc in existingChat.docs) {
                  final participants = doc['participants'];
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
                      otherUserId: user['name'] ?? 'Кандидат',
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
              },
            )
          ],
        ),
      ),
    );
  }
}
