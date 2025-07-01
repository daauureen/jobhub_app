import 'package:flutter/material.dart';
import 'package:firebase_auth/firebase_auth.dart';
import '../../services/job_service.dart';
import '../../models/job_model.dart';
import '../job/job_detail_screen.dart';

class EmployerJobsTab extends StatefulWidget {

  EmployerJobsTab({super.key});

  @override
  State<EmployerJobsTab> createState() => _EmployerJobsTabState();
}

class _EmployerJobsTabState extends State<EmployerJobsTab> {
  final JobService _jobService = JobService();
  
  @override
  Widget build(BuildContext context) {
    final user = FirebaseAuth.instance.currentUser;
    if (user == null) return const Center(child: Text("Не авторизован"));

    return Scaffold(
      appBar: AppBar(title: const Text("Мои вакансии")),
      body: StreamBuilder<List<Job>>(
        stream: _jobService.getJobsByEmployer(user.uid),
        builder: (context, snapshot) {
          if (snapshot.connectionState == ConnectionState.waiting) return const Center(child: CircularProgressIndicator());
          if (!snapshot.hasData || snapshot.data!.isEmpty) return const Center(child: Text('Нет размещённых вакансий'));

          final jobs = snapshot.data!;
          return ListView.builder(
            itemCount: jobs.length,
            itemBuilder: (context, index) {
              final job = jobs[index];
              return ListTile(
                title: Text(job.title),
                subtitle: Text(job.company.isNotEmpty ? job.company : 'Без компании'),
                trailing: const Icon(Icons.arrow_forward_ios),
                onTap: () {
                  Navigator.push(
                    context,
                    MaterialPageRoute(
                      builder: (_) => JobDetailScreen(jobId: job.id),
                    ),
                  );
                },
              );
            },
          );
        },
      ),
    );
  }
}
