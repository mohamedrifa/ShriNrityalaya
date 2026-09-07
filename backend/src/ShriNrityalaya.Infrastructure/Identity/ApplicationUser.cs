using Microsoft.AspNetCore.Identity;

namespace ShriNrityalaya.Infrastructure.Identity;

public class ApplicationUser : IdentityUser<Guid>
{
    public string FirstName { get; set; } = string.Empty;
    public string LastName { get; set; } = string.Empty;
    public DateTimeOffset CreatedAt { get; set; }
    public bool IsActive { get; set; } = true;
    public Guid? AcademyId { get; set; }
}
