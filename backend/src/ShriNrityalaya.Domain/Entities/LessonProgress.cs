using ShriNrityalaya.Domain.Common;

namespace ShriNrityalaya.Domain.Entities;

public class LessonProgress : BaseEntity
{
    public Guid LessonId { get; set; }
    public Lesson Lesson { get; set; } = null!;

    public Guid StudentId { get; set; }
    public Student Student { get; set; } = null!;

    public bool IsFullyWatched { get; set; }
    public int WatchDurationSeconds { get; set; }
    public DateTimeOffset CreatedAt { get; set; } = DateTimeOffset.UtcNow;
}
