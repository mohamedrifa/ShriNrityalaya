using System;
using Microsoft.EntityFrameworkCore.Migrations;

#nullable disable

namespace ShriNrityalaya.Infrastructure.Persistence.Migrations
{
    /// <inheritdoc />
    public partial class UpdateEventParticipantAuditable : Migration
    {
        /// <inheritdoc />
        protected override void Up(MigrationBuilder migrationBuilder)
        {
            migrationBuilder.AddColumn<DateTimeOffset>(
                name: "CreatedAt",
                table: "EventParticipants",
                type: "datetimeoffset",
                nullable: false,
                defaultValue: new DateTimeOffset(new DateTime(1, 1, 1, 0, 0, 0, 0, DateTimeKind.Unspecified), new TimeSpan(0, 0, 0, 0, 0)));

            migrationBuilder.AddColumn<Guid>(
                name: "CreatedBy",
                table: "EventParticipants",
                type: "uniqueidentifier",
                nullable: true);

            migrationBuilder.AddColumn<DateTimeOffset>(
                name: "DeletedAt",
                table: "EventParticipants",
                type: "datetimeoffset",
                nullable: true);

            migrationBuilder.AddColumn<Guid>(
                name: "DeletedBy",
                table: "EventParticipants",
                type: "uniqueidentifier",
                nullable: true);

            migrationBuilder.AddColumn<bool>(
                name: "IsDeleted",
                table: "EventParticipants",
                type: "bit",
                nullable: false,
                defaultValue: false);

            migrationBuilder.AddColumn<DateTimeOffset>(
                name: "UpdatedAt",
                table: "EventParticipants",
                type: "datetimeoffset",
                nullable: true);

            migrationBuilder.AddColumn<Guid>(
                name: "UpdatedBy",
                table: "EventParticipants",
                type: "uniqueidentifier",
                nullable: true);
        }

        /// <inheritdoc />
        protected override void Down(MigrationBuilder migrationBuilder)
        {
            migrationBuilder.DropColumn(
                name: "CreatedAt",
                table: "EventParticipants");

            migrationBuilder.DropColumn(
                name: "CreatedBy",
                table: "EventParticipants");

            migrationBuilder.DropColumn(
                name: "DeletedAt",
                table: "EventParticipants");

            migrationBuilder.DropColumn(
                name: "DeletedBy",
                table: "EventParticipants");

            migrationBuilder.DropColumn(
                name: "IsDeleted",
                table: "EventParticipants");

            migrationBuilder.DropColumn(
                name: "UpdatedAt",
                table: "EventParticipants");

            migrationBuilder.DropColumn(
                name: "UpdatedBy",
                table: "EventParticipants");
        }
    }
}
