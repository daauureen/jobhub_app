import 'package:cloud_firestore/cloud_firestore.dart';

class Application {
  final String id;
  final String jobId;
  final String jobseekerId;
  final String employerId;
  final String? coverLetter;
  final DateTime appliedAt;
  final String status; // e.g. pending, reviewed, accepted, rejected

  Application({
    required this.id,
    required this.jobId,
    required this.jobseekerId,
    required this.employerId,
    this.coverLetter,
    required this.appliedAt,
    required this.status,
  });

  factory Application.fromMap(String id, Map<String, dynamic> data) {
    return Application(
      id: id,
      jobId: data['jobId'] ?? '',
      jobseekerId: data['jobseekerId'] ?? '',
      employerId: data['employerId'] ?? '',
      coverLetter: data['coverLetter'],
      appliedAt: (data['appliedAt'] as Timestamp).toDate(),
      status: data['status'] ?? 'pending',
    );
  }

  Map<String, dynamic> toMap() {
    return {
      'jobId': jobId,
      'jobseekerId': jobseekerId,
      'employerId': employerId,
      'coverLetter': coverLetter,
      'appliedAt': appliedAt,
      'status': status,
    };
  }
}
