import 'package:cloud_firestore/cloud_firestore.dart';


class Job {
  final String id;
  final String title;
  final String description;
  final String employerId;
  final String location;
  final String company;
  final DateTime createdAt;
  final List<String>? requirements;
  final double? salary;

  Job({
    required this.id,
    required this.title,
    required this.description,
    required this.employerId,
    required this.location,
    required this.company,
    required this.createdAt,
    this.requirements,
    this.salary,
  });

  factory Job.fromMap(String id, Map<String, dynamic> data) {
  return Job(
    id: id,
    title: data['title'] ?? '',
    description: data['description'] ?? '',
    employerId: data['employerId'] ?? '',
    location: data['location'] ?? '',
    company: data['company'] ?? '',
    createdAt: (data['createdAt'] as Timestamp?)?.toDate() ?? DateTime.now(),
    requirements: (data['requirements'] is List)
        ? List<String>.from(data['requirements'] ?? [])
        : [],
    salary: data['salary'] is num
        ? (data['salary'] as num).toDouble()
        : null,
  );
}

  Map<String, dynamic> toMap() {
    return {
      'title': title,
      'description': description,
      'employerId': employerId,
      'location': location,
      'company': company,
      'createdAt': createdAt,
      'requirements': requirements,
      'salary': salary,
    };
  }
}
