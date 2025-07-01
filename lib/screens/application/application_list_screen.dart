import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:intl/intl.dart';
import 'application_detail_screen.dart';

class ApplicationListScreen extends StatelessWidget {
  final bool isEmployer;

  const ApplicationListScreen({super.key, this.isEmployer = false});

  Future<List<Map<String, dynamic>>> fetchApplications() async {
    final currentUser = FirebaseAuth.instance.currentUser!;
    final appsQuery = await FirebaseFirestore.instance
        .collection('applications')
        .where(isEmployer ? 'employerId' : 'userId', isEqualTo: currentUser.uid)
        .get();

    final List<Map<String, dynamic>> results = [];

    for (var doc in appsQuery.docs) {
      final data = doc.data();
      data['id'] = doc.id;

      // Получаем вакансию
      if (data['jobId'] != null) {
        final jobDoc = await FirebaseFirestore.instance.collection('jobs').doc(data['jobId']).get();
        if (jobDoc.exists) {
          final jobData = jobDoc.data();
          if (jobData != null) {
            data['title'] = jobData['title'];
          }
        }
      }

      results.add(data);
    }

    return results;
  }

  @override
  Widget build(BuildContext context) {
    final isDarkMode = Theme.of(context).brightness == Brightness.dark;

    return Scaffold(
      appBar: AppBar(
        title: Text(isEmployer ? 'Отклики на вакансии' : 'Мои отклики'),
      ),
      body: FutureBuilder<List<Map<String, dynamic>>>(
        future: fetchApplications(),
        builder: (context, snapshot) {
          if (snapshot.connectionState == ConnectionState.waiting) {
            return const Center(child: CircularProgressIndicator());
          }

          if (!snapshot.hasData || snapshot.data!.isEmpty) {
            return const Center(child: Text('Нет откликов'));
          }

          final applications = snapshot.data!;

          return ListView.builder(
            padding: const EdgeInsets.all(12),
            itemCount: applications.length,
            itemBuilder: (context, index) {
              final data = applications[index];

              final applicantName = data['applicantName'] ?? 'Имя не указано';
              final status = data['status'] ?? 'Ожидает';
              final jobTitle = data['title'] ?? 'Без названия';
              final timestamp = data['appliedAt'] as Timestamp?;
              final appliedAt = timestamp != null
                  ? DateFormat('dd.MM.yyyy').format(timestamp.toDate())
                  : 'Неизвестно';

              return Card(
                shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
                elevation: 2,
                child: ListTile(
                  contentPadding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
                  leading: Icon(Icons.work_outline, color: isDarkMode ? Colors.white70 : Colors.black54),
                  title: Text(
                    isEmployer ? applicantName : jobTitle,
                    style: const TextStyle(fontWeight: FontWeight.w600),
                  ),
                  subtitle: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      const SizedBox(height: 4),
                      Text('Статус: $status'),
                      Text('Дата отклика: $appliedAt'),
                    ],
                  ),
                  trailing: const Icon(Icons.arrow_forward_ios, size: 16),
                  onTap: () {
                    Navigator.push(
                      context,
                      MaterialPageRoute(
                        builder: (_) => ApplicationDetailScreen(applicationId: data['id']),
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
