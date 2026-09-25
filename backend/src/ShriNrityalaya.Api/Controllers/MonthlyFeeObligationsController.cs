using Microsoft.AspNetCore.Authorization;
using Microsoft.AspNetCore.Mvc;
using ShriNrityalaya.Domain.Entities;
using ShriNrityalaya.Domain.Interfaces;
using System.Security.Claims;

namespace ShriNrityalaya.Api.Controllers;

[ApiController]
[Route("api/v1/[controller]")]
[Authorize]
public class MonthlyFeeObligationsController : ControllerBase
{
    private readonly IRepository<MonthlyFeeObligation> _obligationRepository;
    private readonly IRepository<Student> _studentRepository;
    private readonly IRepository<FeePlan> _feePlanRepository;

    public MonthlyFeeObligationsController(
        IRepository<MonthlyFeeObligation> obligationRepository,
        IRepository<Student> studentRepository,
        IRepository<FeePlan> feePlanRepository)
    {
        _obligationRepository = obligationRepository;
        _studentRepository = studentRepository;
        _feePlanRepository = feePlanRepository;
    }

    [HttpGet]
    public async Task<IActionResult> GetAll()
    {
        var userId = User.Claims.FirstOrDefault(c => c.Type == ClaimTypes.NameIdentifier || c.Type == "sub" || c.Type == "http://schemas.xmlsoap.org/ws/2005/05/identity/claims/nameidentifier")?.Value;

        if (string.IsNullOrEmpty(userId)) return Unauthorized();

        var userManager = HttpContext.RequestServices.GetRequiredService<Microsoft.AspNetCore.Identity.UserManager<ShriNrityalaya.Infrastructure.Identity.ApplicationUser>>();
        var user = await userManager.FindByIdAsync(userId);
        if (user == null) return Unauthorized();

        var roles = await userManager.GetRolesAsync(user);

        var obligations = await _obligationRepository.GetAllAsync();
        var students = await _studentRepository.GetAllAsync();

        if (roles.Contains("Student") || roles.Contains("Parent"))
        {
            List<Guid> studentIds = new List<Guid>();

            if (roles.Contains("Student"))
            {
                studentIds = students.Where(s => s.UserId.ToString() == userId).Select(s => s.Id).ToList();
            }
            else if (roles.Contains("Parent"))
            {
                var studentParentRepo = HttpContext.RequestServices.GetRequiredService<IRepository<StudentParent>>();
                var parentRepo = HttpContext.RequestServices.GetRequiredService<IRepository<Parent>>();
                
                var allParents = await parentRepo.GetAllAsync();
                var currentParent = allParents.FirstOrDefault(p => p.UserId.ToString() == userId);
                
                if (currentParent != null)
                {
                    var allLinks = await studentParentRepo.GetAllAsync();
                    studentIds = allLinks.Where(l => l.ParentId == currentParent.Id).Select(l => l.StudentId).ToList();
                }
            }

            obligations = obligations.Where(o => studentIds.Contains(o.StudentId)).ToList();
        }
        else if (!roles.Contains("Teacher") && !roles.Contains("SystemAdmin"))
        {
            // Fail safe: if no recognized role, return empty
            obligations = new List<MonthlyFeeObligation>();
        }

        var result = obligations.Select(o => {
            var student = students.FirstOrDefault(s => s.Id == o.StudentId);
            return new {
                o.Id,
                o.StudentId,
                StudentName = student != null ? $"{student.FirstName} {student.LastName}" : "Unknown Student",
                o.Year,
                o.Month,
                o.AmountDue,
                o.AmountPaid,
                o.Status,
                o.DueDate
            };
        });

        return Ok(new { success = true, data = result });
    }

    [HttpPost("generate")]
    [Authorize(Roles = "Teacher,SystemAdmin")]
    public async Task<IActionResult> Generate([FromQuery] int year, [FromQuery] int month)
    {
        var allStudents = await _studentRepository.GetAllAsync();
        var activeStudents = allStudents.Where(s => s.Status == "Active").ToList();
        
        var existingObligations = await _obligationRepository.GetAllAsync();
        var existingForMonth = existingObligations.Where(o => o.Year == year && o.Month == month).Select(o => o.StudentId).ToList();

        var feePlans = await _feePlanRepository.GetAllAsync();
        var defaultPlan = feePlans.FirstOrDefault(); // Simplification: get default plan or student specific

        int createdCount = 0;
        foreach (var student in activeStudents)
        {
            if (existingForMonth.Contains(student.Id)) continue;
            
            FeePlan? planToUse = null;
            if (student.FeePlanId.HasValue)
            {
                planToUse = feePlans.FirstOrDefault(f => f.Id == student.FeePlanId.Value);
            }
            if (planToUse == null) planToUse = feePlans.FirstOrDefault(); // Fallback

            if (planToUse != null)
            {
                var obligation = new MonthlyFeeObligation
                {
                    StudentId = student.Id,
                    Year = year,
                    Month = month,
                    AmountDue = planToUse.MonthlyAmount,
                    AmountPaid = 0,
                    Status = "Unpaid",
                    DueDate = new DateTime(year, month, 10), // Due on 10th
                    CreatedAt = DateTimeOffset.UtcNow
                };
                await _obligationRepository.AddAsync(obligation);
                createdCount++;
            }
        }

        return Ok(new { success = true, message = $"Generated {createdCount} obligations for {month}/{year}." });
    }
}
