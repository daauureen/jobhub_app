import 'package:cloud_firestore/cloud_firestore.dart';
import '../models/job_model.dart';

class JobService {
  final CollectionReference _jobs = FirebaseFirestore.instance.collection('jobs');

  // Создание вакансии
  Future<void> createJob(Job job) async {
    await _jobs.doc(job.id).set(job.toMap());
  }

  // Получение всех вакансий
  Stream<List<Job>> getAllJobs() {
    return _jobs
        .orderBy('createdAt', descending: true)
        .snapshots()
        .map((snapshot) => snapshot.docs.map((doc) => Job.fromMap(doc.id, doc.data() as Map<String, dynamic>)).toList());
  }

  // Получение вакансий по id работодателя
Stream<List<Job>> getJobsByEmployer(String employerId) {
  print("🔍 Получение вакансий для: $employerId");

  return _jobs
      .where('employerId', isEqualTo: employerId)
      .snapshots()
      .map((snapshot) {
        print("🧾 Найдено документов: ${snapshot.docs.length}");
        for (var doc in snapshot.docs) {
          print("📄 Документ: ${doc.id} | ${doc.data()}");
        }

        return snapshot.docs
            .map((doc) => Job.fromMap(doc.id, doc.data() as Map<String, dynamic>))
            .toList();
      });
}


  // Удаление вакансии
  Future<void> deleteJob(String jobId) async {
    await _jobs.doc(jobId).delete();
  }

  // Получение одной вакансии по id
  Future<Job?> getJobById(String jobId) async {
    DocumentSnapshot doc = await _jobs.doc(jobId).get();
    if (doc.exists) {
      return Job.fromMap(doc.id, doc.data() as Map<String, dynamic>);
    } else {
      return null;
    }
  }
}
