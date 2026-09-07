using ShriNrityalaya.Domain.Common;

namespace ShriNrityalaya.Domain.Entities;

public class LearningResource : BaseEntity
{
    public Guid LessonId { get; set; }
    public Lesson Lesson { get; set; } = null!;

    public string Title { get; set; } = string.Empty;
    public string Type { get; set; } = string.Empty; // Document, Audio, Video
    public string Url { get; set; } = string.Empty;
}
