import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'edit_job_screen.dart';
import 'package:intl/intl.dart';

class JobDetailScreen extends StatelessWidget {
  final String jobId;

  const JobDetailScreen({required this.jobId, Key? key}) : super(key: key);

  Future<Map<String, dynamic>?> fetchJobData() async {
    final doc = await FirebaseFirestore.instance.collection('jobs').doc(jobId).get();
    return doc.exists ? doc.data() : null;
  }

  void applyForJob(BuildContext context, String jobId) async {
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
    final currentUser = FirebaseAuth.instance.currentUser;

    return Scaffold(
      appBar: AppBar(
        title: const Text('Вакансия'),
        actions: [
          FutureBuilder<Map<String, dynamic>?>(
            future: fetchJobData(),
            builder: (context, snapshot) {
              if (snapshot.hasData && snapshot.data?['employerId'] == currentUser?.uid) {
                return IconButton(
                  icon: const Icon(Icons.edit),
                  onPressed: () {
                    Navigator.push(
                      context,
                      MaterialPageRoute(
                        builder: (_) => EditJobScreen(jobId: jobId),
                      ),
                    );
                  },
                );
              }
              return const SizedBox.shrink();
            },
          )
        ],
      ),
      body: FutureBuilder<Map<String, dynamic>?>(
        future: fetchJobData(),
        builder: (context, snapshot) {
          if (snapshot.connectionState == ConnectionState.waiting)
            return const Center(child: CircularProgressIndicator());

          if (!snapshot.hasData || snapshot.data == null)
            return const Center(child: Text('Вакансия не найдена'));

          final jobData = snapshot.data!;
          final isOwner = jobData['employerId'] == currentUser?.uid;
          final date = jobData['createdAt'] != null
              ? (jobData['createdAt'] as Timestamp).toDate()
              : null;

          return SingleChildScrollView(
            padding: const EdgeInsets.all(24),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                // 🧾 Заголовок
                Text(
                  jobData['title'] ?? 'Без названия',
                  style: const TextStyle(fontSize: 26, fontWeight: FontWeight.bold),
                ),
                const SizedBox(height: 6),
                Text(
                  jobData['company'] ?? 'Компания не указана',
                  style: const TextStyle(fontSize: 18, color: Colors.grey),
                ),
                const SizedBox(height: 12),

                // 💰 Зарплата и Локация
                Row(
                  children: [
                    Icon(Icons.work_outline, color: Colors.green[800]),
                    const SizedBox(width: 6),
                    Text(
                      jobData['salary'] != null ?'${jobData['salary']} ₸' : 'Зарплата не указана',
                      style: const TextStyle(fontSize: 16),
                    ),
                    const SizedBox(width: 20),
                    Icon(Icons.location_on_outlined, color: Colors.blueGrey),
                    const SizedBox(width: 6),
                    Text(
                      jobData['location'] ?? 'Локация не указана',
                      style: const TextStyle(fontSize: 16),
                    ),
                  ],
                ),

                const SizedBox(height: 16),

                // 📅 Дата публикации
                if (date != null)
                  Text(
                    'Опубликовано: ${DateFormat('dd.MM.yyyy').format(date)}',
                    style: const TextStyle(color: Colors.grey),
                  ),

                const SizedBox(height: 20),

                // 📝 Описание
                const Text('Описание', style: TextStyle(fontSize: 20, fontWeight: FontWeight.bold)),
                const SizedBox(height: 8),
                Text(
                  jobData['description'] ?? 'Описание отсутствует',
                  style: const TextStyle(fontSize: 16),
                ),

                const SizedBox(height: 24),

                // ✅ Требования
                if (jobData['requirements'] != null &&
                    jobData['requirements'] is List &&
                    (jobData['requirements'] as List).isNotEmpty)
                  Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      const Text('Требования', style: TextStyle(fontSize: 20, fontWeight: FontWeight.bold)),
                      const SizedBox(height: 8),
                      ...List<String>.from(jobData['requirements']).map(
                        (req) => Padding(
                          padding: const EdgeInsets.only(bottom: 6),
                          child: Row(
                            children: [
                              const Icon(Icons.check, size: 18, color: Colors.green),
                              const SizedBox(width: 8),
                              Expanded(child: Text(req, style: const TextStyle(fontSize: 16))),
                            ],
                          ),
                        ),
                      ),
                    ],
                  ),

                const SizedBox(height: 40),

                // 📩 Кнопка отклика
                if (!isOwner)
                  Center(
                    child: ElevatedButton.icon(
                      onPressed: () => applyForJob(context, jobId),
                      icon: const Icon(Icons.send),
                      label: const Text('Откликнуться'),
                      style: ElevatedButton.styleFrom(
                        padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 14),
                        textStyle: const TextStyle(fontSize: 16),
                      ),
                    ),
                  ),
              ],
            ),
          );
        },
      ),
    );
  }
}
