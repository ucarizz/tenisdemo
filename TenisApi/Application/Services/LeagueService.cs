using System;
using System.Collections.Generic;
using System.Linq;
using System.Threading.Tasks;
using Microsoft.Extensions.Logging;
using TenisApi.Application.DTOs;
using TenisApi.Domain.Entities;
using TenisApi.Domain.Repositories;

namespace TenisApi.Application.Services
{
    public class LeagueService : ILeagueService
    {
        private readonly ILeagueMatchRepository _matchRepository;
        private readonly ILogger<LeagueService> _logger;

        public LeagueService(ILeagueMatchRepository matchRepository, ILogger<LeagueService> logger)
        {
            _matchRepository = matchRepository;
            _logger = logger;
        }

        public async Task<IEnumerable<LeagueMatchDto>> GetAllMatchesAsync()
        {
            var matches = await _matchRepository.GetAllAsync();
            return matches.Select(MapToDto);
        }

        public async Task<LeagueMatchDto?> GetMatchByIdAsync(int id)
        {
            var match = await _matchRepository.GetByIdAsync(id);
            return match != null ? MapToDto(match) : null;
        }

        public async Task<LeagueMatchDto> CreateMatchAsync(
            string player1, 
            string player2, 
            string date, 
            bool isDouble = false, 
            string? player1Partner = null, 
            string? player2Partner = null)
        {
            var match = new LeagueMatch(player1, player2, date, isDouble, player1Partner, player2Partner);
            await _matchRepository.AddAsync(match);
            _logger.LogInformation("Match started/created (ID: {MatchId}): {Player1} vs {Player2} (Double: {IsDouble})", 
                match.Id, player1, player2, isDouble);
            return MapToDto(match);
        }

        public async Task CompleteMatchAsync(int id, string score)
        {
            var match = await _matchRepository.GetByIdAsync(id);
            if (match == null)
                throw new KeyNotFoundException($"Maç bulunamadı (ID: {id})");

            // Eski imza için boş geçmiş listesi ile tamamlıyoruz
            match.CompleteMatch(score, new List<MatchPointHistory>());
            await _matchRepository.UpdateAsync(match);
            _logger.LogInformation("Match {MatchId} completed. Score: {Score}", id, score);
        }

        public async Task<LeagueMatchDto> SaveCompletedMatchAsync(
            string player1, 
            string player2, 
            string date, 
            string score, 
            IEnumerable<MatchPointHistoryDto> history,
            bool isDouble = false,
            string? player1Partner = null,
            string? player2Partner = null)
        {
            var match = new LeagueMatch(player1, player2, date, isDouble, player1Partner, player2Partner);
            
            // DTO listesini Domain Entity nesnelerine eşliyoruz
            var pointHistories = history.Select(h => new MatchPointHistory(
                h.P1Points,
                h.P2Points,
                h.P1Games,
                h.P2Games,
                h.P1Sets,
                h.P2Sets,
                h.Server,
                h.SequenceNumber
            )).ToList();

            match.CompleteMatch(score, pointHistories);
            
            await _matchRepository.AddAsync(match);
            _logger.LogInformation("Completed match saved (ID: {MatchId}): {Player1} vs {Player2}. Final Score: {Score}", 
                match.Id, player1, player2, score);
            return MapToDto(match);
        }

        public async Task UpdateMatchLiveStateAsync(
            int matchId, 
            string score, 
            IEnumerable<MatchPointHistoryDto> history,
            bool isCompleted)
        {
            var match = await _matchRepository.GetByIdAsync(matchId);
            if (match == null) return;

            var pointHistories = history.Select(h => new MatchPointHistory(
                h.P1Points,
                h.P2Points,
                h.P1Games,
                h.P2Games,
                h.P1Sets,
                h.P2Sets,
                h.Server,
                h.SequenceNumber
            )).ToList();

            if (isCompleted)
            {
                match.CompleteMatch(score, pointHistories);
                _logger.LogInformation("Match {MatchId} completed. Final Score: {Score}", matchId, score);
            }
            else
            {
                match.UpdateMatchProgress(score, pointHistories);
                _logger.LogInformation("Match {MatchId} progress updated. Current Score: {Score}", matchId, score);
            }

            await _matchRepository.UpdateAsync(match);
        }

        private static LeagueMatchDto MapToDto(LeagueMatch match)
        {
            return new LeagueMatchDto
            {
                Id = match.Id,
                Player1Name = match.Player1Name,
                Player2Name = match.Player2Name,
                MatchDate = match.MatchDate,
                Score = match.Score,
                IsCompleted = match.IsCompleted,
                CreateDate = match.CreateDate,
                IsDouble = match.IsDouble,
                Player1PartnerName = match.Player1PartnerName,
                Player2PartnerName = match.Player2PartnerName,
                PointHistories = match.PointHistories.Select(h => new MatchPointHistoryDto
                {
                    P1Points = h.P1Points,
                    P2Points = h.P2Points,
                    P1Games = h.P1Games,
                    P2Games = h.P2Games,
                    P1Sets = h.P1Sets,
                    P2Sets = h.P2Sets,
                    Server = h.Server,
                    SequenceNumber = h.SequenceNumber,
                    CreatedTime = h.CreatedTime
                }).OrderBy(h => h.SequenceNumber).ToList()
            };
        }
    }
}
