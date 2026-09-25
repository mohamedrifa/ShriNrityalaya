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
        var ordered = all.OrderByDescending(l => l.CreatedAt).ToList();
        return Ok(new { success = true, data = ordered });
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

    [HttpPut("{id}")]
    [Authorize(Roles = "SystemAdmin,Teacher")]
    public async Task<IActionResult> UpdateLesson(
        Guid id, 
        [FromForm] string? title, 
        [FromForm] string? description, 
        IFormFile? videoFile)
    {
        var lesson = await _repository.GetByIdAsync(id);
        if (lesson == null) return NotFound(new { success = false, message = "Lesson not found." });

        if (title != null) lesson.Title = title;
        lesson.Description = description;
        lesson.UpdatedAt = DateTimeOffset.UtcNow;

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

        await _repository.UpdateAsync(lesson);
        return Ok(new { success = true, data = lesson });
    }

    [HttpPost("{lessonId}/progress")]
    public async Task<IActionResult> RecordProgress(Guid lessonId, [FromBody] ProgressDto dto)
    {
        var userId = User.FindFirst(System.Security.Claims.ClaimTypes.NameIdentifier)?.Value;
        var studentRepo = HttpContext.RequestServices.GetRequiredService<IRepository<Student>>();
        var students = await studentRepo.GetAllAsync();
        var student = students.FirstOrDefault(s => s.UserId.ToString() == userId);

        if (student == null) 
        {
            return Ok(new { success = true, message = "Progress not tracked for non-students." });
        }

        var progressRepo = HttpContext.RequestServices.GetRequiredService<IRepository<LessonProgress>>();
        var allProgress = await progressRepo.GetAllAsync();
        var progress = allProgress.FirstOrDefault(p => p.LessonId == lessonId && p.StudentId == student.Id);

        if (progress == null)
        {
            progress = new LessonProgress
            {
                LessonId = lessonId,
                StudentId = student.Id,
                IsFullyWatched = dto.IsFullyWatched,
                WatchDurationSeconds = dto.WatchDurationSeconds,
                CreatedAt = DateTimeOffset.UtcNow
            };
            await progressRepo.AddAsync(progress);
        }
        else
        {
            progress.IsFullyWatched = progress.IsFullyWatched || dto.IsFullyWatched; // once watched, keep true
            if (dto.WatchDurationSeconds > progress.WatchDurationSeconds)
                progress.WatchDurationSeconds = dto.WatchDurationSeconds;
            
            await progressRepo.UpdateAsync(progress);
        }

        return Ok(new { success = true });
    }

    [HttpGet("{lessonId}/progress")]
    [Authorize(Roles = "Teacher,SystemAdmin")]
    public async Task<IActionResult> GetLessonProgress(Guid lessonId)
    {
        var progressRepo = HttpContext.RequestServices.GetRequiredService<IRepository<LessonProgress>>();
        var studentRepo = HttpContext.RequestServices.GetRequiredService<IRepository<Student>>();
        
        var allProgress = await progressRepo.GetAllAsync();
        var lessonProgress = allProgress.Where(p => p.LessonId == lessonId).ToList();
        
        var students = await studentRepo.GetAllAsync();

        var result = lessonProgress.Select(p => {
            var student = students.FirstOrDefault(s => s.Id == p.StudentId);
            return new {
                StudentName = student != null ? $"{student.FirstName} {student.LastName}" : "Unknown",
                p.IsFullyWatched,
                p.WatchDurationSeconds,
                p.CreatedAt
            };
        });

        return Ok(new { success = true, data = result });
    }
}

public class ProgressDto
{
    public bool IsFullyWatched { get; set; }
    public int WatchDurationSeconds { get; set; }
}

public class UpdateLessonDto
{
    public string? Title { get; set; }
    public string? Description { get; set; }
}
