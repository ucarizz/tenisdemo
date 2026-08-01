using System;
using System.Collections.Concurrent;
using System.Linq;
using TenisApi.Application.DTOs;

namespace TenisApi.Application.Services
{
    public class LobbyManager
    {
        private readonly ConcurrentDictionary<string, LobbyStateDto> _lobbies = new();
        private static readonly Random _random = new();

        // Yeni bir lobi odası oluşturur
        public LobbyStateDto CreateLobby(string hostName, bool isDouble, string? hostPartnerName)
        {
            string code;
            do
            {
                code = GenerateLobbyCode();
            } while (_lobbies.ContainsKey(code));

            var lobby = new LobbyStateDto
            {
                Code = code,
                HostName = hostName,
                HostPartnerName = hostPartnerName,
                IsDouble = isDouble,
                IsMatchStarted = false,
                Settings = new LobbySettingsDto()
            };

            _lobbies[code] = lobby;
            return lobby;
        }

        // Lobiye rakip/misafir olarak katılır
        public LobbyStateDto? JoinLobby(string code, string guestName, string? guestPartnerName)
        {
            code = code.ToUpperInvariant().Trim();
            if (!_lobbies.TryGetValue(code, out var lobby))
            {
                return null;
            }

            lobby.GuestName = guestName;
            lobby.GuestPartnerName = guestPartnerName;
            
            return lobby;
        }

        // Lobi maç kurallarını (game/set sayısı) günceller
        public LobbyStateDto? UpdateSettings(string code, LobbySettingsDto settings)
        {
            code = code.ToUpperInvariant().Trim();
            if (!_lobbies.TryGetValue(code, out var lobby))
            {
                return null;
            }

            lobby.Settings = settings;
            return lobby;
        }

        // Lobiyi "maç başladı" durumuna geçirir
        public LobbyStateDto? StartMatch(string code)
        {
            code = code.ToUpperInvariant().Trim();
            if (!_lobbies.TryGetValue(code, out var lobby))
            {
                return null;
            }

            lobby.IsMatchStarted = true;
            return lobby;
        }

        // Koda göre lobi durumunu çeker
        public LobbyStateDto? GetLobby(string code)
        {
            code = code.ToUpperInvariant().Trim();
            _lobbies.TryGetValue(code, out var lobby);
            return lobby;
        }

        // Lobi odasını bellekten siler
        public void RemoveLobby(string code)
        {
            code = code.ToUpperInvariant().Trim();
            _lobbies.TryRemove(code, out _);
        }

        // 6 haneli rastgele benzersiz bir kod üretir
        private string GenerateLobbyCode()
        {
            const string chars = "ABCDEFGHIJKLMNOPQRSTUVWXYZ0123456789";
            return new string(Enumerable.Repeat(chars, 6)
                .Select(s => s[_random.Next(s.Length)]).ToArray());
        }
    }
}
