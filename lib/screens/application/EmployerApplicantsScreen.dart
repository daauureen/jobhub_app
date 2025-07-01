import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:intl/intl.dart';
import 'package:jobhub_app/screens/application/applicant_detail_screen.dart';
import '../chat/chat_screen.dart';

class EmployerApplicantsScreen extends StatelessWidget {
  const EmployerApplicantsScreen({super.key});

Future<List<Map<String, dynamic>>> fetchApplications() async {
  final currentUser = FirebaseAuth.instance.currentUser!;
  final query = await FirebaseFirestore.instance.collection('applications').get();

  List<Map<String, dynamic>> applications = [];

  for (var doc in query.docs) {
    final data = doc.data();
    data['id'] = doc.id;

    // Загружаем job
    final jobDoc = await FirebaseFirestore.instance
        .collection('jobs')
        .doc(data['jobId'])
        .get();

    if (!jobDoc.exists) continue;

    final jobData = jobDoc.data()!;
    if (jobData['employerId'] != currentUser.uid) continue; // фильтр по владельцу

    final userDoc = await FirebaseFirestore.instance
        .collection('users')
        .doc(data['userId'])
        .get();

    if (!userDoc.exists) continue;

    data['job'] = jobData;
    data['user'] = userDoc.data();
    applications.add(data);
  }

  return applications;
}


  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('Отклики кандидатов')),
      body: FutureBuilder<List<Map<String, dynamic>>>(
        future: fetchApplications(),
        builder: (context, snapshot) {
          if (snapshot.connectionState == ConnectionState.waiting) {
            return const Center(child: CircularProgressIndicator());
          }

          if (!snapshot.hasData || snapshot.data!.isEmpty) {
            return const Center(child: Text('Откликов пока нет'));
          }

          final apps = snapshot.data!;

          return ListView.builder(
            itemCount: apps.length,
            padding: const EdgeInsets.all(12),
            itemBuilder: (context, index) {
              final app = apps[index];
              final user = app['user'];
              final job = app['job'];
              final date = (app['appliedAt'] as Timestamp?)?.toDate();
              final formattedDate = date != null ? DateFormat('dd.MM.yyyy').format(date) : 'Не указано';

              return Card(
                shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
                child: ListTile(
                  leading: CircleAvatar(
                    backgroundImage: user['profileImageUrl'] != null
                        ? NetworkImage(user['profileImageUrl'])
                        : null,
                    child: user['profileImageUrl'] == null
                        ? const Icon(Icons.person)
                        : null,
                  ),
                  title: Text('${user['name'] ?? 'Неизвестно'}'),
                  subtitle: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      const SizedBox(height: 4),
                      Text('Вакансия: ${job['title']}'),
                      Text('Дата отклика: $formattedDate'),
                    ],
                  ),
                  trailing: IconButton(
                    icon: const Icon(Icons.message),
                    onPressed: () async {
                      final currentUser = FirebaseAuth.instance.currentUser!;
                      final otherUserId = app['userId'];
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
                  ),
                  onTap: () {
                    Navigator.push(
    context,
    MaterialPageRoute(
      builder: (_) => ApplicantDetailScreen(application: app),
    ),
  );
                  },
                ),
              );
            },
          );
        },
      ),
    );
  }
}
