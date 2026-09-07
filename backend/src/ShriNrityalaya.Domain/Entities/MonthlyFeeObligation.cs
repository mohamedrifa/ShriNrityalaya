using ShriNrityalaya.Domain.Common;

namespace ShriNrityalaya.Domain.Entities;

public class MonthlyFeeObligation : AuditableEntity
{
    public Guid StudentId { get; set; }
    public Student Student { get; set; } = null!;

    public int Year { get; set; }
    public int Month { get; set; }
    
    public decimal AmountDue { get; set; }
    public decimal AmountPaid { get; set; }
    public string Status { get; set; } = "Unpaid"; // Unpaid, Partial, Paid
    
    public DateTime? DueDate { get; set; }
}
