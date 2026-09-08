using System;
using System.Collections.Concurrent;
using System.Linq;
using TenisApi.Application.DTOs;

namespace TenisApi.Application.Services
{
    public class LobbyManager
    {
        private readonly ConcurrentDictionary<string, LobbyStateDto> _lobbies = new();
        private readonly ConcurrentDictionary<string, string> _connectionToLobby = new();
        private static readonly Random _random = new();

        public void AssociateConnection(string connectionId, string lobbyCode)
        {
            _connectionToLobby[connectionId] = lobbyCode.ToUpperInvariant().Trim();
        }

        public string? GetLobbyCodeByConnection(string connectionId)
        {
            _connectionToLobby.TryGetValue(connectionId, out var lobbyCode);
            return lobbyCode;
        }

        public void RemoveConnection(string connectionId)
        {
            _connectionToLobby.TryRemove(connectionId, out _);
        }

        // Yeni bir lobi odası oluşturur
        public LobbyStateDto CreateLobby(string hostName, bool isDouble, string? hostPartnerName, string? hostProfileImageUrl, string? connectionId = null)
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
                HostProfileImageUrl = hostProfileImageUrl,
                IsDouble = isDouble,
                IsMatchStarted = false,
                Settings = new LobbySettingsDto()
            };

            // Host oyuncusunu Slot 0 olarak ekle
            lobby.Players.Add(new LobbyPlayerDto
            {
                ConnectionId = connectionId ?? string.Empty,
                Name = hostName,
                ProfileImageUrl = hostProfileImageUrl,
                Team = 1,
                SlotIndex = 0,
                IsHost = true,
                IsReady = true
            });

            // Eğer kurucu çiftler için partner ismini baştan metin olarak girdiyse yedek oyuncu olarak ekle
            if (isDouble && !string.IsNullOrWhiteSpace(hostPartnerName))
            {
                lobby.Players.Add(new LobbyPlayerDto
                {
                    ConnectionId = string.Empty,
                    Name = hostPartnerName,
                    Team = 1,
                    SlotIndex = 1,
                    IsHost = false,
                    IsReady = true
                });
            }

