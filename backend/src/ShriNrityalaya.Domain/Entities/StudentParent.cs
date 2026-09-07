using ShriNrityalaya.Domain.Common;

namespace ShriNrityalaya.Domain.Entities;

public class StudentParent : BaseEntity
{
    public Guid StudentId { get; set; }
    public Student Student { get; set; } = null!;

    public Guid ParentId { get; set; }
    public Parent Parent { get; set; } = null!;

    public string Relationship { get; set; } = string.Empty;
    public bool IsPrimaryContact { get; set; }
}
