﻿using CloudinaryDotNet;
using Cosmetics.DTO.User;
using Cosmetics.DTO.YouCamApiSettings;
using Cosmetics.Interfaces;
using Cosmetics.Models;
using Cosmetics.Repositories;
using Cosmetics.Repositories.Interface;
using Cosmetics.Repositories.UnitOfWork;
using Cosmetics.Service.Affiliate;
using Cosmetics.Service.Affiliate.Interface;
using Cosmetics.Service.Chatbot;
using Cosmetics.Service.Gemini;


//using Cosmetics.Service.Affiliate;
using Cosmetics.Service.OTP;
using Cosmetics.Service.Payment;
using Cosmetics.Service.SkinAnalysisService;
using Microsoft.AspNetCore.Authentication.Cookies;
using Microsoft.AspNetCore.Authentication.JwtBearer;
using Microsoft.EntityFrameworkCore;
using Microsoft.IdentityModel.Tokens;
using Microsoft.OpenApi.Models;
using Net.payOS;
using System.Text;



var builder = WebApplication.CreateBuilder(args);
// JWT Configuration
//builder.WebHost.ConfigureKestrel(options =>
//{
//    options.ListenAnyIP(5192); // Cho phép HTTP
//    options.ListenAnyIP(7191, listenOptions => listenOptions.UseHttps()); // Cho phép HTTPS
//});
builder.Services.Configure<AppSetting>(builder.Configuration.GetSection("AppSettings"));
var secretKey = builder.Configuration["AppSettings:SecretKey"];
var secretKeyBytes = Encoding.UTF8.GetBytes(secretKey);

builder.Services.AddAuthentication(options =>
{
    options.DefaultAuthenticateScheme = JwtBearerDefaults.AuthenticationScheme;
    options.DefaultChallengeScheme = JwtBearerDefaults.AuthenticationScheme;
})
.AddJwtBearer(JwtBearerDefaults.AuthenticationScheme, options =>
{
    options.TokenValidationParameters = new TokenValidationParameters
    {
        ValidateIssuer = false,
        ValidateAudience = false,
        ValidateIssuerSigningKey = true,
        IssuerSigningKey = new SymmetricSecurityKey(secretKeyBytes),
        ClockSkew = TimeSpan.Zero,
    };
})
.AddCookie(CookieAuthenticationDefaults.AuthenticationScheme, options =>
{
    options.LoginPath = "/Account/Login";
    options.ExpireTimeSpan = TimeSpan.FromHours(3); // Set cookie expiration time to 3 hours
    options.SlidingExpiration = true;
});

// CORS Configuration
builder.Services.AddCors(opts =>
{
    opts.AddPolicy("corspolicy", build =>
    {
        build.AllowAnyOrigin().AllowAnyMethod().AllowAnyHeader();
    });
});

// Swagger Configuration
builder.Services.AddSwaggerGen(option =>
{
    option.SwaggerDoc("v1", new OpenApiInfo { Title = "Demo API", Version = "v1" });
    option.AddSecurityDefinition("Bearer", new OpenApiSecurityScheme
    {
        In = ParameterLocation.Header,
        Description = "Please enter a valid token",
        Name = "Authorization",
        Type = SecuritySchemeType.Http,
        BearerFormat = "JWT",
        Scheme = "Bearer"
    });
    option.AddSecurityRequirement(new OpenApiSecurityRequirement
                {
                    {
                        new OpenApiSecurityScheme
                        {
                            Reference = new OpenApiReference
                            {
                                Type = ReferenceType.SecurityScheme,
                                Id = "Bearer"
                            }
                        },
                        new string[]{}
                    }
                });
    option.EnableAnnotations();
});







builder.Services.AddDbContext<ComedicShopDBContext>(options =>
{
    options.UseSqlServer(builder.Configuration.GetConnectionString("DefaultConnection"));
});

builder.Services.AddAutoMapper(AppDomain.CurrentDomain.GetAssemblies());

// Add IHttpContextAccessor
builder.Services.AddHttpContextAccessor();
builder.Services.AddScoped<IEmailService, EmailService>(sp => new EmailService(
    smtpServer: "smtp.gmail.com",
    smtpPort: 587,
    smtpEmail: "courtb454@gmail.com",
    smtpPassword: "riqc mncz rljd wjrv",
    logger: sp.GetRequiredService<ILogger<EmailService>>()
));


