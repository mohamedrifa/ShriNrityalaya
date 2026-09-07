using ShriNrityalaya.Domain.Common;

namespace ShriNrityalaya.Domain.Entities;

public class BatchStudent : BaseEntity
{
    public Guid BatchId { get; set; }
    public Batch Batch { get; set; } = null!;

    public Guid StudentId { get; set; }
    public Student Student { get; set; } = null!;

    public DateTime JoinedAt { get; set; }
    public string Status { get; set; } = "Active";
}
