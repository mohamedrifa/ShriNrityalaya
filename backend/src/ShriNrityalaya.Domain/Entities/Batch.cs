using ShriNrityalaya.Domain.Common;

namespace ShriNrityalaya.Domain.Entities;

public class Batch : AuditableEntity
{
    public Guid AcademyId { get; set; }
    public string Name { get; set; } = string.Empty;
    public string Level { get; set; } = string.Empty;
    public string? Description { get; set; }
    public Guid? DefaultFeePlanId { get; set; }
    public string Status { get; set; } = "Active";

    public ICollection<BatchStudent> Students { get; set; } = new List<BatchStudent>();
    public ICollection<ClassSchedule> Schedules { get; set; } = new List<ClassSchedule>();
}
