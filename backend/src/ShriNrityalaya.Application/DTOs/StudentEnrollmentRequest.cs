using System.ComponentModel.DataAnnotations;

namespace ShriNrityalaya.Application.DTOs;

public class StudentEnrollmentRequest
{
    // Student Info
    [Required] public string StudentFirstName { get; set; } = string.Empty;
    [Required] public string StudentLastName { get; set; } = string.Empty;
    public DateTime DateOfBirth { get; set; }
    [Required] public string Gender { get; set; } = string.Empty;
    public string? Address { get; set; }
    public string? EmergencyContactNumber { get; set; }
    public DateTime JoiningDate { get; set; } = DateTime.UtcNow;
    public string Status { get; set; } = "Active";
    public Guid? FeePlanId { get; set; }

    // Student Auth
    [Required] public string StudentEmailOrUsername { get; set; } = string.Empty;
    [Required] public string StudentPassword { get; set; } = string.Empty;

    // Parent Info
    [Required] public string ParentFirstName { get; set; } = string.Empty;
    [Required] public string ParentLastName { get; set; } = string.Empty;
    [Required] public string ParentMobileNumber { get; set; } = string.Empty;

    // Parent Auth
    [Required] public string ParentEmailOrUsername { get; set; } = string.Empty;
    [Required] public string ParentPassword { get; set; } = string.Empty;
}
