using Microsoft.EntityFrameworkCore.Migrations;

#nullable disable

namespace TenisApi.Migrations
{
    /// <inheritdoc />
    public partial class AddMatchIdToSwingRecords : Migration
    {
        /// <inheritdoc />
        protected override void Up(MigrationBuilder migrationBuilder)
        {
            migrationBuilder.AddColumn<int>(
                name: "match_id",
                table: "swing_records",
                type: "integer",
                nullable: true);

            migrationBuilder.CreateIndex(
                name: "IX_swing_records_match_id",
                table: "swing_records",
                column: "match_id");

            migrationBuilder.AddForeignKey(
                name: "FK_swing_records_matches_match_id",
                table: "swing_records",
                column: "match_id",
                principalTable: "matches",
                principalColumn: "Id",
                onDelete: ReferentialAction.SetNull);
        }

        /// <inheritdoc />
        protected override void Down(MigrationBuilder migrationBuilder)
        {
            migrationBuilder.DropForeignKey(
                name: "FK_swing_records_matches_match_id",
                table: "swing_records");

            migrationBuilder.DropIndex(
                name: "IX_swing_records_match_id",
                table: "swing_records");

            migrationBuilder.DropColumn(
                name: "match_id",
                table: "swing_records");
        }
    }
}
