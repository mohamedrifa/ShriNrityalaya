using Microsoft.AspNetCore.Authorization;
using Microsoft.AspNetCore.Mvc;
using ShriNrityalaya.Domain.Entities;
using ShriNrityalaya.Domain.Interfaces;

namespace ShriNrityalaya.Api.Controllers;

[ApiController]
[Route("api/v1/[controller]")]
[Authorize]
public class EventParticipantsController : ControllerBase
{
    private readonly IRepository<EventParticipant> _repository;

    public EventParticipantsController(IRepository<EventParticipant> repository)
    {
        _repository = repository;
    }

    [HttpGet("event/{eventId}")]
    [Authorize(Roles = "SystemAdmin,Teacher")]
    public async Task<IActionResult> GetByEvent(Guid eventId)
    {
        var all = await _repository.GetAllAsync();
        var participants = all.Where(p => p.AcademyEventId == eventId).ToList();
        return Ok(new { success = true, data = participants });
    }

    [HttpPost("register")]
    public async Task<IActionResult> Register([FromBody] EventParticipant participant)
    {
        // Simple registration, usually payment logic goes here
        participant.CreatedAt = DateTimeOffset.UtcNow;
        participant.Status = "Registered";
        var created = await _repository.AddAsync(participant);
        return Ok(new { success = true, data = created, message = "Successfully registered for the event!" });
    }
}
