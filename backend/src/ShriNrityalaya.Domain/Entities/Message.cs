using ShriNrityalaya.Domain.Common;

namespace ShriNrityalaya.Domain.Entities;

public class Message : AuditableEntity
{
    public Guid SenderId { get; set; }
    public Guid ReceiverId { get; set; }
    
    public string Subject { get; set; } = string.Empty;
    public string Content { get; set; } = string.Empty;
    
    public bool IsRead { get; set; }
    public DateTime? ReadAt { get; set; }
}
