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
        var role = User.FindFirst(ClaimTypes.Role)?.Value;
        var userId = User.FindFirst(ClaimTypes.NameIdentifier)?.Value;

        var obligations = await _obligationRepository.GetAllAsync();

        if (role == "Student" || role == "Parent")
        {
            // For now, simple filtering by UserId (in a real app, parent maps to multiple students)
            obligations = obligations.Where(o => o.Student.UserId.ToString() == userId).ToList();
        }

        return Ok(new { success = true, data = obligations });
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
            if (!existingForMonth.Contains(student.Id) && defaultPlan != null)
            {
                var obligation = new MonthlyFeeObligation
                {
                    StudentId = student.Id,
                    Year = year,
                    Month = month,
                    AmountDue = defaultPlan.MonthlyAmount,
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
