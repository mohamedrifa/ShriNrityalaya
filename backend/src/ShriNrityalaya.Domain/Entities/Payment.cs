using ShriNrityalaya.Domain.Common;

namespace ShriNrityalaya.Domain.Entities;

public class Payment : AuditableEntity
{
    public Guid StudentId { get; set; }
    public Student Student { get; set; } = null!;

    public Guid? MonthlyFeeObligationId { get; set; }
    public MonthlyFeeObligation? MonthlyFeeObligation { get; set; }

    public decimal Amount { get; set; }
    public DateTime PaymentDate { get; set; }
    public string PaymentMethod { get; set; } = string.Empty; // Cash, UPI, BankTransfer
    public string? TransactionReference { get; set; }
    public string? ProofImageUrl { get; set; }
    
    public string Status { get; set; } = "PendingReview"; // PendingReview, Approved, Rejected
    public Guid? ReviewedBy { get; set; }
    public string? ReviewRemarks { get; set; }
}
