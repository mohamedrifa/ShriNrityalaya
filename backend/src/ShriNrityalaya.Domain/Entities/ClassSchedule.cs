using ShriNrityalaya.Domain.Common;

namespace ShriNrityalaya.Domain.Entities;

public class ClassSchedule : BaseEntity
{
    public Guid BatchId { get; set; }
    public Batch Batch { get; set; } = null!;

    public DayOfWeek DayOfWeek { get; set; }
    public TimeSpan StartTime { get; set; }
    public TimeSpan EndTime { get; set; }
}
