# Build stage
FROM mcr.microsoft.com/dotnet/sdk:10.0 AS build
WORKDIR /src

# Copy csproj and restore dependencies
COPY ["TenisApi.csproj", "./"]
RUN dotnet restore "TenisApi.csproj"

# Copy everything else and build
COPY . .
RUN dotnet publish "TenisApi.csproj" -c Release -o /app/publish /p:UseAppHost=false

# Runtime stage
FROM mcr.microsoft.com/dotnet/aspnet:10.0 AS final
WORKDIR /app
EXPOSE 5200
ENV ASPNETCORE_URLS=http://+:5200
COPY --from=build /app/publish .
ENTRYPOINT ["dotnet", "TenisApi.dll"]
