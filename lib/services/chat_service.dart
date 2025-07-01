import 'package:cloud_firestore/cloud_firestore.dart';

class ChatService {
  final CollectionReference _chats = FirebaseFirestore.instance.collection('chats');

  // Создать/получить чат по id участников
  Future<String> createOrGetChat(String user1Id, String user2Id) async {
    QuerySnapshot query = await _chats
        .where('participants', arrayContains: user1Id)
        .get();

    for (var doc in query.docs) {
      List participants = doc['participants'];
      if (participants.contains(user2Id)) {
        return doc.id;
      }
    }

    DocumentReference newChat = await _chats.add({
      'participants': [user1Id, user2Id],
      'createdAt': Timestamp.now(),
    });

    return newChat.id;
  }

  // Отправка сообщения
  Future<void> sendMessage(String chatId, String senderId, String text) async {
    await _chats.doc(chatId).collection('messages').add({
      'senderId': senderId,
      'text': text,
      'timestamp': Timestamp.now(),
    });
  }

  // Получение потока сообщений
  Stream<QuerySnapshot> getMessages(String chatId) {
    return _chats
        .doc(chatId)
        .collection('messages')
        .orderBy('timestamp', descending: false)
        .snapshots();
  }

  // Получение списка чатов для пользователя
  Stream<QuerySnapshot> getChatsForUser(String userId) {
    return _chats
        .where('participants', arrayContains: userId)
        .orderBy('createdAt', descending: true)
        .snapshots();
  }
}