            _lobbies[code] = lobby;
            return lobby;
        }

        // Lobiye rakip/misafir olarak katılır (Eski metot uyumluluğu ile)
        public LobbyStateDto? JoinLobby(string code, string guestName, string? guestPartnerName, string? guestProfileImageUrl, string? connectionId = null)
        {
            code = code.ToUpperInvariant().Trim();
            if (!_lobbies.TryGetValue(code, out var lobby))
            {
                return null;
            }

            lobby.GuestName = guestName;
            lobby.GuestPartnerName = guestPartnerName;
            lobby.GuestProfileImageUrl = guestProfileImageUrl;

            // Slot 2'ye (Takım 2 Oyuncu 1) yerleştir
            var existingGuest = lobby.Players.FirstOrDefault(p => p.SlotIndex == 2);
            if (existingGuest == null)
            {
                lobby.Players.Add(new LobbyPlayerDto
                {
                    ConnectionId = connectionId ?? string.Empty,
                    Name = guestName,
                    ProfileImageUrl = guestProfileImageUrl,
                    Team = 2,
                    SlotIndex = 2,
                    IsHost = false,
                    IsReady = true
                });
            }
            else
            {
                existingGuest.Name = guestName;
                existingGuest.ProfileImageUrl = guestProfileImageUrl;
                if (!string.IsNullOrEmpty(connectionId)) existingGuest.ConnectionId = connectionId;
            }

            // Çiftler için misafir ortağı varsa Slot 3'e ekle
            if (lobby.IsDouble && !string.IsNullOrWhiteSpace(guestPartnerName))
            {
                var existingGuestPartner = lobby.Players.FirstOrDefault(p => p.SlotIndex == 3);
                if (existingGuestPartner == null)
                {
                    lobby.Players.Add(new LobbyPlayerDto
                    {
                        ConnectionId = string.Empty,
                        Name = guestPartnerName,
                        Team = 2,
                        SlotIndex = 3,
                        IsHost = false,
                        IsReady = true
                    });
                }
                else
                {
                    existingGuestPartner.Name = guestPartnerName;
                }
            }

            SyncLegacyFields(lobby);
            return lobby;
        }

        // Belirli veya boş bir slota oyuncu katılımı (4 kişilik yeni lobi sistemi)
        public LobbyStateDto? JoinLobbySlot(string code, string name, string? profileImageUrl, string connectionId, int? requestedSlotIndex = null)
        {
            code = code.ToUpperInvariant().Trim();
            if (!_lobbies.TryGetValue(code, out var lobby))
            {
                return null;
            }

            // Eğer oyuncu zaten lobideyse güncelle
            var existing = lobby.Players.FirstOrDefault(p => p.ConnectionId == connectionId);
            if (existing != null)
            {
                existing.Name = name;
                existing.ProfileImageUrl = profileImageUrl;
                if (requestedSlotIndex.HasValue && requestedSlotIndex.Value != existing.SlotIndex)
                {
                    SwitchSlot(code, connectionId, requestedSlotIndex.Value);
                }
                return lobby;
            }

            int maxSlots = lobby.IsDouble ? 4 : 2;
            int targetSlot = -1;

            if (requestedSlotIndex.HasValue && requestedSlotIndex.Value < maxSlots)
            {
                // İstenen slot boş mu veya sadece isim girilmiş sahte oyuncu mu?
                var occupant = lobby.Players.FirstOrDefault(p => p.SlotIndex == requestedSlotIndex.Value);
                if (occupant == null || string.IsNullOrEmpty(occupant.ConnectionId))
                {
                    if (occupant != null) lobby.Players.Remove(occupant);
                    targetSlot = requestedSlotIndex.Value;
                }
            }

            if (targetSlot == -1)
            {
                // Boş slot ara (Önce Takım 2, sonra Takım 1 partner slotu)
                var candidateSlots = lobby.IsDouble ? new[] { 2, 1, 3 } : new[] { 2, 1 };
                foreach (var s in candidateSlots)
                {
                    var occupant = lobby.Players.FirstOrDefault(p => p.SlotIndex == s);
                    if (occupant == null || string.IsNullOrEmpty(occupant.ConnectionId))
                    {
                        if (occupant != null) lobby.Players.Remove(occupant);
                        targetSlot = s;
                        break;
                    }
                }
            }

            if (targetSlot == -1)
            {
                // Lobi tamamen dolu
                return null;
            }

            int team = (targetSlot == 0 || targetSlot == 1) ? 1 : 2;

            lobby.Players.Add(new LobbyPlayerDto
            {
                ConnectionId = connectionId,
                Name = name,
                ProfileImageUrl = profileImageUrl,
                Team = team,
                SlotIndex = targetSlot,
                IsHost = false,
                IsReady = true
            });

            SyncLegacyFields(lobby);
            return lobby;
        }

        // Slot/Takım değiştirme (Örn: Takım A'dan Takım B'ye geçme)
        public LobbyStateDto? SwitchSlot(string code, string connectionId, int targetSlotIndex)
        {
            code = code.ToUpperInvariant().Trim();
            if (!_lobbies.TryGetValue(code, out var lobby))
            {
                return null;
            }

            int maxSlots = lobby.IsDouble ? 4 : 2;
            if (targetSlotIndex < 0 || targetSlotIndex >= maxSlots)
            {
                return null;
            }

            var player = lobby.Players.FirstOrDefault(p => p.ConnectionId == connectionId);
            if (player == null)
            {
                return null;
            }

            var occupant = lobby.Players.FirstOrDefault(p => p.SlotIndex == targetSlotIndex);
            if (occupant != null && !string.IsNullOrEmpty(occupant.ConnectionId) && occupant != player)
            {
                // Hedef slot zaten başka bir gerçek oyuncu tarafından dolu
                return null;
            }

            if (occupant != null && occupant != player)
            {
                lobby.Players.Remove(occupant);
            }

            player.SlotIndex = targetSlotIndex;
            player.Team = (targetSlotIndex == 0 || targetSlotIndex == 1) ? 1 : 2;

            // Eğer kurucu slot 0'ı bıraktıysa host durumunu güncelle
            if (player.IsHost && targetSlotIndex != 0)
            {
                // Slot 0'a biri geçerse host olabilir, veya kurucu ünvanı kalabilir
            }

            SyncLegacyFields(lobby);
            return lobby;
        }

        // Oyuncuyu lobiden çıkarma / bağlantı koptuğunda
        public (string? code, LobbyStateDto? lobby) RemovePlayerByConnection(string connectionId)
        {
            if (!_connectionToLobby.TryRemove(connectionId, out var code))
            {
                return (null, null);
            }

            if (_lobbies.TryGetValue(code, out var lobby))
            {
                var player = lobby.Players.FirstOrDefault(p => p.ConnectionId == connectionId);
                if (player != null)
                {
                    lobby.Players.Remove(player);

                    // Eğer hiç gerçek oyuncu kalmadıysa lobiyi sil
                    if (!lobby.Players.Any(p => !string.IsNullOrEmpty(p.ConnectionId)))
                    {
                        _lobbies.TryRemove(code, out _);
                        return (code, null);
                    }

                    // Host çıktıysa kalan ilk oyuncuyu host yap
                    if (player.IsHost && lobby.Players.Any())
                    {
                        var newHost = lobby.Players.First();
                        newHost.IsHost = true;
                    }

                    SyncLegacyFields(lobby);
                    return (code, lobby);
                }
            }

            return (code, null);
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

        // Geriye dönük uyumluluk alanlarını oyuncu listesiyle eşitler
        private static void SyncLegacyFields(LobbyStateDto lobby)
        {
            var p0 = lobby.Players.FirstOrDefault(p => p.SlotIndex == 0);
            if (p0 != null)
            {
                lobby.HostName = p0.Name;
                lobby.HostProfileImageUrl = p0.ProfileImageUrl;
            }

            var p1 = lobby.Players.FirstOrDefault(p => p.SlotIndex == 1);
            if (p1 != null)
            {
                lobby.HostPartnerName = p1.Name;
            }
            else if (!lobby.IsDouble)
            {
                lobby.HostPartnerName = null;
            }

            var p2 = lobby.Players.FirstOrDefault(p => p.SlotIndex == 2 || (!lobby.IsDouble && p.SlotIndex == 1));
            if (p2 != null)
            {
                lobby.GuestName = p2.Name;
                lobby.GuestProfileImageUrl = p2.ProfileImageUrl;
            }

            var p3 = lobby.Players.FirstOrDefault(p => p.SlotIndex == 3);
            if (p3 != null)
            {
                lobby.GuestPartnerName = p3.Name;
            }
            else if (!lobby.IsDouble)
            {
                lobby.GuestPartnerName = null;
            }
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
