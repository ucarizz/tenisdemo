using System.Collections.Generic;
using System.Threading.Tasks;
using TenisApi.Application.DTOs;

namespace TenisApi.Application.Services
{
    public interface ILeagueService
    {
        Task<IEnumerable<LeagueMatchDto>> GetAllMatchesAsync();
        Task<LeagueMatchDto?> GetMatchByIdAsync(int id);
        Task<LeagueMatchDto> CreateMatchAsync(
            string player1, 
            string player2, 
            string date, 
            bool isDouble = false, 
            string? player1Partner = null, 
            string? player2Partner = null);
        Task CompleteMatchAsync(int id, string score);
        
        // Maçı tamamlanmış olarak geçmişiyle birlikte tek adımda kaydeden servis metodu
        Task<LeagueMatchDto> SaveCompletedMatchAsync(
            string player1, 
            string player2, 
            string date, 
            string score, 
            IEnumerable<MatchPointHistoryDto> history,
            bool isDouble = false,
            string? player1Partner = null,
            string? player2Partner = null);

        Task UpdateMatchLiveStateAsync(
            int matchId, 
            string score, 
            IEnumerable<MatchPointHistoryDto> history,
            bool isCompleted);
    }
}
