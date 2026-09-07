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
    public async Task<IActionResult> GetByStudent(Guid studentId)
    {
        var all = await _repository.GetAllAsync();
        var studentAssessments = all.Where(a => a.StudentId == studentId).OrderByDescending(a => a.AssessmentDate).ToList();
        return Ok(new { success = true, data = studentAssessments });
    }

    [HttpPost]
    [Authorize(Roles = "SystemAdmin,Teacher")]
    public async Task<IActionResult> Create([FromBody] SkillAssessment assessment)
    {
        assessment.CreatedAt = DateTimeOffset.UtcNow;
        var created = await _repository.AddAsync(assessment);
        return Ok(new { success = true, data = created });
    }
}