builder.Services.AddControllers()
    .AddNewtonsoftJson(options =>
{
    options.SerializerSettings.ReferenceLoopHandling = Newtonsoft.Json.ReferenceLoopHandling.Ignore;
    options.SerializerSettings.DateTimeZoneHandling = Newtonsoft.Json.DateTimeZoneHandling.Utc;
    options.SerializerSettings.DateFormatHandling = Newtonsoft.Json.DateFormatHandling.IsoDateFormat;
});

//Cloudinary
var cloudinaryAccount = new Account(
        builder.Configuration["Cloudinary:CloudName"],
        builder.Configuration["Cloudinary:ApiKey"],
        builder.Configuration["Cloudinary:ApiSecret"]
    );


var cloudinary = new Cloudinary(cloudinaryAccount);
builder.Services.AddSingleton(cloudinary);

// Add Repositories and Interfaces
builder.Services.AddScoped(typeof(IGenericRepository<>), typeof(GenericRepository<>));
builder.Services.AddScoped<IUnitOfWork, UnitOfWork>();
builder.Services.AddScoped<IProductRepository, ProductRepository>();
builder.Services.AddScoped<ICategoryRepository, CategoryRepository>();
builder.Services.AddScoped<IBrandRepository, BrandRepository>();
builder.Services.AddScoped<IOrderRepository, OrderRepository>();
builder.Services.AddScoped<IOrderDetailRepository, OrderDetailRepository>();
builder.Services.AddScoped<IUserRepository, UserRepository>();
builder.Services.AddScoped<IAffiliateRepository, AffiliateRepository>();
builder.Services.AddScoped<IAffiliateService, AffiliateService>();
builder.Services.AddScoped<IPaymentTransactionRepository, PaymentTransactionRepository>();
builder.Services.AddScoped<ICartDetailRepository, CartDetailRepository>();
builder.Services.AddScoped<IKOLVideoRepository, KOLVideoRepository>();
builder.Services.AddScoped<IAffiliateProfileRepository, AffiliateProfileRepository>();
builder.Services.AddControllers();
builder.Services.AddHttpClient<GeminiChatService>();
builder.Services.AddScoped<IChatbotService, ChatbotService>();
// Chat History Services
builder.Services.AddScoped<IChatSessionRepository, ChatSessionRepository>();
builder.Services.AddScoped<IChatMessageRepository, ChatMessageRepository>();
builder.Services.AddScoped<IChatService, ChatService>();
builder.Services.AddMemoryCache();
builder.Services.AddSingleton<IConfiguration>(builder.Configuration);
//payOS
builder.Services.AddSingleton<PayOS>(sp =>
	new PayOS(
		clientId: builder.Configuration["PayOS:ClientId"],
		apiKey: builder.Configuration["PayOS:ApiKey"],
		checksumKey: builder.Configuration["PayOS:ChecksumKey"]
	));
builder.Services.AddScoped<IPaymentService, PayOSService>();
//builder.Services.AddScoped<IAffiliateLinkRepository, AffiliateLinkRepository>();
//Add Services
builder.Services.AddHostedService<ExpiredOtpCleanerService>();
// Đăng ký IAffiliateService với AffiliateService
//builder.Services.AddScoped<IAffiliateService, AffiliateService>();

// Đăng ký IProductService (nếu đã có ProductService)
builder.Services.AddScoped<IProductService, ProductService>();
builder.Services.AddHttpClient<ISkinAnalysisService, SkinAnalysisService>(client =>
{
    string? baseUrl = builder.Configuration["YouCamApi:BaseUrl"];
    client.BaseAddress = string.IsNullOrEmpty(baseUrl) ? null : new Uri(baseUrl);
});





// Learn more about configuring Swagger/OpenAPI at
builder.Services.AddEndpointsApiExplorer();
builder.Services.AddSwaggerGen();

// Other service registrations

var app = builder.Build();
// Configure middleware, static files, authentication, authorization, etc.

    app.UseCors("corspolicy");
// app.UseHttpsRedirection();
//app.UseSwagger();
//app.UseSwaggerUI();



// Configure the HTTP request pipeline.
//if (app.Environment.IsDevelopment())
//{
  
//}
app.UseSwagger();
app.UseSwaggerUI();
//app.UseHttpsRedirection();

app.UseAuthorization();

app.MapControllers();

app.Run();
