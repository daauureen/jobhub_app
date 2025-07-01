import 'package:cloud_firestore/cloud_firestore.dart';
import '../models/user_model.dart';

class UserService {
  final CollectionReference _users = FirebaseFirestore.instance.collection('users');

  // Получение пользователя по id
  Future<UserModel?> getUserById(String uid) async {
    try {
      DocumentSnapshot doc = await _users.doc(uid).get();
      if (doc.exists) {
        return UserModel.fromMap(doc.data() as Map<String, dynamic>, doc.id);
      }
      return null;
    } catch (e) {
      print('Ошибка при получении пользователя: $e');
      return null;
    }
  }

  // Обновление данных пользователя
  Future<void> updateUser(UserModel user) async {
    try {
      await _users.doc(user.uid).update(user.toMap());
    } catch (e) {
      print('Ошибка при обновлении пользователя: $e');
    }
  }

  // Получение всех пользователей с ролью 'jobseeker' (для работодателя)
  Stream<List<UserModel>> getJobSeekers() {
    return _users
        .where('role', isEqualTo: 'jobseeker')
        .snapshots()
        .map((snapshot) => snapshot.docs
            .map((doc) => UserModel.fromMap(doc.data() as Map<String, dynamic>, doc.id))
            .toList());
  }

  // Получение всех пользователей с ролью 'employer' (по аналогии, если нужно)
  Stream<List<UserModel>> getEmployers() {
    return _users
        .where('role', isEqualTo: 'employer')
        .snapshots()
        .map((snapshot) => snapshot.docs
            .map((doc) => UserModel.fromMap(doc.data() as Map<String, dynamic>, doc.id))
            .toList());
  }
}
