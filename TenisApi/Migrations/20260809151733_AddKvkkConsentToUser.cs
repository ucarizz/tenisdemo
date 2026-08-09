using System;
using Microsoft.EntityFrameworkCore.Migrations;

#nullable disable

namespace TenisApi.Migrations
{
    /// <inheritdoc />
    public partial class AddKvkkConsentToUser : Migration
    {
        /// <inheritdoc />
        protected override void Up(MigrationBuilder migrationBuilder)
        {
            migrationBuilder.AddColumn<bool>(
                name: "IsKvkkAccepted",
                table: "users",
                type: "boolean",
                nullable: false,
                defaultValue: false);

            migrationBuilder.AddColumn<DateTime>(
                name: "KvkkAcceptedAt",
                table: "users",
                type: "timestamp with time zone",
                nullable: true);
        }

        /// <inheritdoc />
        protected override void Down(MigrationBuilder migrationBuilder)
        {
            migrationBuilder.DropColumn(
                name: "IsKvkkAccepted",
                table: "users");

            migrationBuilder.DropColumn(
                name: "KvkkAcceptedAt",
                table: "users");
        }
    }
}
