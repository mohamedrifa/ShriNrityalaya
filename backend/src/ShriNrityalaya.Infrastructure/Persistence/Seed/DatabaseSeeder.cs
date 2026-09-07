using Microsoft.AspNetCore.Identity;
using ShriNrityalaya.Infrastructure.Identity;

namespace ShriNrityalaya.Infrastructure.Persistence.Seed;

public static class DatabaseSeeder
{
    public static async Task SeedAsync(UserManager<ApplicationUser> userManager, RoleManager<IdentityRole<Guid>> roleManager)
    {
        var roles = new[] { "SystemAdmin", "Teacher", "Student", "Parent" };

        foreach (var role in roles)
        {
            if (!await roleManager.RoleExistsAsync(role))
            {
                await roleManager.CreateAsync(new IdentityRole<Guid>(role));
            }
        }

        var teacherEmail = "teacher@shrinrityalaya.com";
        if (await userManager.FindByEmailAsync(teacherEmail) == null)
        {
            var teacher = new ApplicationUser
            {
                UserName = teacherEmail,
                Email = teacherEmail,
                FirstName = "Primary",
                LastName = "Teacher",
                CreatedAt = DateTimeOffset.UtcNow,
                IsActive = true,
                EmailConfirmed = true
            };

            var result = await userManager.CreateAsync(teacher, "Teacher123!");
            if (result.Succeeded)
            {
                await userManager.AddToRoleAsync(teacher, "Teacher");
            }
        }
    }
}
