using Microsoft.EntityFrameworkCore.Migrations;
using Npgsql.EntityFrameworkCore.PostgreSQL.Metadata;

#nullable disable

namespace TenisApi.Migrations
{
    /// <inheritdoc />
    public partial class AddMatchPointHistoryTable : Migration
    {
        /// <inheritdoc />
        protected override void Up(MigrationBuilder migrationBuilder)
        {
            migrationBuilder.CreateTable(
                name: "match_point_histories",
                columns: table => new
                {
                    Id = table.Column<int>(type: "integer", nullable: false)
                        .Annotation("Npgsql:ValueGenerationStrategy", NpgsqlValueGenerationStrategy.IdentityByDefaultColumn),
                    MatchId = table.Column<int>(type: "integer", nullable: false),
                    P1Points = table.Column<int>(type: "integer", nullable: false),
                    P2Points = table.Column<int>(type: "integer", nullable: false),
                    P1Games = table.Column<int>(type: "integer", nullable: false),
                    P2Games = table.Column<int>(type: "integer", nullable: false),
                    P1Sets = table.Column<int>(type: "integer", nullable: false),
                    P2Sets = table.Column<int>(type: "integer", nullable: false),
                    Server = table.Column<string>(type: "character varying(20)", maxLength: 20, nullable: false),
                    SequenceNumber = table.Column<int>(type: "integer", nullable: false)
                },
                constraints: table =>
                {
                    table.PrimaryKey("PK_match_point_histories", x => x.Id);
                    table.ForeignKey(
                        name: "FK_match_point_histories_matches_MatchId",
                        column: x => x.MatchId,
                        principalTable: "matches",
                        principalColumn: "Id",
                        onDelete: ReferentialAction.Cascade);
                });

            migrationBuilder.CreateIndex(
                name: "IX_match_point_histories_MatchId",
                table: "match_point_histories",
                column: "MatchId");
        }

        /// <inheritdoc />
        protected override void Down(MigrationBuilder migrationBuilder)
        {
            migrationBuilder.DropTable(
                name: "match_point_histories");
        }
    }
}
