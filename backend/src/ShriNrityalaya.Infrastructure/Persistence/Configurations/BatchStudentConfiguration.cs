using Microsoft.EntityFrameworkCore;
using Microsoft.EntityFrameworkCore.Metadata.Builders;
using ShriNrityalaya.Domain.Entities;

namespace ShriNrityalaya.Infrastructure.Persistence.Configurations;

public class BatchStudentConfiguration : IEntityTypeConfiguration<BatchStudent>
{
    public void Configure(EntityTypeBuilder<BatchStudent> builder)
    {
        builder.HasKey(bs => bs.Id);
        
        builder.HasOne(bs => bs.Batch)
            .WithMany(b => b.Students)
            .HasForeignKey(bs => bs.BatchId)
            .OnDelete(DeleteBehavior.Restrict);

        builder.HasOne(bs => bs.Student)
            .WithMany(s => s.Batches)
            .HasForeignKey(bs => bs.StudentId)
            .OnDelete(DeleteBehavior.Restrict);
    }
}
