using ShriNrityalaya.Domain.Common;

namespace ShriNrityalaya.Domain.Entities;

public class PracticeSubmission : AuditableEntity
{
    public Guid StudentId { get; set; }
    public Student Student { get; set; } = null!;

    public Guid LessonId { get; set; }
    public Lesson Lesson { get; set; } = null!;

    public string VideoUrl { get; set; } = string.Empty;
    public string? StudentNotes { get; set; }
    
    public string Status { get; set; } = "PendingReview"; // PendingReview, Reviewed
    public TeacherFeedback? Feedback { get; set; }
}
