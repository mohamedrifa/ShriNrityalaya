using Microsoft.AspNetCore.Authorization;
using Microsoft.AspNetCore.Mvc;
using ShriNrityalaya.Domain.Entities;
using ShriNrityalaya.Domain.Interfaces;

namespace ShriNrityalaya.Api.Controllers;

[ApiController]
[Route("api/v1/[controller]")]
[Authorize]
public class LessonsController : ControllerBase
{
    private readonly IRepository<Lesson> _repository;

    public LessonsController(IRepository<Lesson> repository)
    {
        _repository = repository;
    }

    [HttpGet]
    public async Task<IActionResult> GetAll()
    {
        var all = await _repository.GetAllAsync();
        return Ok(new { success = true, data = all });
    }

    [HttpGet("batch/{batchId}")]
    public async Task<IActionResult> GetByBatch(Guid batchId)
    {
        var all = await _repository.GetAllAsync();
        var batchLessons = all.Where(l => l.BatchId == batchId).OrderBy(l => l.OrderSequence).ToList();
        return Ok(new { success = true, data = batchLessons });
    }

    [HttpPost("upload")]
    [Authorize(Roles = "SystemAdmin,Teacher")]
    public async Task<IActionResult> UploadLesson(
        [FromForm] Guid? batchId,
        [FromForm] string title,
        [FromForm] string? description,
        [FromForm] int orderSequence,
        IFormFile? videoFile)
    {
        var lesson = new Lesson
        {
            BatchId = batchId == Guid.Empty ? null : batchId,
            Title = title,
            Description = description,
            OrderSequence = orderSequence,
            CreatedAt = DateTimeOffset.UtcNow
        };

        if (videoFile != null && videoFile.Length > 0)
        {
            var uploadsFolder = Path.Combine(Directory.GetCurrentDirectory(), "wwwroot", "uploads", "lessons");
            if (!Directory.Exists(uploadsFolder)) Directory.CreateDirectory(uploadsFolder);

            var fileName = Guid.NewGuid().ToString() + Path.GetExtension(videoFile.FileName);
            var filePath = Path.Combine(uploadsFolder, fileName);

            using (var stream = new FileStream(filePath, FileMode.Create))
            {
                await videoFile.CopyToAsync(stream);
            }

            lesson.VideoUrl = "/uploads/lessons/" + fileName;
        }

        var created = await _repository.AddAsync(lesson);
        return Ok(new { success = true, data = created });
    }
}
