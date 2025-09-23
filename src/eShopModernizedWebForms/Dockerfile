# Build stage - Use the SDK image to build the application
FROM mcr.microsoft.com/dotnet/framework/sdk:4.7.2-windowsservercore-ltsc2019 AS build-env
WORKDIR /app

# Copy solution and project files
COPY eShopModernizedWebForms.sln ./
COPY src/eShopModernizedWebForms/eShopModernizedWebForms.csproj ./src/eShopModernizedWebForms/
COPY src/eShopModernizedWebForms/packages.config ./src/eShopModernizedWebForms/

# Restore NuGet packages
RUN nuget restore eShopModernizedWebForms.sln

# Copy source code
COPY src/eShopModernizedWebForms/ ./src/eShopModernizedWebForms/

# Build the application
RUN msbuild src/eShopModernizedWebForms/eShopModernizedWebForms.csproj /p:Configuration=Release /p:Platform="Any CPU" /p:OutputPath=../../publish

# Runtime stage - Use the ASP.NET runtime image
FROM mcr.microsoft.com/dotnet/framework/aspnet:4.7.2-windowsservercore-ltsc2019
WORKDIR /inetpub/wwwroot

# Remove default website
RUN Remove-Website -Name "Default Web Site"

# Create new website
RUN New-Website -Name "eShopWebForms" -Port 80 -PhysicalPath "C:\inetpub\wwwroot"

# Copy application files from build stage
COPY --from=build-env /app/publish .

# Expose port 80
EXPOSE 80

# Set environment variables for container configuration
ENV UseMockData=true
ENV UseAzureStorage=false
ENV UseAzureManagedIdentity=false
ENV UseCustomizationData=false

# Configure IIS to run in the foreground
ENTRYPOINT ["C:\\ServiceMonitor.exe", "w3svc"]
