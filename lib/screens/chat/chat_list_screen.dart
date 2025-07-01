import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'chat_screen.dart';

class ChatListScreen extends StatelessWidget {
  const ChatListScreen({super.key});

  @override
  Widget build(BuildContext context) {
    final currentUser = FirebaseAuth.instance.currentUser!;
    final chatsRef = FirebaseFirestore.instance
        .collection('chats')
        .where('participants', arrayContains: currentUser.uid)
        .orderBy('lastMessageTime', descending: true);

    return Scaffold(
      appBar: AppBar(title: const Text('Мои чаты')),
      body: StreamBuilder<QuerySnapshot>(
        stream: chatsRef.snapshots(),
        builder: (context, snapshot) {
          if (snapshot.connectionState == ConnectionState.waiting) {
            return _buildLoadingList();
          }

          if (!snapshot.hasData || snapshot.data!.docs.isEmpty) {
            return const Center(child: Text('Нет активных чатов'));
          }

          final chats = snapshot.data!.docs;

          return ListView.builder(
            itemCount: chats.length,
            itemBuilder: (context, index) {
              final chat = chats[index];
              final data = chat.data() as Map<String, dynamic>;

              final List<dynamic> participants = data['participants'] ?? [];
              final Map<String, dynamic> participantNames =
                  Map<String, dynamic>.from(data['participantNames'] ?? {});

              if (participants.length < 2) return const SizedBox();

              // Найти ID другого пользователя
              final otherUserId = participants.firstWhere(
                (id) => id != currentUser.uid,
                orElse: () => null,
              );

              // Проверка на null и тип
              if (otherUserId == null || otherUserId is! String) {
                return const SizedBox(); // Пропустить некорректный чат
              }

              final otherUserName = participantNames[otherUserId] ?? 'Собеседник';
              final lastMessage = data['lastMessage'] ?? '';

              return ListTile(
                leading: const CircleAvatar(child: Icon(Icons.person)),
                title: Text(otherUserName),
                subtitle: Text(
                  lastMessage,
                  maxLines: 1,
                  overflow: TextOverflow.ellipsis,
                ),
                trailing: const Icon(Icons.arrow_forward_ios, size: 16),
                onTap: () {
                  Navigator.push(
                    context,
                    MaterialPageRoute(
                      builder: (_) => ChatScreen(chatId: chat.id),
                    ),
                  );
                },
              );
            },
          );
        },
      ),
    );
  }

  Widget _buildLoadingList() {
    return ListView.builder(
      itemCount: 4,
      itemBuilder: (context, index) => const ListTile(
        leading: CircleAvatar(backgroundColor: Colors.grey),
        title: SizedBox(
          height: 14,
          width: 100,
          child: DecoratedBox(
            decoration: BoxDecoration(color: Colors.grey, borderRadius: BorderRadius.all(Radius.circular(4))),
          ),
        ),
        subtitle: SizedBox(
          height: 12,
          width: 150,
          child: DecoratedBox(
            decoration: BoxDecoration(color: Colors.grey, borderRadius: BorderRadius.all(Radius.circular(4))),
          ),
        ),
      ),
    );
  }
}
