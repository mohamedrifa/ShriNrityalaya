using ShriNrityalaya.Domain.Common;

namespace ShriNrityalaya.Domain.Entities;

public class Lesson : AuditableEntity
{
    public Guid? BatchId { get; set; }
    public Batch? Batch { get; set; }

    public string Title { get; set; } = string.Empty;
    public string? Description { get; set; }
    public string? VideoUrl { get; set; }
    
    public int OrderSequence { get; set; }
    
    public ICollection<LearningResource> Resources { get; set; } = new List<LearningResource>();
}
