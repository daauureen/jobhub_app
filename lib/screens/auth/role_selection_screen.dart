import 'package:flutter/material.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:cloud_firestore/cloud_firestore.dart';

class RoleSelectionScreen extends StatelessWidget {
  Future<void> _setRole(BuildContext context, String role) async {
    final user = FirebaseAuth.instance.currentUser;
    if (user == null) return;

    try {
      await FirebaseFirestore.instance.collection('users').doc(user.uid).update({'role': role});
      if (role == 'jobseeker') {
        Navigator.pushReplacementNamed(context, '/jobseeker_home');
      } else {
        Navigator.pushReplacementNamed(context, '/employer_home');
      }
    } catch (e) {
      print("Ошибка при установке роли: $e");
      ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text("Не удалось установить роль")));
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: Text('Выбор роли')),
      body: Padding(
        padding: const EdgeInsets.all(20),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Text(
              'Кем вы являетесь?',
              style: TextStyle(fontSize: 20, fontWeight: FontWeight.bold),
            ),
            SizedBox(height: 30),
            ElevatedButton.icon(
              onPressed: () => _setRole(context, 'jobseeker'),
              icon: Icon(Icons.person),
              label: Text('Соискатель'),
              style: ElevatedButton.styleFrom(minimumSize: Size.fromHeight(50)),
            ),
            SizedBox(height: 20),
            ElevatedButton.icon(
              onPressed: () => _setRole(context, 'employer'),
              icon: Icon(Icons.business),
              label: Text('Работодатель'),
              style: ElevatedButton.styleFrom(minimumSize: Size.fromHeight(50)),
            ),
          ],
        ),
      ),
    );
  }
}
