using Microsoft.AspNetCore.Authorization;
using Microsoft.AspNetCore.Mvc;
using ShriNrityalaya.Domain.Entities;
using ShriNrityalaya.Domain.Interfaces;

namespace ShriNrityalaya.Api.Controllers;

[ApiController]
[Route("api/v1/[controller]")]
[Authorize(Roles = "Teacher,SystemAdmin")]
public class AttendanceController : ControllerBase
{
    private readonly IRepository<AttendanceRecord> _repository;

    public AttendanceController(IRepository<AttendanceRecord> repository)
    {
        _repository = repository;
    }

    [HttpPost("bulk")]
    public async Task<IActionResult> MarkAttendanceBulk([FromBody] List<AttendanceRecord> records)
    {
        foreach (var record in records)
        {
            await _repository.AddAsync(record);
        }
        return Ok(new { success = true, message = "Attendance marked successfully." });
    }

    [HttpGet("session/{sessionId}")]
    public async Task<IActionResult> GetBySession(Guid sessionId)
    {
        var all = await _repository.GetAllAsync();
        var sessionRecords = all.Where(a => a.ClassSessionId == sessionId).ToList();
        
        return Ok(new { success = true, data = sessionRecords });
    }
}
