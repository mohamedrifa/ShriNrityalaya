using ShriNrityalaya.Domain.Common;

namespace ShriNrityalaya.Domain.Entities;

public class Student : AuditableEntity
{
    public Guid UserId { get; set; }
    public string FirstName { get; set; } = string.Empty;
    public string LastName { get; set; } = string.Empty;
    public DateTime DateOfBirth { get; set; }
    public string Gender { get; set; } = string.Empty;
    public string? BloodGroup { get; set; }
    public string? Address { get; set; }
    public string? EmergencyContactNumber { get; set; }
    public DateTime JoiningDate { get; set; }
    public string Status { get; set; } = "Active";

    public ICollection<StudentParent> Parents { get; set; } = new List<StudentParent>();
    public ICollection<BatchStudent> Batches { get; set; } = new List<BatchStudent>();
}
