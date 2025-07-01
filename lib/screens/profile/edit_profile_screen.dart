import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';

class EditProfileScreen extends StatefulWidget {
  @override
  _EditProfileScreenState createState() => _EditProfileScreenState();
}

class _EditProfileScreenState extends State<EditProfileScreen> {
  final _formKey = GlobalKey<FormState>();

  final TextEditingController _nameController = TextEditingController();
  final TextEditingController _phoneController = TextEditingController();
  final TextEditingController _bioController = TextEditingController();
  final TextEditingController _companyNameController = TextEditingController();
  final TextEditingController _contactPersonController = TextEditingController();
  final TextEditingController _addressController = TextEditingController();
  final TextEditingController _companyDescriptionController = TextEditingController();
  final TextEditingController _websiteController = TextEditingController();

  bool isEmployer = false;

  @override
  void initState() {
    super.initState();
    _loadUserData();
  }

  Future<void> _loadUserData() async {
    final user = FirebaseAuth.instance.currentUser;
    if (user == null) return;

    final doc = await FirebaseFirestore.instance.collection('users').doc(user.uid).get();
    final data = doc.data();
    if (data != null) {
      setState(() {
        isEmployer = data['role'] == 'employer';
        _nameController.text = data['name'] ?? '';
        _phoneController.text = data['phone'] ?? '';
        _bioController.text = data['bio'] ?? '';
        _companyNameController.text = data['companyName'] ?? '';
        _contactPersonController.text = data['contactPerson'] ?? '';
        _addressController.text = data['address'] ?? '';
        _companyDescriptionController.text = data['companyDescription'] ?? '';
        _websiteController.text = data['website'] ?? '';
      });
    }
  }

  Future<void> _saveProfile() async {
    if (!_formKey.currentState!.validate()) return;

    final user = FirebaseAuth.instance.currentUser;
    if (user == null) return;

    final dataToUpdate = {
      'name': _nameController.text.trim(),
      'phone': _phoneController.text.trim(),
      'bio': _bioController.text.trim(),
    };

    if (isEmployer) {
      dataToUpdate.addAll({
        'companyName': _companyNameController.text.trim(),
        'contactPerson': _contactPersonController.text.trim(),
        'address': _addressController.text.trim(),
        'companyDescription': _companyDescriptionController.text.trim(),
        'website': _websiteController.text.trim(),
      });
    }

    await FirebaseFirestore.instance.collection('users').doc(user.uid).update(dataToUpdate);

    ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text('Профиль обновлён')));
    Navigator.pop(context);
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: Text('Редактировать профиль')),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(20),
        child: Form(
          key: _formKey,
          child: Column(
            children: [
              TextFormField(controller: _nameController, decoration: InputDecoration(labelText: 'Имя')),
              TextFormField(controller: _phoneController, decoration: InputDecoration(labelText: 'Телефон')),
              TextFormField(controller: _bioController, decoration: InputDecoration(labelText: 'О себе')),
              if (isEmployer) ...[
                const Divider(height: 30),
                TextFormField(controller: _companyNameController, decoration: InputDecoration(labelText: 'Название компании')),
                TextFormField(controller: _contactPersonController, decoration: InputDecoration(labelText: 'Контактное лицо')),
                TextFormField(controller: _addressController, decoration: InputDecoration(labelText: 'Адрес')),
                TextFormField(controller: _companyDescriptionController, decoration: InputDecoration(labelText: 'Описание компании')),
                TextFormField(controller: _websiteController, decoration: InputDecoration(labelText: 'Сайт')),
              ],
              const SizedBox(height: 20),
              ElevatedButton(onPressed: _saveProfile, child: Text('Сохранить')),
            ],
          ),
        ),
      ),
    );
  }
}
