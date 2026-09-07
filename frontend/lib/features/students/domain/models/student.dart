class Student {
  final String? id;
  final String firstName;
  final String lastName;
  final DateTime dateOfBirth;
  final String gender;
  final String? bloodGroup;
  final String? address;
  final String? emergencyContactNumber;
  final DateTime joiningDate;
  final String status;

  Student({
    this.id,
    required this.firstName,
    required this.lastName,
    required this.dateOfBirth,
    required this.gender,
    this.bloodGroup,
    this.address,
    this.emergencyContactNumber,
    required this.joiningDate,
    required this.status,
  });

  factory Student.fromJson(Map<String, dynamic> json) {
    return Student(
      id: json['id'],
      firstName: json['firstName'] ?? '',
      lastName: json['lastName'] ?? '',
      dateOfBirth: DateTime.tryParse(json['dateOfBirth'] ?? '') ?? DateTime.now(),
      gender: json['gender'] ?? '',
      bloodGroup: json['bloodGroup'],
      address: json['address'],
      emergencyContactNumber: json['emergencyContactNumber'],
      joiningDate: DateTime.tryParse(json['joiningDate'] ?? '') ?? DateTime.now(),
      status: json['status'] ?? 'Active',
    );
  }

  Map<String, dynamic> toJson() {
    return {
      if (id != null) 'id': id,
      'firstName': firstName,
      'lastName': lastName,
      'dateOfBirth': dateOfBirth.toIso8601String(),
      'gender': gender,
      'bloodGroup': bloodGroup,
      'address': address,
      'emergencyContactNumber': emergencyContactNumber,
      'joiningDate': joiningDate.toIso8601String(),
      'status': status,
    };
  }
}
