using System.Collections.Generic;
using System.Text.Json.Serialization;
using System.Threading.Tasks;
using Microsoft.AspNetCore.Mvc;
using TenisApi.Application.DTOs;
using TenisApi.Application.Services;

namespace TenisApi.Controllers
{
    [ApiController]
    [Route("v1/matches")]
    public class MatchesController : ControllerBase
    {
        private readonly ILeagueService _leagueService;

        public MatchesController(ILeagueService leagueService)
        {
            _leagueService = leagueService;
        }

        [HttpGet]
        public async Task<ActionResult<IEnumerable<LeagueMatchDto>>> GetMatches()
        {
            var matches = await _leagueService.GetAllMatchesAsync();
            return Ok(matches);
        }

        [HttpGet("{id}")]
        public async Task<ActionResult<LeagueMatchDto>> GetMatchDetails(int id)
        {
            var match = await _leagueService.GetMatchByIdAsync(id);
            if (match == null)
            {
                return NotFound(new { message = "Maç bulunamadı." });
            }
            return Ok(match);
        }

        [HttpPost]
        public async Task<ActionResult<LeagueMatchDto>> CreateMatch([FromBody] CreateMatchRequest request)
        {
            var match = await _leagueService.CreateMatchAsync(
                request.Player1Name, 
                request.Player2Name, 
                request.MatchDate,
                request.IsDouble,
                request.Player1PartnerName,
                request.Player2PartnerName);
            return CreatedAtAction(nameof(GetMatchDetails), new { id = match.Id }, match);
        }

        [HttpPost("{id}/complete")]
        public async Task<IActionResult> CompleteMatch(int id, [FromBody] CompleteMatchRequest request)
        {
            try
            {
                await _leagueService.CompleteMatchAsync(id, request.Score);
                return NoContent();
            }
            catch (KeyNotFoundException ex)
            {
                return NotFound(new { message = ex.Message });
            }
        }

        [HttpPost("completed")]
        public async Task<ActionResult<LeagueMatchDto>> CreateCompletedMatch([FromBody] SaveCompletedMatchRequest request)
        {
            var match = await _leagueService.SaveCompletedMatchAsync(
                request.Player1Name,
                request.Player2Name,
                request.MatchDate,
                request.Score,
                request.History,
                request.IsDouble,
                request.Player1PartnerName,
                request.Player2PartnerName);
            
            return CreatedAtAction(nameof(GetMatchDetails), new { id = match.Id }, match);
        }

        [HttpPut("{id}/live-progress")]
        public async Task<IActionResult> UpdateLiveProgress(int id, [FromBody] UpdateLiveProgressRequest request)
        {
            try
            {
                await _leagueService.UpdateMatchLiveStateAsync(id, request.Score, request.History, request.IsCompleted);
                return Ok(new { message = "Maç gelişimi güncellendi." });
            }
            catch (System.Collections.Generic.KeyNotFoundException ex)
            {
                return NotFound(new { message = ex.Message });
            }
        }
    }

    public class UpdateLiveProgressRequest
    {
        [JsonPropertyName("score")]
        public string Score { get; set; } = string.Empty;

        [JsonPropertyName("is_completed")]
        public bool IsCompleted { get; set; }

        [JsonPropertyName("history")]
        public List<MatchPointHistoryDto> History { get; set; } = new();
    }

    public class CreateMatchRequest
    {
        [JsonPropertyName("player_1_name")]
        public string Player1Name { get; set; } = string.Empty;

        [JsonPropertyName("player_2_name")]
        public string Player2Name { get; set; } = string.Empty;

        [JsonPropertyName("match_date")]
        public string MatchDate { get; set; } = string.Empty;

        [JsonPropertyName("is_double")]
        public bool IsDouble { get; set; }

        [JsonPropertyName("player_1_partner_name")]
        public string? Player1PartnerName { get; set; }

        [JsonPropertyName("player_2_partner_name")]
        public string? Player2PartnerName { get; set; }
    }

    public class CompleteMatchRequest
    {
        public string Score { get; set; } = string.Empty;
    }

    public class SaveCompletedMatchRequest
    {
        [JsonPropertyName("player_1_name")]
        public string Player1Name { get; set; } = string.Empty;

        [JsonPropertyName("player_2_name")]
        public string Player2Name { get; set; } = string.Empty;

        [JsonPropertyName("match_date")]
        public string MatchDate { get; set; } = string.Empty;

        [JsonPropertyName("score")]
        public string Score { get; set; } = string.Empty;

        [JsonPropertyName("is_double")]
        public bool IsDouble { get; set; }

        [JsonPropertyName("player_1_partner_name")]
        public string? Player1PartnerName { get; set; }

        [JsonPropertyName("player_2_partner_name")]
        public string? Player2PartnerName { get; set; }

        [JsonPropertyName("history")]
        public List<MatchPointHistoryDto> History { get; set; } = new();
    }
}
