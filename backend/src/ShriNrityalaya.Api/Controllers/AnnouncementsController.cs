using Microsoft.AspNetCore.Authorization;
using Microsoft.AspNetCore.Mvc;
using ShriNrityalaya.Domain.Entities;
using ShriNrityalaya.Domain.Interfaces;

namespace ShriNrityalaya.Api.Controllers;

[ApiController]
[Route("api/v1/[controller]")]
[Authorize]
public class AnnouncementsController : ControllerBase
{
    private readonly IRepository<Announcement> _repository;

    public AnnouncementsController(IRepository<Announcement> repository)
    {
        _repository = repository;
    }

    [HttpGet]
    public async Task<IActionResult> GetAll()
    {
        var all = await _repository.GetAllAsync();
        var ordered = all.OrderByDescending(a => a.CreatedAt).ToList();
        return Ok(new { success = true, data = ordered });
    }

    [HttpPost]
    [Authorize(Roles = "SystemAdmin,Teacher")]
    public async Task<IActionResult> Create([FromBody] AnnouncementDto dto)
    {
        var announcement = new Announcement
        {
            Title = dto.Title,
            Content = dto.Content,
            CreatedAt = DateTimeOffset.UtcNow
        };
        var created = await _repository.AddAsync(announcement);
        return Ok(new { success = true, data = created });
    }
}

public class AnnouncementDto
{
    public string Title { get; set; } = string.Empty;
    public string Content { get; set; } = string.Empty;
}
