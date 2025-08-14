# eShopLegacyWebFormsSolution

eShopLegacyWebFormsSolution is a legacy .NET Framework 4.7.2 ASP.NET Web Forms e-commerce catalog management application. The application provides CRUD operations for managing product catalogs, supports both mock data and SQL Server database backends, and includes Azure cloud integrations.

Always reference these instructions first and fallback to search or bash commands only when you encounter unexpected information that does not match the info here.

## Working Effectively

### Prerequisites and Setup
- **CRITICAL**: This application requires Windows development environment with Visual Studio or Build Tools for Visual Studio 2017/2019/2022
- Install .NET Framework 4.7.2 SDK or later: `https://dotnet.microsoft.com/download/dotnet-framework/net472`
- Install Visual Studio 2019/2022 with ASP.NET and web development workload
- **Linux/Mac limitations**: This is a .NET Framework (not .NET Core) application - it CANNOT be built on Linux/Mac without using Windows containers

### Build Process
- **CRITICAL**: NEVER CANCEL builds - they can take 5-15 minutes depending on NuGet package restoration
- Open solution: `eShopModernizedWebForms.sln` in Visual Studio
- Restore NuGet packages: Right-click solution → "Restore NuGet Packages" (takes 3-5 minutes, NEVER CANCEL)
- Build solution: Build → Build Solution or `Ctrl+Shift+B` (takes 2-5 minutes, NEVER CANCEL)
- Alternative command line build: `MSBuild eShopModernizedWebForms.sln /p:Configuration=Debug` (timeout: 10+ minutes)

### Running the Application
- **ALWAYS run with mock data first**: Set `UseMockData=true` in Web.config (line 24) - this is the default
- Debug in Visual Studio: Press F5 or Debug → Start Debugging
- Application runs on: `https://localhost:44322/` (IIS Express)
- **Default port conflicts**: If port 44322 is occupied, Visual Studio will auto-assign a new port
- **Authentication**: Set `UseAzureActiveDirectory=false` in Web.config for development without Azure AD

### Database Setup (Optional)
- **Mock data recommended**: Application works perfectly with mock data for development
- For SQL Server: Update connection string in `Web.config` line 20
- Database auto-creates on first run using Entity Framework Code First migrations
- Connection string format: `Server=.;Database=eShopCatalog;Integrated Security=true;`

## Validation

### Manual Testing Scenarios
After making changes, ALWAYS run through these complete end-to-end scenarios:

1. **Catalog Viewing**: Navigate to home page, verify product list displays with images and data
2. **Product Creation**: Click "Create New" → Fill form → Upload image → Save → Verify product appears in list
3. **Product Editing**: Click "Edit" on any product → Modify data → Save → Verify changes persist
4. **Product Details**: Click "Details" to view full product information
5. **Product Deletion**: Click "Delete" → Confirm → Verify product removed from list
6. **Pagination**: Navigate between pages if more than 10 products exist

### Key URLs to Test
- Main catalog: `https://localhost:44322/`
- Create product: `https://localhost:44322/Catalog/Create`
- Edit product: `https://localhost:44322/Catalog/Edit/{id}`
- Product details: `https://localhost:44322/Catalog/Details/{id}`

### Testing with Mock Data
- Application loads with 12 pre-configured catalog items (.NET branded merchandise)
- All CRUD operations work in-memory without database
- Image uploads work with local file storage
- Perfect for development and testing without database dependencies

## Build and Test Timing Expectations

- **NuGet Package Restore**: 3-5 minutes. NEVER CANCEL. Set timeout to 10+ minutes.
- **Solution Build**: 2-5 minutes. NEVER CANCEL. Set timeout to 10+ minutes.
- **Application Startup**: 30-60 seconds for first run, 10-15 seconds for subsequent runs
- **Image Upload**: 5-10 seconds for typical image files (1-5MB)

## Architecture and Key Components

### Project Structure
```
src/eShopModernizedWebForms/
├── App_Start/           # Application configuration and startup
├── Catalog/            # Product CRUD pages and logic
├── Content/            # CSS stylesheets and design assets
├── Models/             # Entity Framework models and data context
├── Scripts/            # JavaScript libraries and custom scripts
├── Services/           # Business logic layer (real and mock implementations)
├── Pics/               # Product image storage
└── Setup/              # Sample data CSV files
```

### Key Files and Their Purpose
- `Global.asax.cs`: Application startup, dependency injection, database initialization
- `Web.config`: Configuration including connection strings, mock data settings, Azure settings
- `Default.aspx`: Main product catalog listing page
- `Models/CatalogDBContext.cs`: Entity Framework database context
- `Services/CatalogServiceMock.cs`: Mock data service (enabled by default)
- `Services/CatalogService.cs`: Real database service
- `Models/Infrastructure/PreconfiguredData.cs`: Mock catalog data definitions

### Configuration Settings
Key Web.config app settings:
- `UseMockData=true`: Use in-memory mock data (recommended for development)
- `UseAzureStorage=false`: Use local file storage for images  
- `UseAzureActiveDirectory=false`: Disable Azure AD authentication (recommended for development)
- `UseCustomizationData=false`: Use built-in sample data
- `UseAzureManagedIdentity=false`: Disable Azure managed identity for local development

### Common Development Tasks
- **Adding new products**: Use mock data approach in `PreconfiguredData.cs` or via UI
- **Changing styling**: Modify files in `Content/` directory (custom.css, site.css)
- **Adding business logic**: Extend services in `Services/` directory
- **Database changes**: Modify models in `Models/` directory, EF will auto-migrate

### Technology Stack
- **Framework**: ASP.NET Web Forms 4.7.2
- **Database**: Entity Framework 6.x with SQL Server (LocalDB or full SQL Server)
- **Dependency Injection**: Autofac
- **Frontend**: Bootstrap 4.3.1, jQuery 3.4.1
- **Logging**: log4net
- **Azure**: Application Insights, Key Vault, Blob Storage (optional)

### Mock Data Details
Default catalog includes 12 items:
- .NET Bot Black Hoodie ($19.50)
- .NET Black & White Mug ($8.50) 
- Prism White T-Shirt ($12.00)
- And 9 other .NET-branded merchandise items

Brands: Azure, .NET, Visual Studio, SQL Server, Other
Types: Mug, T-Shirt, Sheet, USB Memory Stick

## Container Support Limitations

### Docker Considerations
- **Windows containers only**: Uses `mcr.microsoft.com/dotnet/framework/aspnet:4.7.2` base image
- **Linux limitation**: Cannot build or run on Linux Docker hosts
- **Development**: Use Visual Studio for development, Docker for production deployment on Windows hosts
- Build context: `docker build -f src/eShopModernizedWebForms/Dockerfile .`

## Troubleshooting Common Issues

### Build Failures
- **Missing Windows WebApp targets**: Install Visual Studio with web development workload
- **NuGet package issues**: Delete `packages/` folder and restore packages
- **Port conflicts**: Change port in project properties or let Visual Studio auto-assign

### Runtime Issues  
- **Database errors**: Switch to mock data (`UseMockData=true`) for development
- **Missing images**: Check `Pics/` directory has default.png and sample images
- **Slow performance**: First run includes JIT compilation and can be slow

### Getting Help
- Check `log4Net.xml` configuration for detailed logging
- Application Insights integration available for Azure-hosted deployments
- Mock data service eliminates most database-related issues during development

Always validate changes by running through the complete catalog management workflow: view → create → edit → delete products.