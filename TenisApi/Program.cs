using Microsoft.AspNetCore.Authentication.JwtBearer;
using Microsoft.IdentityModel.Tokens;
using System.Text;
using Microsoft.EntityFrameworkCore;
using TenisApi.Application.Services;
using TenisApi.Domain.Entities;
using TenisApi.Domain.Repositories;
using TenisApi.Infrastructure.Persistence;
using TenisApi.Infrastructure.Persistence.Repositories;

var builder = WebApplication.CreateBuilder(args);

// DbContext configuration using PostgreSQL
var connectionString = builder.Configuration.GetConnectionString("DefaultConnection");
builder.Services.AddDbContext<TenisDbContext>(options =>
    options.UseNpgsql(connectionString));

// Register Repositories and Services (Dependency Injection)
builder.Services.AddScoped<ILeagueMatchRepository, LeagueMatchRepository>();
builder.Services.AddScoped<ILeagueService, LeagueService>();
builder.Services.AddScoped<IAuthService, AuthService>();

// Configure JWT Authentication
var jwtSettings = builder.Configuration.GetSection("JwtSettings");
var key = Encoding.UTF8.GetBytes(jwtSettings.GetValue<string>("Key") ?? "DefaultTennisSuperSecretSecureKey1234567890!");

builder.Services.AddAuthentication(options =>
{
    options.DefaultAuthenticateScheme = JwtBearerDefaults.AuthenticationScheme;
    options.DefaultChallengeScheme = JwtBearerDefaults.AuthenticationScheme;
})
.AddJwtBearer(options =>
{
    options.TokenValidationParameters = new TokenValidationParameters
    {
        ValidateIssuer = true,
        ValidateAudience = true,
        ValidateLifetime = true,
        ValidateIssuerSigningKey = true,
        ValidIssuer = jwtSettings.GetValue<string>("Issuer") ?? "TenisApi",
        ValidAudience = jwtSettings.GetValue<string>("Audience") ?? "tenisdemo",
        IssuerSigningKey = new SymmetricSecurityKey(key),
        ClockSkew = TimeSpan.Zero
    };
});

builder.Services.AddControllers()
    .AddJsonOptions(options =>
    {
        options.JsonSerializerOptions.PropertyNamingPolicy = System.Text.Json.JsonNamingPolicy.SnakeCaseLower;
    });

builder.Services.AddOpenApi();

var app = builder.Build();

if (app.Environment.IsDevelopment())
{
    app.MapOpenApi();
}

app.UseAuthentication();
app.UseAuthorization();
app.MapControllers();

// Automatic database migration and seed data on startup
using (var scope = app.Services.CreateScope())
{
    var services = scope.ServiceProvider;
    try
    {
        var context = services.GetRequiredService<TenisDbContext>();
        await context.Database.MigrateAsync();
        
        if (!await context.Users.AnyAsync(u => u.Email == "admin@tennis.com"))
        {
            var adminPasswordHash = PasswordHasher.HashPassword("admin123");
            var adminUser = new User("admin@tennis.com", adminPasswordHash, "Admin User");
            await context.Users.AddAsync(adminUser);
            await context.SaveChangesAsync();
        }
        
        if (!await context.Matches.AnyAsync())
        {
            var match1 = new LeagueMatch("Murat Uçar", "Ahmet Yılmaz", "23.07.2026 - 19:30");
            match1.CompleteMatch("6-4, 4-6, 10-8", new List<MatchPointHistory>());
            
            var match2 = new LeagueMatch("Mehmet Demir", "Burak Kaya", "24.07.2026 - 18:00");
            var match3 = new LeagueMatch("Can Özkan", "Murat Uçar", "26.07.2026 - 20:00");
            
            await context.Matches.AddRangeAsync(match1, match2, match3);
            await context.SaveChangesAsync();
        }
    }
    catch (Exception ex)
    {
        var logger = services.GetRequiredService<ILogger<Program>>();
        logger.LogError(ex, "Veritabanı göçü veya veri ekleme sırasında bir hata oluştu.");
    }
}

app.Run();
