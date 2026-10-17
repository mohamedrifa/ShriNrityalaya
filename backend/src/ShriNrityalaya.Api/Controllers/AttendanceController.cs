using Microsoft.AspNetCore.Authorization;
using Microsoft.AspNetCore.Mvc;
using ShriNrityalaya.Domain.Entities;
using ShriNrityalaya.Domain.Interfaces;
using System.Security.Claims;

namespace ShriNrityalaya.Api.Controllers;

[ApiController]
[Route("api/v1/[controller]")]
[Authorize]
public class AttendanceController : ControllerBase
{
    private readonly IRepository<AttendanceRecord> _repository;

    public AttendanceController(IRepository<AttendanceRecord> repository)
    {
        _repository = repository;
    }

    [HttpPost("bulk")]
    [Authorize(Roles = "Teacher,SystemAdmin")]
    public async Task<IActionResult> MarkAttendanceBulk([FromBody] List<AttendanceRecordDto> records)
    {
        if (records == null || records.Count == 0)
        {
            return BadRequest(new { success = false, message = "No attendance records provided." });
        }

        var sessionRepo = HttpContext.RequestServices.GetRequiredService<IRepository<ClassSession>>();
        var batchRepo = HttpContext.RequestServices.GetRequiredService<IRepository<Batch>>();

        // Resolve or create a default batch if none exists
        var allBatches = await batchRepo.GetAllAsync();
        var defaultBatch = allBatches.FirstOrDefault();
        if (defaultBatch == null)
        {
            defaultBatch = new Batch
            {
                Name = "General Batch",
                Level = "All Levels",
                Status = "Active",
                CreatedAt = DateTimeOffset.UtcNow
            };
            await batchRepo.AddAsync(defaultBatch);
        }

        var allSessions = await sessionRepo.GetAllAsync();
        var allAttendance = await _repository.GetAllAsync();

        foreach (var record in records)
        {
            Guid targetSessionId = record.ClassSessionId ?? Guid.Empty;

            // If session is empty, find or create one for the date
            if (targetSessionId == Guid.Empty)
            {
                var sessionDate = record.Date?.Date ?? DateTime.UtcNow.Date;
                var existingSession = allSessions.FirstOrDefault(s => s.SessionDate.Date == sessionDate);
                if (existingSession == null)
                {
                    existingSession = new ClassSession
                    {
                        BatchId = defaultBatch.Id,
                        SessionDate = sessionDate,
                        StartTime = new TimeSpan(17, 0, 0),
                        EndTime = new TimeSpan(18, 30, 0),
                        Status = "Completed",
                        TopicsCovered = "Regular Bharathanatyam Class",
                        CreatedAt = DateTimeOffset.UtcNow
                    };
                    await sessionRepo.AddAsync(existingSession);
                    allSessions = await sessionRepo.GetAllAsync();
                }
                targetSessionId = existingSession.Id;
            }

            var existingRecord = allAttendance.FirstOrDefault(a =>
                a.StudentId == record.StudentId && a.ClassSessionId == targetSessionId);

            if (existingRecord != null)
            {
                existingRecord.Status = record.Status;
                if (!string.IsNullOrEmpty(record.Remarks))
                {
                    existingRecord.Remarks = record.Remarks;
                }
                await _repository.UpdateAsync(existingRecord);
            }
            else
            {
                var newRecord = new AttendanceRecord
                {
                    StudentId = record.StudentId,
                    ClassSessionId = targetSessionId,
                    Status = record.Status,
                    Remarks = record.Remarks
                };
                await _repository.AddAsync(newRecord);
            }
        }

        return Ok(new { success = true, message = "Attendance marked successfully." });
    }

    [HttpGet("session/{sessionId}")]
    [Authorize(Roles = "Teacher,SystemAdmin")]
    public async Task<IActionResult> GetBySession(Guid sessionId)
    {
        var all = await _repository.GetAllAsync();
        var sessionRecords = all.Where(a => a.ClassSessionId == sessionId).ToList();
        
        return Ok(new { success = true, data = sessionRecords });
    }

    [HttpGet("student/{studentId}")]
    public async Task<IActionResult> GetByStudent(string studentId)
    {
        Guid targetStudentId;
        if (studentId.ToLower() == "me")
        {
            var userId = User.Claims.FirstOrDefault(c => c.Type == ClaimTypes.NameIdentifier || c.Type == "sub" || c.Type == "http://schemas.xmlsoap.org/ws/2005/05/identity/claims/nameidentifier")?.Value;
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
            {
                return BadRequest(new { success = false, message = "Invalid student ID." });
            }
        }

        var all = await _repository.GetAllAsync();
        var studentRecords = all.Where(a => a.StudentId == targetStudentId).ToList();

        var sessionRepo = HttpContext.RequestServices.GetRequiredService<IRepository<ClassSession>>();
        var sessions = await sessionRepo.GetAllAsync();
        var sessionMap = sessions.ToDictionary(s => s.Id, s => s);

        var result = studentRecords.Select(r => new
        {
            id = r.Id,
            studentId = r.StudentId,
            classSessionId = r.ClassSessionId,
            status = r.Status,
            remarks = r.Remarks,
            date = sessionMap.ContainsKey(r.ClassSessionId) ? sessionMap[r.ClassSessionId].SessionDate : DateTime.UtcNow,
            topicsCovered = sessionMap.ContainsKey(r.ClassSessionId) ? sessionMap[r.ClassSessionId].TopicsCovered : "Regular Bharathanatyam Class",
            startTime = sessionMap.ContainsKey(r.ClassSessionId) ? sessionMap[r.ClassSessionId].StartTime.ToString(@"hh\:mm") : "17:00",
            endTime = sessionMap.ContainsKey(r.ClassSessionId) ? sessionMap[r.ClassSessionId].EndTime.ToString(@"hh\:mm") : "18:30"
        }).OrderByDescending(x => x.date).ToList();

        return Ok(new { success = true, data = result });
    }
}

public class AttendanceRecordDto
{
    public Guid StudentId { get; set; }
    public Guid? ClassSessionId { get; set; }
    public string Status { get; set; } = "Present";
    public string? Remarks { get; set; }
    public DateTime? Date { get; set; }
}
