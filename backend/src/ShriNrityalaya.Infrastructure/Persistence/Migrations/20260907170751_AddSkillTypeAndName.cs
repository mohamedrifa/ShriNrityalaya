using Microsoft.EntityFrameworkCore.Migrations;

#nullable disable

namespace ShriNrityalaya.Infrastructure.Persistence.Migrations
{
    /// <inheritdoc />
    public partial class AddSkillTypeAndName : Migration
    {
        /// <inheritdoc />
        protected override void Up(MigrationBuilder migrationBuilder)
        {
            migrationBuilder.AddColumn<string>(
                name: "SkillName",
                table: "SkillAssessments",
                type: "nvarchar(max)",
                nullable: false,
                defaultValue: "");

            migrationBuilder.AddColumn<string>(
                name: "SkillType",
                table: "SkillAssessments",
                type: "nvarchar(max)",
                nullable: false,
                defaultValue: "");
        }

        /// <inheritdoc />
        protected override void Down(MigrationBuilder migrationBuilder)
        {
            migrationBuilder.DropColumn(
                name: "SkillName",
                table: "SkillAssessments");

            migrationBuilder.DropColumn(
                name: "SkillType",
                table: "SkillAssessments");
        }
    }
}
