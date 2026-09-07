using ShriNrityalaya.Domain.Common;

namespace ShriNrityalaya.Domain.Entities;

public class FeePlan : AuditableEntity
{
    public Guid AcademyId { get; set; }
    public string Name { get; set; } = string.Empty;
    public decimal MonthlyAmount { get; set; }
    public decimal AdmissionFee { get; set; }
    public string? Description { get; set; }
    public bool IsActive { get; set; } = true;
}
