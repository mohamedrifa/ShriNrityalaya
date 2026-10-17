using ShriNrityalaya.Domain.Common;

namespace ShriNrityalaya.Domain.Entities;

public class AttendanceRecord : BaseEntity
{
    public Guid ClassSessionId { get; set; }
    public ClassSession? ClassSession { get; set; }

    public Guid StudentId { get; set; }
    public Student? Student { get; set; }

    public string Status { get; set; } = "Present"; // Present, Absent, Late, Excused
    public string? Remarks { get; set; }
}
