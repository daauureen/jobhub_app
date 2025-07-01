class UserModel {
  final String uid;
  final String name;
  final String email;
  final String role;
  final String? bio;
  final String? profileImageUrl;
  final String? resumeUrl;
  final String? companyName;
  final String? contactPerson;
  final String? phone;
  final String? address;
  final String? companyDescription;
  final String? website;

  UserModel({
    required this.uid,
    required this.name,
    required this.email,
    required this.role,
    this.bio,
    this.profileImageUrl,
    this.resumeUrl,
    this.companyName,
    this.contactPerson,
    this.phone,
    this.address,
    this.companyDescription,
    this.website,
  });

  factory UserModel.fromMap(Map<String, dynamic> data, String uid) {
    return UserModel(
      uid: uid,
      name: data['name'] ?? '',
      email: data['email'] ?? '',
      role: data['role'] ?? '',
      bio: data['bio'],
      profileImageUrl: data['profileImageUrl'],
      resumeUrl: data['resumeUrl'],
      companyName: data['companyName'],
      contactPerson: data['contactPerson'],
      phone: data['phone'],
      address: data['address'],
      companyDescription: data['companyDescription'],
      website: data['website'],
    );
  }

  Map<String, dynamic> toMap() {
    return {
      'name': name,
      'email': email,
      'role': role,
      'bio': bio,
      'profileImageUrl': profileImageUrl,
      'resumeUrl': resumeUrl,
      'companyName': companyName,
      'contactPerson': contactPerson,
      'phone': phone,
      'address': address,
      'companyDescription': companyDescription,
      'website': website,
    };
  }
}
