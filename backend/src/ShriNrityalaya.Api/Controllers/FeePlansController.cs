using Microsoft.AspNetCore.Authorization;
using Microsoft.AspNetCore.Mvc;
using ShriNrityalaya.Domain.Entities;
using ShriNrityalaya.Domain.Interfaces;

namespace ShriNrityalaya.Api.Controllers;

[ApiController]
[Route("api/v1/[controller]")]
[Authorize(Roles = "SystemAdmin,Teacher")]
public class FeePlansController : ControllerBase
{
    private readonly IRepository<FeePlan> _repository;

    public FeePlansController(IRepository<FeePlan> repository)
    {
        _repository = repository;
    }

    [HttpGet]
    public async Task<IActionResult> GetAll()
    {
        var plans = await _repository.GetAllAsync();
        return Ok(new { success = true, data = plans });
    }

    [HttpGet("{id}")]
    public async Task<IActionResult> GetById(Guid id)
    {
        var plan = await _repository.GetByIdAsync(id);
        if (plan == null) return NotFound();
        return Ok(new { success = true, data = plan });
    }

    [HttpPost]
    public async Task<IActionResult> Create([FromBody] FeePlan plan)
    {
        plan.CreatedAt = DateTimeOffset.UtcNow;
        var created = await _repository.AddAsync(plan);
        return CreatedAtAction(nameof(GetById), new { id = created.Id }, new { success = true, data = created });
    }

    [HttpPut("{id}")]
    public async Task<IActionResult> Update(Guid id, [FromBody] FeePlan updatedPlan)
    {
        var plan = await _repository.GetByIdAsync(id);
        if (plan == null) return NotFound();

        plan.Name = updatedPlan.Name;
        plan.MonthlyAmount = updatedPlan.MonthlyAmount;
        plan.AdmissionFee = updatedPlan.AdmissionFee;
        plan.Description = updatedPlan.Description;
        plan.UpdatedAt = DateTimeOffset.UtcNow;

        await _repository.UpdateAsync(plan);
        return Ok(new { success = true, message = "Fee plan updated successfully." });
    }
}
