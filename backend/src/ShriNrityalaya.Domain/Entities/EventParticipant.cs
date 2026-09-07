using ShriNrityalaya.Domain.Common;

namespace ShriNrityalaya.Domain.Entities;

public class EventParticipant : AuditableEntity
{
    public Guid AcademyEventId { get; set; }
    public AcademyEvent AcademyEvent { get; set; } = null!;

    public Guid StudentId { get; set; }
    public Student Student { get; set; } = null!;

    public bool HasPaidFee { get; set; }
    public string Status { get; set; } = "Registered"; // Registered, Participated, Cancelled
}
