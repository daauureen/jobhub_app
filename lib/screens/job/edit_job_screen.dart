import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';

class EditJobScreen extends StatefulWidget {
  final String jobId;

  const EditJobScreen({required this.jobId});

  @override
  _EditJobScreenState createState() => _EditJobScreenState();
}

class _EditJobScreenState extends State<EditJobScreen> {
  final _titleController = TextEditingController();
  final _descriptionController = TextEditingController();
  final _locationController = TextEditingController();
  final _salaryController = TextEditingController();
  bool _isLoading = true;

  @override
  void initState() {
    super.initState();
    _loadJobData();
  }

  Future<void> _loadJobData() async {
    final doc = await FirebaseFirestore.instance.collection('jobs').doc(widget.jobId).get();
    final data = doc.data()!;
    setState(() {
      _titleController.text = data['title'] ?? '';
      _descriptionController.text = data['description'] ?? '';
      _locationController.text = data['location'] ?? '';
      _salaryController.text = (data['salary'] ?? '').toString();
      _isLoading = false;
    });
  }

  void _updateJob() async {
    await FirebaseFirestore.instance.collection('jobs').doc(widget.jobId).update({
      'title': _titleController.text.trim(),
      'description': _descriptionController.text.trim(),
      'location': _locationController.text.trim(),
      'salary': double.tryParse(_salaryController.text.trim()),
    });

    ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text("Вакансия обновлена")));
    Navigator.pop(context);
  }

  @override
  Widget build(BuildContext context) {
    if (_isLoading) return Scaffold(body: Center(child: CircularProgressIndicator()));

    return Scaffold(
      appBar: AppBar(title: Text('Редактировать вакансию')),
      body: Padding(
        padding: const EdgeInsets.all(20),
        child: Column(
          children: [
            TextField(controller: _titleController, decoration: InputDecoration(labelText: 'Название')),
            TextField(controller: _descriptionController, decoration: InputDecoration(labelText: 'Описание')),
            TextField(controller: _locationController, decoration: InputDecoration(labelText: 'Локация')),
            TextField(controller: _salaryController, decoration: InputDecoration(labelText: 'Зарплата')),
            SizedBox(height: 20),
            ElevatedButton(onPressed: _updateJob, child: Text('Сохранить')),
          ],
        ),
      ),
    );
  }
}
