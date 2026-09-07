class SkillAssessment {
  final String? id;
  final String studentId;
  final String teacherId;
  final String batchId;
  final DateTime assessmentDate;
  final String skillType;
  final String skillName;
  final String skillLevel;
  final String remarks;
  final int score;

  SkillAssessment({
    this.id,
    required this.studentId,
    required this.teacherId,
    required this.batchId,
    required this.assessmentDate,
    required this.skillType,
    required this.skillName,
    required this.skillLevel,
    required this.remarks,
    required this.score,
  });

  factory SkillAssessment.fromJson(Map<String, dynamic> json) {
    return SkillAssessment(
      id: json['id'],
      studentId: json['studentId'] ?? '',
      teacherId: json['teacherId'] ?? '',
      batchId: json['batchId'] ?? '',
      assessmentDate: json['assessmentDate'] != null 
          ? DateTime.parse(json['assessmentDate']) 
          : DateTime.now(),
      skillType: json['skillType'] ?? 'General',
      skillName: json['skillName'] ?? '',
      skillLevel: json['skillLevel'] ?? '',
      remarks: json['remarks'] ?? '',
      score: json['score'] ?? 0,
    );
  }

  Map<String, dynamic> toJson() {
    return {
      if (id != null) 'id': id,
      'studentId': studentId,
      'teacherId': teacherId,
      'batchId': batchId,
      'assessmentDate': assessmentDate.toIso8601String(),
      'skillType': skillType,
      'skillName': skillName,
      'skillLevel': skillLevel,
      'remarks': remarks,
      'score': score,
    };
  }
}
