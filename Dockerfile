# Build stage - Use the SDK image to build the application
FROM mcr.microsoft.com/dotnet/framework/sdk:4.7.2-windowsservercore-ltsc2019 AS build-env
WORKDIR /app

# Copy solution and project files for package restore
COPY eShopModernizedWebForms.sln ./
COPY src/eShopModernizedWebForms/eShopModernizedWebForms.csproj ./src/eShopModernizedWebForms/
COPY src/eShopModernizedWebForms/packages.config ./src/eShopModernizedWebForms/

# Restore NuGet packages
RUN nuget restore eShopModernizedWebForms.sln

# Copy all source code
COPY src/eShopModernizedWebForms/ ./src/eShopModernizedWebForms/

# Build and publish the application
RUN msbuild src/eShopModernizedWebForms/eShopModernizedWebForms.csproj `
    /p:Configuration=Release `
    /p:Platform="Any CPU" `
    /p:PublishProfile=FolderProfile `
    /p:WebPublishMethod=FileSystem `
    /p:PublishUrl=C:\publish `
    /p:DeployOnBuild=true

# Runtime stage - Use the ASP.NET runtime image
FROM mcr.microsoft.com/dotnet/framework/aspnet:4.7.2-windowsservercore-ltsc2019

# Set working directory
WORKDIR /inetpub/wwwroot

# Remove default website and setup IIS
RUN powershell -NoProfile -Command \
    Remove-Website -Name 'Default Web Site'; \
    New-Website -Name 'eShopWebForms' -Port 80 -PhysicalPath 'C:\inetpub\wwwroot'

# Copy published application from build stage
COPY --from=build-env /publish ./

# Expose port 80
EXPOSE 80

# Set default environment variables for container configuration
ENV UseMockData=true \
    UseAzureStorage=false \
    UseAzureManagedIdentity=false \
    UseCustomizationData=false \
    UseAzureActiveDirectory=false

# Configure IIS to run in the foreground
ENTRYPOINT ["C:\\ServiceMonitor.exe", "w3svc"]