using Microsoft.AspNetCore.Authorization;
using Microsoft.AspNetCore.Mvc;
using ShriNrityalaya.Domain.Entities;
using ShriNrityalaya.Domain.Interfaces;

namespace ShriNrityalaya.Api.Controllers;

[ApiController]
[Route("api/v1/[controller]")]
[Authorize(Roles = "Teacher,SystemAdmin")]
public class DirectoryController : ControllerBase
{
    private readonly IRepository<Student> _studentRepository;
    private readonly IRepository<Parent> _parentRepository;
    private readonly IRepository<StudentParent> _studentParentRepository;

    public DirectoryController(
        IRepository<Student> studentRepository,
        IRepository<Parent> parentRepository,
        IRepository<StudentParent> studentParentRepository)
    {
        _studentRepository = studentRepository;
        _parentRepository = parentRepository;
        _studentParentRepository = studentParentRepository;
    }

    [HttpGet]
    public async Task<IActionResult> GetDirectory()
    {
        var students = await _studentRepository.GetAllAsync();
        var parents = await _parentRepository.GetAllAsync();
        var links = await _studentParentRepository.GetAllAsync();

        var activeStudents = students.Where(s => s.Status != "Inactive").ToList();

        var directory = new List<DirectoryEntryDto>();

        foreach (var student in activeStudents)
        {
            var studentLinks = links.Where(l => l.StudentId == student.Id).ToList();
            foreach (var link in studentLinks)
            {
                var parent = parents.FirstOrDefault(p => p.Id == link.ParentId);
                if (parent != null)
                {
                    directory.Add(new DirectoryEntryDto
                    {
                        StudentId = student.Id,
                        StudentFirstName = student.FirstName,
                        StudentLastName = student.LastName,
                        StudentEmergencyContact = student.EmergencyContactNumber ?? string.Empty,
                        ParentId = parent.Id,
                        ParentFirstName = parent.FirstName,
                        ParentLastName = parent.LastName,
                        ParentMobileNumber = parent.MobileNumber,
                        Relationship = link.Relationship
                    });
                }
            }
        }

        return Ok(new { success = true, data = directory });
    }
}

public class DirectoryEntryDto
{
    public Guid StudentId { get; set; }
    public string StudentFirstName { get; set; } = string.Empty;
    public string StudentLastName { get; set; } = string.Empty;
    public string StudentEmergencyContact { get; set; } = string.Empty;
    public Guid ParentId { get; set; }
    public string ParentFirstName { get; set; } = string.Empty;
    public string ParentLastName { get; set; } = string.Empty;
    public string ParentMobileNumber { get; set; } = string.Empty;
    public string Relationship { get; set; } = string.Empty;
}
