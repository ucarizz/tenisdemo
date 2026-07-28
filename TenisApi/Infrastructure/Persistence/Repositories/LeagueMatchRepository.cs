using System.Collections.Generic;
using System.Threading.Tasks;
using Microsoft.EntityFrameworkCore;
using TenisApi.Domain.Entities;
using TenisApi.Domain.Repositories;

namespace TenisApi.Infrastructure.Persistence.Repositories
{
    public class LeagueMatchRepository : ILeagueMatchRepository
    {
        private readonly TenisDbContext _context;

        public LeagueMatchRepository(TenisDbContext context)
        {
            _context = context;
        }

        public async Task<LeagueMatch?> GetByIdAsync(int id)
        {
            return await _context.Matches.FindAsync(id);
        }

        public async Task<IEnumerable<LeagueMatch>> GetAllAsync()
        {
            return await _context.Matches.ToListAsync();
        }

        public async Task AddAsync(LeagueMatch match)
        {
            await _context.Matches.AddAsync(match);
            await _context.SaveChangesAsync();
        }

        public async Task UpdateAsync(LeagueMatch match)
        {
            _context.Matches.Update(match);
            await _context.SaveChangesAsync();
        }

        public async Task DeleteAsync(LeagueMatch match)
        {
            _context.Matches.Remove(match);
            await _context.SaveChangesAsync();
        }
    }
}
