using ShriNrityalaya.Domain.Common;

namespace ShriNrityalaya.Domain.Entities;

public class TeacherFeedback : BaseEntity
{
    public Guid PracticeSubmissionId { get; set; }
    public PracticeSubmission PracticeSubmission { get; set; } = null!;

    public Guid TeacherId { get; set; }

    public string Remarks { get; set; } = string.Empty;
    public int Rating { get; set; } // 1-5
    public DateTime ReviewedAt { get; set; }
}
