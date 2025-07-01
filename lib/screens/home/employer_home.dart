// Весь код EmployerHomeScreen со всеми исправлениями

import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:jobhub_app/models/job_model.dart';
import 'package:jobhub_app/screens/application/application_list_screen.dart';
import 'package:jobhub_app/screens/chat/chat_list_screen.dart';
import 'package:jobhub_app/screens/job/create_job_screen.dart';
import 'package:jobhub_app/screens/job/job_detail_screen.dart';
import 'package:jobhub_app/screens/profile/view_profile_screen.dart';
import 'package:jobhub_app/services/job_service.dart';
import 'package:jobhub_app/screens/application/EmployerApplicantsScreen.dart';

class EmployerHomeScreen extends StatefulWidget {
  const EmployerHomeScreen({Key? key}) : super(key: key);

  @override
  State<EmployerHomeScreen> createState() => _EmployerHomeScreenState();
}

class _EmployerHomeScreenState extends State<EmployerHomeScreen> {
  int _selectedIndex = 0;
  final JobService _jobService = JobService();
  final user = FirebaseAuth.instance.currentUser!;
  String _searchQuery = '';
  String _locationFilter = '';
  double? _minSalary;

  @override
  Widget build(BuildContext context) {
    final screens = [
      _buildJobList(),
      const EmployerApplicantsScreen(),
      const ChatListScreen(),
      const ViewProfileScreen(isEmployer: true),
    ];

    return SafeArea(
      child: Scaffold(
        body: IndexedStack(index: _selectedIndex, children: screens),
        bottomNavigationBar: BottomNavigationBar(
          currentIndex: _selectedIndex,
          onTap: (index) => setState(() => _selectedIndex = index),
          type: BottomNavigationBarType.fixed,
          items: const [
            BottomNavigationBarItem(icon: Icon(Icons.work), label: 'Вакансии'),
            BottomNavigationBarItem(icon: Icon(Icons.check_circle_outline), label: 'Отклики'),
            BottomNavigationBarItem(icon: Icon(Icons.chat_bubble_outline), label: 'Чаты'),
            BottomNavigationBarItem(icon: Icon(Icons.person_outline), label: 'Профиль'),
          ],
        ),
        floatingActionButton: _selectedIndex == 0
            ? FloatingActionButton(
                onPressed: () {
                  Navigator.push(context, MaterialPageRoute(builder: (_) => CreateJobScreen()));
                },
                child: const Icon(Icons.add),
              )
            : null,
      ),
    );
  }

  Widget _buildJobList() {
    return Column(
      children: [
        Padding(
          padding: const EdgeInsets.all(12),
          child: Row(
            children: [
              Expanded(
                child: TextField(
                  decoration: const InputDecoration(
                    hintText: 'Поиск вакансий...',
                    prefixIcon: Icon(Icons.search),
                    border: OutlineInputBorder(borderRadius: BorderRadius.all(Radius.circular(10))),
                  ),
                  onChanged: (value) {
                    setState(() => _searchQuery = value.toLowerCase());
                  },
                ),
              ),
              IconButton(
                icon: const Icon(Icons.filter_list),
                onPressed: _openFilterDialog,
              ),
            ],
          ),
        ),
        Expanded(
          child: StreamBuilder<List<Job>>(
            stream: _jobService.getJobsByEmployer(user.uid),
            builder: (context, snapshot) {
              if (snapshot.connectionState == ConnectionState.waiting) {
                return const Center(child: CircularProgressIndicator());
              }

              if (!snapshot.hasData || snapshot.data!.isEmpty) {
                return const Center(child: Text('Нет размещённых вакансий'));
              }

              final jobs = snapshot.data!
                  .where((job) =>
                      (_searchQuery.isEmpty || job.title.toLowerCase().contains(_searchQuery)) &&
                      (_locationFilter.isEmpty || job.location?.toLowerCase() == _locationFilter) &&
                      (_minSalary == null || (job.salary ?? 0) >= _minSalary!))
                  .toList();

              if (jobs.isEmpty) {
                return const Center(child: Text('Нет вакансий по заданным критериям'));
              }

              return ListView.builder(
                padding: const EdgeInsets.all(12),
                itemCount: jobs.length,
                itemBuilder: (context, index) {
                  final job = jobs[index];

                  return FutureBuilder<QuerySnapshot>(
                    future: FirebaseFirestore.instance
                        .collection('applications')
                        .where('jobId', isEqualTo: job.id)
                        .get(),
                    builder: (context, appSnapshot) {
                      int applicationCount = appSnapshot.hasData ? appSnapshot.data!.docs.length : 0;

                      return Card(
                        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
                        elevation: 3,
                        margin: const EdgeInsets.symmetric(vertical: 8, horizontal: 4),
                        child: ListTile(
                          contentPadding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
                          title: Text(job.title, style: const TextStyle(fontSize: 16, fontWeight: FontWeight.bold)),
                          subtitle: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              const SizedBox(height: 4),
                              Text('Компания: ${job.company}'),
                              if (job.location != null && job.location!.isNotEmpty)
                                Text('Локация: ${job.location}'),
                              if (job.salary != null)
                                Text('Зарплата: ${job.salary!.toStringAsFixed(0)} ₸'),
                              const SizedBox(height: 4),
                              Text('Откликов: $applicationCount', style: const TextStyle(color: Colors.green)),
                            ],
                          ),
                          trailing: const Icon(Icons.arrow_forward_ios, size: 16),
                          onTap: () async {
                            await Navigator.push(
                              context,
                              MaterialPageRoute(
                                builder: (_) => JobDetailScreen(jobId: job.id),
                              ),
                            );
                            setState(() {}); // обновить после возврата
                          },
                        ),
                      );
                    },
                  );
                },
              );
            },
          ),
        ),
      ],
    );
  }

  void _openFilterDialog() {
    final locationController = TextEditingController(text: _locationFilter);
    final salaryController = TextEditingController(text: _minSalary?.toString() ?? '');

    showDialog(
      context: context,
      builder: (context) {
        return AlertDialog(
          title: const Text('Фильтр'),
          content: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              TextField(
                controller: locationController,
                decoration: const InputDecoration(labelText: 'Город'),
              ),
              const SizedBox(height: 12),
              TextField(
                controller: salaryController,
                keyboardType: TextInputType.number,
                decoration: const InputDecoration(labelText: 'Минимальная зарплата'),
              ),
            ],
          ),
          actions: [
            TextButton(
              onPressed: () {
                setState(() {
                  _locationFilter = '';
                  _minSalary = null;
                });
                Navigator.pop(context);
              },
              child: const Text('Сбросить'),
            ),
            ElevatedButton(
              onPressed: () {
                setState(() {
                  _locationFilter = locationController.text.trim().toLowerCase();
                  _minSalary = double.tryParse(salaryController.text.trim());
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
}
