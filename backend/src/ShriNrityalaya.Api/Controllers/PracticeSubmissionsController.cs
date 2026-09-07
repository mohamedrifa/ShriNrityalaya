using Microsoft.AspNetCore.Authorization;
using Microsoft.AspNetCore.Mvc;
using ShriNrityalaya.Domain.Entities;
using ShriNrityalaya.Domain.Interfaces;

namespace ShriNrityalaya.Api.Controllers;

[ApiController]
[Route("api/v1/[controller]")]
[Authorize]
public class PracticeSubmissionsController : ControllerBase
{
    private readonly IRepository<PracticeSubmission> _repository;

    public PracticeSubmissionsController(IRepository<PracticeSubmission> repository)
    {
        _repository = repository;
    }

    [HttpGet]
    [Authorize(Roles = "SystemAdmin,Teacher")]
    public async Task<IActionResult> GetPendingSubmissions()
    {
        var all = await _repository.GetAllAsync();
        var pending = all.Where(s => s.Status == "PendingReview").ToList();
        return Ok(new { success = true, data = pending });
    }

    [HttpPost]
    [Authorize(Roles = "Student")]
    public async Task<IActionResult> Submit([FromBody] PracticeSubmission submission)
    {
        submission.CreatedAt = DateTimeOffset.UtcNow;
        submission.Status = "PendingReview";
        
        var created = await _repository.AddAsync(submission);
        return Ok(new { success = true, message = "Practice submitted successfully.", data = created });
    }
}
