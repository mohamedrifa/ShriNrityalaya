using ShriNrityalaya.Domain.Common;

namespace ShriNrityalaya.Domain.Entities;

public class SkillAssessment : AuditableEntity
{
    public Guid StudentId { get; set; }
    public Student Student { get; set; } = null!;

    public Guid TeacherId { get; set; }
    public Guid BatchId { get; set; }
    
    public DateTime AssessmentDate { get; set; }
    public string SkillType { get; set; } = "General"; // Adavu, Margam, Theory
    public string SkillName { get; set; } = string.Empty; // Tatta Adavu, Alarippu
    public string SkillLevel { get; set; } = string.Empty; // Beginner, Intermediate, Advanced
    public string Remarks { get; set; } = string.Empty;
    public int Score { get; set; } // Out of 100
}
