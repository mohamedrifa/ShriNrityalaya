using Microsoft.EntityFrameworkCore;
using Microsoft.EntityFrameworkCore.Metadata.Builders;
using ShriNrityalaya.Domain.Entities;

namespace ShriNrityalaya.Infrastructure.Persistence.Configurations;

public class StudentParentConfiguration : IEntityTypeConfiguration<StudentParent>
{
    public void Configure(EntityTypeBuilder<StudentParent> builder)
    {
        builder.HasKey(sp => sp.Id);
        
        builder.HasOne(sp => sp.Student)
            .WithMany(s => s.Parents)
            .HasForeignKey(sp => sp.StudentId)
            .OnDelete(DeleteBehavior.Restrict);

        builder.HasOne(sp => sp.Parent)
            .WithMany(p => p.Students)
            .HasForeignKey(sp => sp.ParentId)
            .OnDelete(DeleteBehavior.Restrict);
    }
}
