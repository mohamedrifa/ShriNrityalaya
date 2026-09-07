using Microsoft.AspNetCore.Authorization;
using Microsoft.AspNetCore.Mvc;
using ShriNrityalaya.Domain.Entities;
using ShriNrityalaya.Domain.Interfaces;

namespace ShriNrityalaya.Api.Controllers;

[ApiController]
[Route("api/v1/[controller]")]
[Authorize(Roles = "SystemAdmin,Teacher")]
public class TeacherFeedbacksController : ControllerBase
{
    private readonly IRepository<TeacherFeedback> _repository;
    private readonly IRepository<PracticeSubmission> _submissionRepository;

    public TeacherFeedbacksController(IRepository<TeacherFeedback> repository, IRepository<PracticeSubmission> submissionRepository)
    {
        _repository = repository;
        _submissionRepository = submissionRepository;
    }

    [HttpPost]
    public async Task<IActionResult> CreateFeedback([FromBody] TeacherFeedback feedback)
    {
        var submission = await _submissionRepository.GetByIdAsync(feedback.PracticeSubmissionId);
        if (submission == null) return NotFound("Submission not found");

        feedback.ReviewedAt = DateTime.UtcNow;
        var created = await _repository.AddAsync(feedback);

        submission.Status = "Reviewed";
        await _submissionRepository.UpdateAsync(submission);

        return Ok(new { success = true, message = "Feedback submitted.", data = created });
    }
}
