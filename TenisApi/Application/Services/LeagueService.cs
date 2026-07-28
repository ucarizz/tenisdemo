using System;
using System.Collections.Generic;
using System.Linq;
using System.Threading.Tasks;
using TenisApi.Application.DTOs;
using TenisApi.Domain.Entities;
using TenisApi.Domain.Repositories;

namespace TenisApi.Application.Services
{
    public class LeagueService : ILeagueService
    {
        private readonly ILeagueMatchRepository _matchRepository;

        public LeagueService(ILeagueMatchRepository matchRepository)
        {
            _matchRepository = matchRepository;
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
            return MapToDto(match);
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
                    SequenceNumber = h.SequenceNumber
                }).OrderBy(h => h.SequenceNumber).ToList()
            };
        }
    }
}
