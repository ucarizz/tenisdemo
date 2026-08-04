using Microsoft.AspNetCore.Authentication.JwtBearer;
using Microsoft.IdentityModel.Tokens;
using System.Text;
using Microsoft.EntityFrameworkCore;
using TenisApi.Application.Services;
using TenisApi.Domain.Entities;
using TenisApi.Domain.Repositories;
using TenisApi.Infrastructure.Persistence;
using TenisApi.Infrastructure.Persistence.Repositories;
using TenisApi.Hubs;
using Serilog;
using Serilog.Sinks.Graylog;
using TenisApi.Infrastructure.Middlewares;
using Scalar.AspNetCore;

var graylogHost = Environment.GetEnvironmentVariable("GRAYLOG_HOST") ?? "127.0.0.1";
var graylogPortString = Environment.GetEnvironmentVariable("GRAYLOG_PORT");
int graylogPort = int.TryParse(graylogPortString, out var p) ? p : 12201;

Log.Logger = new LoggerConfiguration()
    .MinimumLevel.Debug()
    .Enrich.FromLogContext()
    .WriteTo.Console()
    .WriteTo.Graylog(new GraylogSinkOptions
    {
        HostnameOrAddress = graylogHost,
        Port = graylogPort,
        TransportType = Serilog.Sinks.Graylog.Core.Transport.TransportType.Udp
    })
    .CreateLogger();

var builder = WebApplication.CreateBuilder(args);
builder.Host.UseSerilog();

// DbContext configuration using PostgreSQL
var connectionString = builder.Configuration.GetConnectionString("DefaultConnection");
builder.Services.AddDbContext<TenisDbContext>(options =>
    options.UseNpgsql(connectionString));

// Register Repositories and Services (Dependency Injection)
builder.Services.AddScoped<ILeagueMatchRepository, LeagueMatchRepository>();
builder.Services.AddScoped<ILeagueService, LeagueService>();
builder.Services.AddScoped<IAuthService, AuthService>();
builder.Services.AddSingleton<LobbyManager>();

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

builder.Services.AddSignalR();

builder.Services.AddControllers()
    .AddJsonOptions(options =>
    {
        options.JsonSerializerOptions.PropertyNamingPolicy = System.Text.Json.JsonNamingPolicy.SnakeCaseLower;
    });

builder.Services.AddOpenApi();

var app = builder.Build();

app.MapOpenApi();
app.MapScalarApiReference(options =>
{
    options.WithTitle("Tenis API Reference")
           .WithTheme(ScalarTheme.DeepSpace);
});

var uploadsPath = Path.Combine(app.Environment.ContentRootPath, "uploads");
if (!Directory.Exists(uploadsPath))
{
    Directory.CreateDirectory(uploadsPath);
}
app.UseStaticFiles(new StaticFileOptions
{
    FileProvider = new Microsoft.Extensions.FileProviders.PhysicalFileProvider(uploadsPath),
    RequestPath = "/uploads"
});

app.UseMiddleware<ExceptionHandlingMiddleware>();
app.UseMiddleware<RequestResponseLoggingMiddleware>();

app.UseSerilogRequestLogging(options =>
{
    options.EnrichDiagnosticContext = (diagnosticContext, httpContext) =>
    {
        diagnosticContext.Set("RequestHost", httpContext.Request.Host.Value);
        diagnosticContext.Set("RequestScheme", httpContext.Request.Scheme);
        if (httpContext.Request.QueryString.HasValue)
        {
            diagnosticContext.Set("QueryString", httpContext.Request.QueryString.Value);
        }
        
        var ip = httpContext.Connection.RemoteIpAddress?.ToString();
        if (!string.IsNullOrEmpty(ip))
        {
            diagnosticContext.Set("ClientIp", ip);
        }

        var userIdClaim = httpContext.User?.FindFirst(System.Security.Claims.ClaimTypes.NameIdentifier)?.Value;
        if (!string.IsNullOrEmpty(userIdClaim))
        {
            diagnosticContext.Set("UserId", userIdClaim);
        }
    };
});

app.UseAuthentication();
app.UseAuthorization();
app.MapControllers();
app.MapHub<TennisHub>("/hubs/tennis");

// Automatic database migration and seed data on startup
using (var scope = app.Services.CreateScope())
{
    var services = scope.ServiceProvider;
    var logger = services.GetRequiredService<ILogger<Program>>();
    try
    {
        var context = services.GetRequiredService<TenisDbContext>();
        
        // Retry policy for database migration on startup (max 6 retries, 5s delay)
        int retryCount = 0;
        int maxRetries = 6;
        while (retryCount < maxRetries)
        {
            try
            {
                await context.Database.MigrateAsync();
                break;
            }
            catch (Exception ex) when (retryCount < maxRetries - 1)
            {
                retryCount++;
                logger.LogWarning(ex, "Veritabanına bağlanılamadı. Yeniden deneniyor... ({RetryCount}/{MaxRetries})", retryCount, maxRetries);
                await Task.Delay(TimeSpan.FromSeconds(5));
            }
        }
        
        if (!await context.Users.AnyAsync(u => u.Email == "admin@tennis.com"))
        {
            var adminPasswordHash = PasswordHasher.HashPassword("admin123");
            var adminUser = new User("admin@tennis.com", adminPasswordHash, "Admin User");
            await context.Users.AddAsync(adminUser);
            await context.SaveChangesAsync();
        }

        if (!await context.Users.AnyAsync(u => u.Email == "user@tennis.com"))
        {
            var userPasswordHash = PasswordHasher.HashPassword("user123");
            var testUser = new User("user@tennis.com", userPasswordHash, "Test Oyuncusu");
            await context.Users.AddAsync(testUser);
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
        logger.LogError(ex, "Veritabanı göçü veya veri ekleme sırasında bir hata oluştu.");
    }
}

app.Run();
