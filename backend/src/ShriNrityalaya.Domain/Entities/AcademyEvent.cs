using ShriNrityalaya.Domain.Common;

namespace ShriNrityalaya.Domain.Entities;

public class AcademyEvent : AuditableEntity
{
    public Guid AcademyId { get; set; }
    
    public string Title { get; set; } = string.Empty;
    public string Description { get; set; } = string.Empty;
    public DateTime EventDate { get; set; }
    public string Location { get; set; } = string.Empty;
    
    public decimal? ParticipationFee { get; set; }
    public string Status { get; set; } = "Upcoming"; // Upcoming, Ongoing, Completed, Cancelled
    
    public ICollection<EventParticipant> Participants { get; set; } = new List<EventParticipant>();
}
