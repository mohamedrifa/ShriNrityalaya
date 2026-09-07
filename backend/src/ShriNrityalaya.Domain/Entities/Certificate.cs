using ShriNrityalaya.Domain.Common;

namespace ShriNrityalaya.Domain.Entities;

public class Certificate : AuditableEntity
{
    public Guid StudentId { get; set; }
    public Student Student { get; set; } = null!;

    public string Title { get; set; } = string.Empty;
    public string Description { get; set; } = string.Empty;
    public DateTime IssueDate { get; set; }
    public string? CertificateImageUrl { get; set; }
}
