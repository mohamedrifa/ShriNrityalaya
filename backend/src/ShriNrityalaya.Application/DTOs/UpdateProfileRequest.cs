using System.ComponentModel.DataAnnotations;

namespace ShriNrityalaya.Application.DTOs;

public class UpdateProfileRequest
{
    [Required]
    public string FirstName { get; set; } = string.Empty;

    [Required]
    public string LastName { get; set; } = string.Empty;
}
