using ShriNrityalaya.Domain.Common;

namespace ShriNrityalaya.Domain.Entities;

public class ClassSession : AuditableEntity
{
    public Guid BatchId { get; set; }
    public Batch Batch { get; set; } = null!;

    public DateTime SessionDate { get; set; }
    public TimeSpan StartTime { get; set; }
    public TimeSpan EndTime { get; set; }
    
    public string Status { get; set; } = "Scheduled"; // Scheduled, Completed, Cancelled
    public string? TopicsCovered { get; set; }
    public Guid? TeacherId { get; set; }
}
