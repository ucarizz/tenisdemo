using Microsoft.EntityFrameworkCore.Migrations;

#nullable disable

namespace TenisApi.Migrations
{
    /// <inheritdoc />
    public partial class AddDoubleMatchSupport : Migration
    {
        /// <inheritdoc />
        protected override void Up(MigrationBuilder migrationBuilder)
        {
            migrationBuilder.AddColumn<bool>(
                name: "IsDouble",
                table: "matches",
                type: "boolean",
                nullable: false,
                defaultValue: false);

            migrationBuilder.AddColumn<string>(
                name: "Player1PartnerName",
                table: "matches",
                type: "character varying(100)",
                maxLength: 100,
                nullable: true);

            migrationBuilder.AddColumn<string>(
                name: "Player2PartnerName",
                table: "matches",
                type: "character varying(100)",
                maxLength: 100,
                nullable: true);
        }

        /// <inheritdoc />
        protected override void Down(MigrationBuilder migrationBuilder)
        {
            migrationBuilder.DropColumn(
                name: "IsDouble",
                table: "matches");

            migrationBuilder.DropColumn(
                name: "Player1PartnerName",
                table: "matches");

            migrationBuilder.DropColumn(
                name: "Player2PartnerName",
                table: "matches");
        }
    }
}
