using Microsoft.AspNetCore.Authorization;
using Microsoft.AspNetCore.Mvc;
using ShriNrityalaya.Domain.Entities;
using ShriNrityalaya.Domain.Interfaces;

using Microsoft.AspNetCore.Identity;
using ShriNrityalaya.Application.DTOs;
using ShriNrityalaya.Infrastructure.Identity;

namespace ShriNrityalaya.Api.Controllers;

[ApiController]
[Route("api/v1/[controller]")]
[Authorize]
public class StudentsController : ControllerBase
{
    private readonly IRepository<Student> _studentRepository;
    private readonly IRepository<Parent> _parentRepository;
    private readonly IRepository<StudentParent> _studentParentRepository;
    private readonly UserManager<ApplicationUser> _userManager;

    public StudentsController(
        IRepository<Student> studentRepository,
        IRepository<Parent> parentRepository,
        IRepository<StudentParent> studentParentRepository,
        UserManager<ApplicationUser> userManager)
    {
        _studentRepository = studentRepository;
        _parentRepository = parentRepository;
        _studentParentRepository = studentParentRepository;
        _userManager = userManager;
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
    public async Task<IActionResult> Create([FromBody] StudentEnrollmentRequest req)
    {
        // 1. Create Student User
        var studentUser = new ApplicationUser
        {
            UserName = req.StudentEmailOrUsername,
            Email = req.StudentEmailOrUsername.Contains("@") ? req.StudentEmailOrUsername : null,
            FirstName = req.StudentFirstName,
            LastName = req.StudentLastName,
            CreatedAt = DateTimeOffset.UtcNow,
            IsActive = true
        };
        var studentResult = await _userManager.CreateAsync(studentUser, req.StudentPassword);
        if (!studentResult.Succeeded)
            return BadRequest(new { success = false, message = "Failed to create student login.", errors = studentResult.Errors });
        await _userManager.AddToRoleAsync(studentUser, "Student");

        // 2. Create Parent User
        var parentUser = new ApplicationUser
        {
            UserName = req.ParentEmailOrUsername,
            Email = req.ParentEmailOrUsername.Contains("@") ? req.ParentEmailOrUsername : null,
            FirstName = req.ParentFirstName,
            LastName = req.ParentLastName,
            CreatedAt = DateTimeOffset.UtcNow,
            IsActive = true
        };
        var parentResult = await _userManager.CreateAsync(parentUser, req.ParentPassword);
        if (!parentResult.Succeeded)
            return BadRequest(new { success = false, message = "Failed to create parent login.", errors = parentResult.Errors });
        await _userManager.AddToRoleAsync(parentUser, "Parent");

        // 3. Create Student Entity
        var student = new Student
        {
            UserId = studentUser.Id,
            FirstName = req.StudentFirstName,
            LastName = req.StudentLastName,
            DateOfBirth = req.DateOfBirth,
            Gender = req.Gender,
            Address = req.Address,
            EmergencyContactNumber = req.EmergencyContactNumber,
            JoiningDate = req.JoiningDate,
            Status = req.Status,
            FeePlanId = req.FeePlanId,
            CreatedAt = DateTimeOffset.UtcNow
        };
        var createdStudent = await _studentRepository.AddAsync(student);

        // 4. Create Parent Entity
        var parent = new Parent
        {
            UserId = parentUser.Id,
            FirstName = req.ParentFirstName,
            LastName = req.ParentLastName,
            MobileNumber = req.ParentMobileNumber,
            Email = req.ParentEmailOrUsername.Contains("@") ? req.ParentEmailOrUsername : null,
            Address = req.Address,
            CreatedAt = DateTimeOffset.UtcNow
        };
        var createdParent = await _parentRepository.AddAsync(parent);

        // 5. Link them
        var link = new StudentParent
        {
            StudentId = createdStudent.Id,
            ParentId = createdParent.Id,
            Relationship = "Primary"
        };
        await _studentParentRepository.AddAsync(link);

        return CreatedAtAction(nameof(GetById), new { id = createdStudent.Id }, new { success = true, data = createdStudent });
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
        existing.Address = student.Address;
        existing.EmergencyContactNumber = student.EmergencyContactNumber;
        existing.JoiningDate = student.JoiningDate;
        existing.Status = student.Status;
        existing.FeePlanId = student.FeePlanId;
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
