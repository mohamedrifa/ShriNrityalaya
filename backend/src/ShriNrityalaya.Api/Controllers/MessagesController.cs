using Microsoft.AspNetCore.Authorization;
using Microsoft.AspNetCore.Mvc;
using ShriNrityalaya.Domain.Entities;
using ShriNrityalaya.Domain.Interfaces;

namespace ShriNrityalaya.Api.Controllers;

[ApiController]
[Route("api/v1/[controller]")]
[Authorize]
public class MessagesController : ControllerBase
{
    private readonly IRepository<Message> _repository;

    public MessagesController(IRepository<Message> repository)
    {
        _repository = repository;
    }

    [HttpGet("inbox/{userId}")]
    public async Task<IActionResult> GetInbox(Guid userId)
    {
        var all = await _repository.GetAllAsync();
        var inbox = all.Where(m => m.ReceiverId == userId).OrderByDescending(m => m.CreatedAt).ToList();
        return Ok(new { success = true, data = inbox });
    }

    [HttpPost]
    public async Task<IActionResult> SendMessage([FromBody] Message message)
    {
        message.CreatedAt = DateTimeOffset.UtcNow;
        message.IsRead = false;
        var created = await _repository.AddAsync(message);
        return Ok(new { success = true, data = created });
    }
}
