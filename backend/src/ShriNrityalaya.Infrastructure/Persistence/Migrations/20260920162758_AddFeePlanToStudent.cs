using System;
using Microsoft.EntityFrameworkCore.Migrations;

#nullable disable

namespace ShriNrityalaya.Infrastructure.Persistence.Migrations
{
    /// <inheritdoc />
    public partial class AddFeePlanToStudent : Migration
    {
        /// <inheritdoc />
        protected override void Up(MigrationBuilder migrationBuilder)
        {
            migrationBuilder.AddColumn<Guid>(
                name: "FeePlanId",
                table: "Students",
                type: "uniqueidentifier",
                nullable: true);

            migrationBuilder.CreateIndex(
                name: "IX_Students_FeePlanId",
                table: "Students",
                column: "FeePlanId");

            migrationBuilder.AddForeignKey(
                name: "FK_Students_FeePlans_FeePlanId",
                table: "Students",
                column: "FeePlanId",
                principalTable: "FeePlans",
                principalColumn: "Id");
        }

        /// <inheritdoc />
        protected override void Down(MigrationBuilder migrationBuilder)
        {
            migrationBuilder.DropForeignKey(
                name: "FK_Students_FeePlans_FeePlanId",
                table: "Students");

            migrationBuilder.DropIndex(
                name: "IX_Students_FeePlanId",
                table: "Students");

            migrationBuilder.DropColumn(
                name: "FeePlanId",
                table: "Students");
        }
    }
}
