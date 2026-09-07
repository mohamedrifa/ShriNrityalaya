using Microsoft.AspNetCore.Authorization;
using Microsoft.AspNetCore.Mvc;
using ShriNrityalaya.Domain.Entities;
using ShriNrityalaya.Domain.Interfaces;

namespace ShriNrityalaya.Api.Controllers;

[ApiController]
[Route("api/v1/[controller]")]
[Authorize]
public class StudentsController : ControllerBase
{
    private readonly IRepository<Student> _studentRepository;

    public StudentsController(IRepository<Student> studentRepository)
    {
        _studentRepository = studentRepository;
    }

    [HttpGet]
    public async Task<IActionResult> GetAll()
    {
        var students = await _studentRepository.GetAllAsync();
        return Ok(new { success = true, data = students });
    }

    [HttpGet("{id}")]
    public async Task<IActionResult> GetById(Guid id)
    {
        var student = await _studentRepository.GetByIdAsync(id);
        if (student == null) return NotFound(new { success = false, message = "Student not found." });

        return Ok(new { success = true, data = student });
    }

    [HttpPost]
    [Authorize(Roles = "Teacher,SystemAdmin")]
    public async Task<IActionResult> Create([FromBody] Student student)
    {
        student.CreatedAt = DateTimeOffset.UtcNow;
        var created = await _studentRepository.AddAsync(student);
        return CreatedAtAction(nameof(GetById), new { id = created.Id }, new { success = true, data = created });
    }

    [HttpPut("{id}")]
    [Authorize(Roles = "Teacher,SystemAdmin")]
    public async Task<IActionResult> Update(Guid id, [FromBody] Student student)
    {
        var existing = await _studentRepository.GetByIdAsync(id);
        if (existing == null) return NotFound(new { success = false, message = "Student not found." });

        existing.FirstName = student.FirstName;
        existing.LastName = student.LastName;
        existing.DateOfBirth = student.DateOfBirth;
        existing.Gender = student.Gender;
        existing.BloodGroup = student.BloodGroup;
        existing.Address = student.Address;
        existing.EmergencyContactNumber = student.EmergencyContactNumber;
        existing.JoiningDate = student.JoiningDate;
        existing.Status = student.Status;
        existing.UpdatedAt = DateTimeOffset.UtcNow;

        await _studentRepository.UpdateAsync(existing);
        return Ok(new { success = true, data = existing });
    }

    [HttpDelete("{id}")]
    [Authorize(Roles = "Teacher,SystemAdmin")]
    public async Task<IActionResult> Delete(Guid id)
    {
        var existing = await _studentRepository.GetByIdAsync(id);
        if (existing == null) return NotFound(new { success = false, message = "Student not found." });

        await _studentRepository.DeleteAsync(existing);
        return Ok(new { success = true, message = "Student deleted successfully." });
    }
}
