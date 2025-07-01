import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:intl/intl.dart';
import 'package:firebase_auth/firebase_auth.dart';

class JobListScreen extends StatefulWidget {
  @override
  _JobListScreenState createState() => _JobListScreenState();
}

class _JobListScreenState extends State<JobListScreen> {
  final TextEditingController _searchController = TextEditingController();
  String _searchQuery = '';
  String _selectedLocation = '';
  double? _minSalary;
  bool _onlyWithSalary = false;
  
 void _openFilterDialog() {
  final _locationController = TextEditingController(text: _selectedLocation);
  final _salaryController = TextEditingController(text: _minSalary?.toString() ?? '');

  showDialog(
    context: context,
    barrierDismissible: true,
    builder: (context) {
      return AlertDialog(
        title: const Text('Фильтр вакансий'),
        content: SingleChildScrollView(
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              TextField(
                controller: _locationController,
                decoration: const InputDecoration(
                  labelText: 'Город',
                  prefixIcon: Icon(Icons.location_on_outlined),
                ),
              ),
              const SizedBox(height: 12),
              TextField(
                controller: _salaryController,
                decoration: const InputDecoration(
                  labelText: 'Минимальная зарплата',
                  prefixIcon: Icon(Icons.monetization_on_outlined),
                ),
                keyboardType: TextInputType.number,
              ),
              const SizedBox(height: 12),
              CheckboxListTile(
                value: _onlyWithSalary,
                onChanged: (value) {
                  setState(() => _onlyWithSalary = value ?? false);
                },
                title: const Text('Только с зарплатой'),
                controlAffinity: ListTileControlAffinity.leading,
                contentPadding: EdgeInsets.zero,
              ),
            ],
          ),
        ),
        actions: [
          TextButton(
            onPressed: () {
              setState(() {
                _selectedLocation = '';
                _minSalary = null;
                _onlyWithSalary = false;
              });
              Navigator.pop(context);
            },
            child: const Text('Сбросить'),
          ),
          ElevatedButton(
            onPressed: () {
              setState(() {
                _selectedLocation = _locationController.text.trim().toLowerCase();
                _minSalary = double.tryParse(_salaryController.text.trim());
              });
              Navigator.pop(context);
            },
            child: const Text('Применить'),
          ),
        ],
      );
    },
  );
}

  void applyForJob(String jobId) async {
    final user = FirebaseAuth.instance.currentUser;
    if (user == null) return;

    final applicationRef = FirebaseFirestore.instance.collection('applications');

    final existing = await applicationRef
        .where('jobId', isEqualTo: jobId)
        .where('userId', isEqualTo: user.uid)
        .get();

    if (existing.docs.isNotEmpty) {
      ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text('Вы уже откликались')));
      return;
    }

    await applicationRef.add({
      'jobId': jobId,
      'userId': user.uid,
      'appliedAt': Timestamp.now(),
    });

    ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text('Отклик отправлен')));
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: PreferredSize(
        preferredSize: const Size.fromHeight(70),
        child: Container(
          padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 10),
          decoration: BoxDecoration(
            color: Colors.grey[100],
            borderRadius: const BorderRadius.vertical(
              bottom: Radius.circular(20),
            ),
            boxShadow: [
              BoxShadow(
                color: Colors.black12,
                blurRadius: 8,
                offset: Offset(0, 2),
              ),
            ],
          ),
          child: SafeArea(
            child: Row(
              children: [
                Expanded(
                  child: Container(
                    padding: const EdgeInsets.symmetric(horizontal: 12),
                    decoration: BoxDecoration(
                      color: Colors.white,
                      borderRadius: BorderRadius.circular(12),
                      border: Border.all(color: Colors.grey.shade300),
                    ),
                    child: TextField(
                      controller: _searchController,
                      onChanged: (value) {
                        setState(() {
                          _searchQuery = value.toLowerCase();
                        });
                      },
                      decoration: const InputDecoration(
                        icon: Icon(Icons.search, color: Colors.grey),
                        hintText: 'Поиск вакансий...',
                        border: InputBorder.none,
                      ),
                    ),
                  ),
                ),
                const SizedBox(width: 10),
                IconButton(
                  icon: const Icon(Icons.filter_list, color: Colors.black87),
                  onPressed: () {
                    _openFilterDialog();
                  },
                )
              ],
            ),
          ),
        ),
      ),
      body: StreamBuilder<QuerySnapshot>(
        stream: FirebaseFirestore.instance.collection('jobs').orderBy('createdAt', descending: true).snapshots(),
        builder: (context, snapshot) {
          if (snapshot.connectionState == ConnectionState.waiting) return const Center(child: CircularProgressIndicator());
          if (!snapshot.hasData || snapshot.data!.docs.isEmpty) return const Center(child: Text('Вакансии не найдены'));

          final filtered = snapshot.data!.docs.where((doc) {
  final data = doc.data() as Map<String, dynamic>;
  final title = (data['title'] ?? '').toString().toLowerCase();
  final location = (data['location'] ?? '').toString().toLowerCase();
  final salary = data['salary'];

  final matchesSearch = title.contains(_searchQuery);
  final matchesLocation = _selectedLocation.isEmpty || location.contains(_selectedLocation);
  final matchesSalary = _minSalary == null || (salary is num && salary >= _minSalary!);
  final hasSalary = !_onlyWithSalary || (salary is num && salary > 0);

  return matchesSearch && matchesLocation && matchesSalary && hasSalary;
}).toList();


          return ListView.builder(
            itemCount: filtered.length,
            padding: const EdgeInsets.all(12),
            itemBuilder: (context, index) {
              final doc = filtered[index];
              final data = doc.data() as Map<String, dynamic>;

              final title = data['title'] ?? 'Без названия';
              final salary = data['salary'] != null ? '${data['salary']} ₸' : 'Зарплата не указана';
              final company = data['company'] ?? 'Компания не указана';
              final location = data['location'] ?? 'Локация не указана';
              final timestamp = data['createdAt'];
              final createdAt = timestamp is Timestamp
                  ? DateFormat('dd.MM.yyyy').format(timestamp.toDate())
                  : 'Дата не указана';

              return InkWell(
                onTap: () {
                  Navigator.pushNamed(context, '/job_detail', arguments: doc.id);
                },
                child: Card(
                  shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
                  elevation: 4,
                  margin: const EdgeInsets.symmetric(vertical: 8),
                  child: Padding(
                    padding: const EdgeInsets.all(16),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(title, style: const TextStyle(fontSize: 18, fontWeight: FontWeight.bold)),
                        const SizedBox(height: 4),
                        Text(company, style: const TextStyle(color: Colors.black54)),
                        const SizedBox(height: 4),
                        Row(
                          children: [
                            Icon(Icons.location_on, size: 16, color: Colors.grey),
                            const SizedBox(width: 4),
                            Text(location),
                          ],
                        ),
                        const SizedBox(height: 4),
                        Row(
                          children: [
                            Icon(Icons.calendar_today, size: 16, color: Colors.grey),
                            const SizedBox(width: 4),
                            Text('Опубликовано: $createdAt'),
                          ],
                        ),
                        const SizedBox(height: 4),
                        Row(
                          children: [
                            Icon(Icons.monetization_on, size: 16, color: Colors.grey),
                            const SizedBox(width: 4),
                            Text(salary),
                          ],
                        ),
                        const SizedBox(height: 12),
                        Align(
                          alignment: Alignment.centerRight,
                          child: ElevatedButton(
                            onPressed: () => applyForJob(doc.id),
                            child: const Text('Откликнуться'),
                          ),
                        ),
                      ],
                    ),
                  ),
                ),
              );
            },
          );
        },
      ),
    );
  }
}
