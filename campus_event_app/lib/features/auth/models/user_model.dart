class UserModel {
  const UserModel({
    required this.id,
    required this.fullName,
    required this.email,
    required this.role,
    this.studentIdNumber,
    this.department,
    this.phone,
    this.isActive = true,
  });

  final int id;
  final String fullName;
  final String email;
  final String role; // student | organizer | admin
  final String? studentIdNumber;
  final String? department;
  final String? phone;
  final bool isActive;

  bool get isStudent => role == 'student';
  bool get isOrganizer => role == 'organizer';
  bool get isAdmin => role == 'admin';

  factory UserModel.fromJson(Map<String, dynamic> json) {
    return UserModel(
      id: int.parse(json['id'].toString()),
      fullName: (json['full_name'] ?? '').toString(),
      email: (json['email'] ?? '').toString(),
      role: (json['role'] ?? 'student').toString(),
      studentIdNumber: json['student_id_number']?.toString(),
      department: json['department']?.toString(),
      phone: json['phone']?.toString(),
      isActive: json['is_active'].toString() != '0',
    );
  }

  Map<String, dynamic> toJson() => {
        'id': id,
        'full_name': fullName,
        'email': email,
        'role': role,
        'student_id_number': studentIdNumber,
        'department': department,
        'phone': phone,
        'is_active': isActive ? 1 : 0,
      };
}
