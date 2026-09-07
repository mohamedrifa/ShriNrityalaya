using Microsoft.AspNetCore.Authorization;
using Microsoft.AspNetCore.Mvc;
using ShriNrityalaya.Domain.Entities;
using ShriNrityalaya.Domain.Interfaces;

namespace ShriNrityalaya.Api.Controllers;

[ApiController]
[Route("api/v1/[controller]")]
[Authorize]
public class AcademyEventsController : ControllerBase
{
    private readonly IRepository<AcademyEvent> _repository;

    public AcademyEventsController(IRepository<AcademyEvent> repository)
    {
        _repository = repository;
    }

    [HttpGet]
    public async Task<IActionResult> GetAll()
    {
        var events = await _repository.GetAllAsync();
        var activeEvents = events.Where(e => e.Status != "Cancelled").OrderBy(e => e.EventDate).ToList();
        return Ok(new { success = true, data = activeEvents });
    }

    [HttpPost]
    [Authorize(Roles = "SystemAdmin,Teacher")]
    public async Task<IActionResult> Create([FromBody] AcademyEvent academyEvent)
    {
        academyEvent.CreatedAt = DateTimeOffset.UtcNow;
        academyEvent.Status = "Upcoming";
        var created = await _repository.AddAsync(academyEvent);
        return Ok(new { success = true, data = created });
    }
}
