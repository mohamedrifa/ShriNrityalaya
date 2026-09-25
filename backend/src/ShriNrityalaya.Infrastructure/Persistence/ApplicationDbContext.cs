using Microsoft.AspNetCore.Identity;
using Microsoft.AspNetCore.Identity.EntityFrameworkCore;
using Microsoft.EntityFrameworkCore;
using ShriNrityalaya.Infrastructure.Identity;

namespace ShriNrityalaya.Infrastructure.Persistence;

public class ApplicationDbContext : IdentityDbContext<ApplicationUser, IdentityRole<Guid>, Guid>
{
    public ApplicationDbContext(DbContextOptions<ApplicationDbContext> options) : base(options)
    {
    }

    public DbSet<ShriNrityalaya.Domain.Entities.Student> Students { get; set; }
    public DbSet<ShriNrityalaya.Domain.Entities.Parent> Parents { get; set; }
    public DbSet<ShriNrityalaya.Domain.Entities.StudentParent> StudentParents { get; set; }
    public DbSet<ShriNrityalaya.Domain.Entities.Batch> Batches { get; set; }
    public DbSet<ShriNrityalaya.Domain.Entities.BatchStudent> BatchStudents { get; set; }
    public DbSet<ShriNrityalaya.Domain.Entities.ClassSchedule> ClassSchedules { get; set; }
    public DbSet<ShriNrityalaya.Domain.Entities.FeePlan> FeePlans { get; set; }
    public DbSet<ShriNrityalaya.Domain.Entities.MonthlyFeeObligation> MonthlyFeeObligations { get; set; }
    public DbSet<ShriNrityalaya.Domain.Entities.Payment> Payments { get; set; }
    public DbSet<ShriNrityalaya.Domain.Entities.ClassSession> ClassSessions { get; set; }
    public DbSet<ShriNrityalaya.Domain.Entities.AttendanceRecord> AttendanceRecords { get; set; }
    public DbSet<ShriNrityalaya.Domain.Entities.Lesson> Lessons { get; set; }
    public DbSet<ShriNrityalaya.Domain.Entities.LessonProgress> LessonProgresses { get; set; }
    public DbSet<ShriNrityalaya.Domain.Entities.LearningResource> LearningResources { get; set; }
    public DbSet<ShriNrityalaya.Domain.Entities.PracticeSubmission> PracticeSubmissions { get; set; }
    public DbSet<ShriNrityalaya.Domain.Entities.TeacherFeedback> TeacherFeedbacks { get; set; }
    public DbSet<ShriNrityalaya.Domain.Entities.SkillAssessment> SkillAssessments { get; set; }
    public DbSet<ShriNrityalaya.Domain.Entities.Certificate> Certificates { get; set; }
    public DbSet<ShriNrityalaya.Domain.Entities.Message> Messages { get; set; }
    public DbSet<ShriNrityalaya.Domain.Entities.AcademyEvent> AcademyEvents { get; set; }
    public DbSet<ShriNrityalaya.Domain.Entities.EventParticipant> EventParticipants { get; set; }
    public DbSet<ShriNrityalaya.Domain.Entities.Announcement> Announcements { get; set; }

    protected override void OnModelCreating(ModelBuilder builder)
    {
        base.OnModelCreating(builder);
        builder.ApplyConfigurationsFromAssembly(typeof(ApplicationDbContext).Assembly);
        
        builder.Entity<ShriNrityalaya.Domain.Entities.AcademyEvent>().Property(p => p.ParticipationFee).HasColumnType("decimal(18,2)");
        builder.Entity<ShriNrityalaya.Domain.Entities.FeePlan>().Property(p => p.AdmissionFee).HasColumnType("decimal(18,2)");
        builder.Entity<ShriNrityalaya.Domain.Entities.FeePlan>().Property(p => p.MonthlyAmount).HasColumnType("decimal(18,2)");
        builder.Entity<ShriNrityalaya.Domain.Entities.MonthlyFeeObligation>().Property(p => p.AmountDue).HasColumnType("decimal(18,2)");
        builder.Entity<ShriNrityalaya.Domain.Entities.MonthlyFeeObligation>().Property(p => p.AmountPaid).HasColumnType("decimal(18,2)");
        builder.Entity<ShriNrityalaya.Domain.Entities.Payment>().Property(p => p.Amount).HasColumnType("decimal(18,2)");
    }
}
