import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';

class CreateJobScreen extends StatefulWidget {
  @override
  _CreateJobScreenState createState() => _CreateJobScreenState();
}

class _CreateJobScreenState extends State<CreateJobScreen> {
  final _titleController = TextEditingController();
  final _descriptionController = TextEditingController();
  final _locationController = TextEditingController();
  final _salaryController = TextEditingController();

  bool _isLoading = false;

void createJob() async {
  if (_titleController.text.isEmpty || _descriptionController.text.isEmpty) {
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(content: Text("Пожалуйста, заполните обязательные поля")),
    );
    return;
  }

  final salaryText = _salaryController.text.trim();
  final salary = double.tryParse(salaryText);
  if (salaryText.isNotEmpty && salary == null) {
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(content: Text("Некорректное значение зарплаты")),
    );
    return;
  }

  setState(() => _isLoading = true);

  try {
    final user = FirebaseAuth.instance.currentUser;
    if (user == null) throw Exception("Пользователь не авторизован");

    // Загружаем профиль пользователя из Firestore
    final userDoc = await FirebaseFirestore.instance
        .collection('users')
        .doc(user.uid)
        .get();

    final userData = userDoc.data();
    final companyName = userData?['companyName'] ?? '';

    await FirebaseFirestore.instance.collection('jobs').add({
      'title': _titleController.text.trim(),
      'description': _descriptionController.text.trim(),
      'location': _locationController.text.trim(),
      'salary': salary,
      'employerId': user.uid,
      'company': companyName,
      'requirements': [],
      'createdAt': FieldValue.serverTimestamp(),
    });

    if (context.mounted) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text("Вакансия успешно опубликована")),
      );
      Navigator.pushReplacementNamed(context, '/employer_home');
    }
  } catch (e) {
    print('❌ Ошибка при публикации: $e');
    if (context.mounted) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text("Ошибка при публикации")),
      );
    }
  } finally {
    if (mounted) setState(() => _isLoading = false);
  }
}


  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: Text('Создать вакансию')),
      body: Padding(
        padding: const EdgeInsets.all(20),
        child: Column(
          children: [
            TextField(controller: _titleController, decoration: InputDecoration(labelText: 'Название *')),
            TextField(controller: _descriptionController, decoration: InputDecoration(labelText: 'Описание *')),
            TextField(controller: _locationController, decoration: InputDecoration(labelText: 'Локация')),
            TextField(controller: _salaryController, decoration: InputDecoration(labelText: 'Зарплата')),
            SizedBox(height: 20),
            _isLoading
                ? CircularProgressIndicator()
                : ElevatedButton(onPressed: createJob, child: Text('Опубликовать')),
          ],
        ),
      ),
    );
  }
}
