using Microsoft.AspNetCore.Authorization;
using Microsoft.AspNetCore.Mvc;
using ShriNrityalaya.Domain.Entities;
using ShriNrityalaya.Domain.Interfaces;

namespace ShriNrityalaya.Api.Controllers;

[ApiController]
[Route("api/v1/[controller]")]
[Authorize]
public class SkillAssessmentsController : ControllerBase
{
    private readonly IRepository<SkillAssessment> _repository;

    public SkillAssessmentsController(IRepository<SkillAssessment> repository)
    {
        _repository = repository;
    }

    [HttpGet]
    [Authorize(Roles = "SystemAdmin,Teacher")]
    public async Task<IActionResult> GetAll()
    {
        var all = await _repository.GetAllAsync();
        return Ok(new { success = true, data = all });
    }

    [HttpGet("student/{studentId}")]
    public async Task<IActionResult> GetByStudent(string studentId)
    {
        Guid targetStudentId;
        if (studentId.ToLower() == "me")
        {
            var userId = User.Claims.FirstOrDefault(c => c.Type == System.Security.Claims.ClaimTypes.NameIdentifier || c.Type == "sub" || c.Type == "http://schemas.xmlsoap.org/ws/2005/05/identity/claims/nameidentifier")?.Value;
            var userManager = HttpContext.RequestServices.GetRequiredService<Microsoft.AspNetCore.Identity.UserManager<ShriNrityalaya.Infrastructure.Identity.ApplicationUser>>();
            var user = await userManager.FindByIdAsync(userId!);
            var roles = await userManager.GetRolesAsync(user!);

            if (roles.Contains("Student"))
            {
                var studentRepo = HttpContext.RequestServices.GetRequiredService<IRepository<Student>>();
                var students = await studentRepo.GetAllAsync();
                var student = students.FirstOrDefault(s => s.UserId.ToString() == userId);
                if (student == null) return Unauthorized();
                targetStudentId = student.Id;
            }
            else if (roles.Contains("Parent"))
            {
                var studentParentRepo = HttpContext.RequestServices.GetRequiredService<IRepository<StudentParent>>();
                var parentRepo = HttpContext.RequestServices.GetRequiredService<IRepository<Parent>>();
                var allParents = await parentRepo.GetAllAsync();
                var currentParent = allParents.FirstOrDefault(p => p.UserId.ToString() == userId);
                if (currentParent == null) return Unauthorized();

                var allLinks = await studentParentRepo.GetAllAsync();
                var link = allLinks.FirstOrDefault(l => l.ParentId == currentParent.Id);
                if (link == null) return Unauthorized();
                
                targetStudentId = link.StudentId;
            }
            else
            {
                return Unauthorized();
            }
        }
        else
        {
            if (!Guid.TryParse(studentId, out targetStudentId))
                return BadRequest("Invalid student ID format");
        }

        var all = await _repository.GetAllAsync();
        var studentAssessments = all.Where(a => a.StudentId == targetStudentId).OrderByDescending(a => a.AssessmentDate).ToList();
        return Ok(new { success = true, data = studentAssessments });
    }

    [HttpPost]
    [Authorize(Roles = "SystemAdmin,Teacher")]
    public async Task<IActionResult> Create([FromBody] CreateSkillAssessmentDto dto)
    {
        var assessment = new SkillAssessment
        {
            StudentId = dto.StudentId,
            TeacherId = dto.TeacherId,
            BatchId = dto.BatchId,
            AssessmentDate = dto.AssessmentDate,
            SkillType = dto.SkillType ?? "General",
            SkillName = dto.SkillName ?? string.Empty,
            SkillLevel = dto.SkillLevel ?? string.Empty,
            Remarks = dto.Remarks ?? string.Empty,
            Score = dto.Score,
            CreatedAt = DateTimeOffset.UtcNow
        };
        var created = await _repository.AddAsync(assessment);
        return Ok(new { success = true, data = created });
    }
}

public class CreateSkillAssessmentDto
{
    public Guid StudentId { get; set; }
    public Guid TeacherId { get; set; }
    public Guid BatchId { get; set; }
    public DateTime AssessmentDate { get; set; }
    public string? SkillType { get; set; }
    public string? SkillName { get; set; }
    public string? SkillLevel { get; set; }
    public string? Remarks { get; set; }
    public int Score { get; set; }
}
