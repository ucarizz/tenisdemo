using Microsoft.AspNetCore.Authorization;
using Microsoft.AspNetCore.Mvc;
using Microsoft.EntityFrameworkCore;
using System;
using System.Linq;
using System.Security.Claims;
using System.Threading.Tasks;
using TenisApi.Application.DTOs;
using TenisApi.Domain.Entities;
using TenisApi.Infrastructure.Persistence;

namespace TenisApi.Controllers
{
    [Authorize]
    [ApiController]
    [Route("v1/swing")]
    public class SwingController : ControllerBase
    {
        private readonly TenisDbContext _context;

        public SwingController(TenisDbContext context)
        {
            _context = context;
        }

        [HttpPost("record")]
        public async Task<IActionResult> RecordSwing([FromBody] CreateSwingRecordRequest request)
        {
            var userIdStr = User.FindFirst(ClaimTypes.NameIdentifier)?.Value;
            if (string.IsNullOrEmpty(userIdStr) || !int.TryParse(userIdStr, out var userId))
            {
                return Unauthorized(new { message = "Geçersiz kullanıcı oturumu." });
            }

            var userExists = await _context.Users.AnyAsync(u => u.Id == userId);
            if (!userExists)
            {
                return NotFound(new { message = "Kullanıcı bulunamadı." });
            }

            var record = new SwingRecord(
                userId,
                request.SpeedKmh,
                request.AccelerationG,
                request.SwingType,
                request.RecordedAt
            );

            _context.SwingRecords.Add(record);
            await _context.SaveChangesAsync();

            return Ok(new SwingRecordResponse
            {
                Id = record.Id,
                UserId = record.UserId,
                SpeedKmh = record.SpeedKmh,
                AccelerationG = record.AccelerationG,
                SwingType = record.SwingType,
                RecordedAt = record.RecordedAt
            });
        }

        [HttpGet("history")]
        public async Task<IActionResult> GetSwingHistory([FromQuery] int limit = 50)
        {
            var userIdStr = User.FindFirst(ClaimTypes.NameIdentifier)?.Value;
            if (string.IsNullOrEmpty(userIdStr) || !int.TryParse(userIdStr, out var userId))
            {
                return Unauthorized(new { message = "Geçersiz kullanıcı oturumu." });
            }

            var records = await _context.SwingRecords
                .Where(r => r.UserId == userId)
                .OrderByDescending(r => r.RecordedAt)
                .Take(limit)
                .Select(r => new SwingRecordResponse
                {
                    Id = r.Id,
                    UserId = r.UserId,
                    SpeedKmh = r.SpeedKmh,
                    AccelerationG = r.AccelerationG,
                    SwingType = r.SwingType,
                    RecordedAt = r.RecordedAt
                })
                .ToListAsync();

            return Ok(records);
        }
    }
}
