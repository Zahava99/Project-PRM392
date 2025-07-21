using AutoMapper;
using CloudinaryDotNet;
using CloudinaryDotNet.Actions;
using Cosmetics.DTO.Product;
using Cosmetics.DTO.User;
using Cosmetics.Models;
using Cosmetics.Repositories.UnitOfWork;
using Cosmetics.Service.Affiliate.Interface;
using Microsoft.AspNetCore.Mvc;
using Microsoft.EntityFrameworkCore;

namespace Cosmetics.Controllers
{
    [Route("api/[controller]")]
    [ApiController]
    public class ProductController : ControllerBase
    {
        private readonly IUnitOfWork _unitOfWork;
        private readonly IMapper _mapper;
        private readonly IAffiliateService _affiliateService;

        public ProductController(IUnitOfWork unitOfWork, IMapper mapper, IAffiliateService affiliateService)
        {
            _unitOfWork = unitOfWork;
            _mapper = mapper;
            _affiliateService = affiliateService;
        }

        [HttpGet]
        [Route("GetAllProduct")]
        public async Task<IActionResult> GetAll(
    string search = null,
    Guid? brandId = null,
    Guid? categoryId = null,
    int? page = null,
    int? pageSize = null,
    string sortBy = null)
        {
            if (!ModelState.IsValid)
            {
                return BadRequest(new ApiResponse
                {
                    Success = false,
                    Message = "Invalid data",
                    Data = ModelState
                });
            }

            var list = await _unitOfWork.Products.GetAllAsync();
            var totalCount = list.Count();

            page ??= 1;
            pageSize ??= 10;

            var products = await _unitOfWork.Products.GetAsync(
                filter: p => (string.IsNullOrEmpty(search) || p.Name.ToLower().Contains(search.ToLower())) &&
                             (!brandId.HasValue || p.BrandId == brandId) &&
                             (!categoryId.HasValue || p.CategoryId == categoryId),
                orderBy: sortBy switch
                {
                    "a" => q => q.OrderBy(p => p.Price),
                    "d" => q => q.OrderByDescending(p => p.Price),
                    "price" => q => q.OrderBy(p => p.Price),
                    _ => q => q.OrderBy(p => p.ProductId),
                },
                page: page,
                pageSize: pageSize,
                includeOperations: new Func<IQueryable<Product>, IQueryable<Product>>[]
                {
            q => q.Include(p => p.Brand),
            q => q.Include(p => p.Category)
                }
            );

            var productDTO = _mapper.Map<List<ProductDTO>>(products);
            var response = new
            {
                TotalCount = totalCount,
                ToTalPages = (int)Math.Ceiling(totalCount / (double)pageSize.Value),
                CurrentPage = page,
                PageSize = pageSize,
                Products = productDTO
            };

            return Ok(response);
        }

        [HttpGet]
        [Route("GetProductBy/{id:guid}")]
        public async Task<IActionResult> GetById([FromRoute] Guid id)
        {
            if (!ModelState.IsValid)
            {
                return BadRequest(new ApiResponse
                {
                    Success = false,
                    Message = "Invalid data",
                    Data = ModelState
                });
            }

            var products = await _unitOfWork.Products.GetAsync(
                filter: p => p.ProductId == id,
                includeOperations: new Func<IQueryable<Product>, IQueryable<Product>>[]
                {
            q => q.Include(p => p.Brand),
            q => q.Include(p => p.Category)
                }
            );

            var product = products.FirstOrDefault();

            if (product == null)
            {
                return Ok(new ApiResponse
                {
                    Success = false,
                    StatusCode = StatusCodes.Status404NotFound,
                    Message = "Product not found!"
                });
            }

            return Ok(new ApiResponse
            {
                Success = true,
                StatusCode = StatusCodes.Status200OK,
                Data = _mapper.Map<ProductDTO>(product)
            });
        }

        [HttpGet]
        [Route("affiliate/{id:guid}")]
        public async Task<IActionResult> HandleAffiliateLink([FromRoute] Guid id, [FromQuery] string @ref = null)
        {
            // Don't track here - let Flutter app handle tracking to avoid duplicates
            // Backend just serves HTML page to redirect to app

            // Check if product exists
            var product = await _unitOfWork.Products.GetByIdAsync(id);
            if (product == null)
            {
                return NotFound("Product not found");
            }

            // Return HTML page that will open the app
            var html = $@"
<!DOCTYPE html>
<html>
<head>
    <meta charset='UTF-8'>
    <meta name='viewport' content='width=device-width, initial-scale=1.0'>
    <title>Opening Cosmotopia...</title>
    <style>
        body {{
            font-family: Arial, sans-serif;
            display: flex;
            justify-content: center;
            align-items: center;
            height: 100vh;
            margin: 0;
            background: linear-gradient(135deg, #667eea 0%, #764ba2 100%);
            color: white;
        }}
        .container {{
            text-align: center;
            padding: 20px;
        }}
        .spinner {{
            border: 3px solid #f3f3f3;
            border-top: 3px solid #ffffff;
            border-radius: 50%;
            width: 40px;
            height: 40px;
            animation: spin 1s linear infinite;
            margin: 20px auto;
        }}
        @keyframes spin {{
            0% {{ transform: rotate(0deg); }}
            100% {{ transform: rotate(360deg); }}
        }}
        .fallback {{
            margin-top: 20px;
            font-size: 14px;
            opacity: 0.8;
        }}
        .fallback a {{
            color: #ffffff;
            text-decoration: underline;
        }}
    </style>
</head>
<body>
    <div class='container'>
        <h1>Opening Cosmotopia App...</h1>
        <div class='spinner'></div>
        <p>Please wait while we redirect you to the app.</p>
        <div class='fallback'>
            <p>If the app doesn't open automatically:</p>
            <p><a href='#' onclick='openApp()'>Click here to open the app</a></p>
            <p><a href='https://play.google.com/store'>Download from Play Store</a></p>
        </div>
    </div>

    <script>
        function openApp() {{
            // Try to open the app with custom scheme matching Flutter route
            var deeplink = 'cosmotopia://api/Product/affiliate/{id}';
            if ('{@ref}' !== '') {{
                deeplink += '?ref={@ref}';
            }}
            
            console.log('Attempting to open app with deeplink:', deeplink);
            
            // Try to open the app
            window.location.href = deeplink;
            
            // Fallback: try intent for Android
            setTimeout(() => {{
                var intentLink = 'intent://api/Product/affiliate/{id}';
                if ('{@ref}' !== '') {{
                    intentLink += '?ref={@ref}';
                }}
                intentLink += '#Intent;scheme=cosmotopia;package=com.mycompany.stationeryecommerceapp;end';
                
                console.log('Fallback intent:', intentLink);
                window.location.href = intentLink;
            }}, 1500);
        }}

        // Automatically try to open the app when page loads
        window.onload = function() {{
            setTimeout(openApp, 1000);
        }};
    </script>
</body>
</html>";

            return Content(html, "text/html");
        }

        [HttpDelete]
        [Route("DeleteProduct/{id:guid}")]
        public async Task<IActionResult> DeleteById([FromRoute] Guid id)
        {
            if(!ModelState.IsValid)
            {
                return BadRequest(new ApiResponse
                {
                    Success = false,
                    Message = "Invalid data",
                    Data = ModelState
                });
            }

            var product = await _unitOfWork.Products.GetByIdAsync(id);

            if(product == null)
            {
                return Ok(new ApiResponse
                {
                    Success = false,
                    StatusCode = StatusCodes.Status404NotFound,
                    Message = "Product does not exist!",
                }); 
            }

             _unitOfWork.Products.Delete(product);
            await _unitOfWork.CompleteAsync();

            return Ok(new ApiResponse
            {
                Success = true,
                Message = "Product deleted successfully"
            });
        }

        [HttpPost]
        [Route("CreateProduct")]
        public async Task<IActionResult> Create(ProductCreateDTO productDTO)
        {
            if(!ModelState.IsValid)
            {
                return BadRequest(new ApiResponse
                {
                    Success = false,
                    Message = "Invalid data",
                    Data = ModelState
                });
            }

            if(!await _unitOfWork.Products.CategoryExist(productDTO.CategoryId.Value)) 
            {
                return BadRequest(new ApiResponse
                {
                    Success = false,
                    StatusCode= StatusCodes.Status404NotFound,
                    Message = "Category does not exist!",
                });
            }

            if(!await _unitOfWork.Products.BranchExist(productDTO.BrandId.Value))
            {
                return BadRequest(new ApiResponse
                {
                    Success = false,
                    StatusCode = StatusCodes.Status404NotFound,
                    Message = "Branch does not exist!",
                });
            }

            var imageUrls = new List<string>();




            var productModel = new Product
            {
                ProductId = Guid.NewGuid(),
                Name = productDTO.Name,
                Description = productDTO.Description,
                Price = productDTO.Price,
                StockQuantity = productDTO.StockQuantity,
                ImageUrls = productDTO.imageUrls.ToArray(),
                CommissionRate = productDTO.CommissionRate,
                CategoryId = productDTO.CategoryId,
                BrandId = productDTO.BrandId,
                CreateAt = DateTime.Now,
                IsActive = true,
            };

            await _unitOfWork.Products.AddAsync(productModel);
            await _unitOfWork.CompleteAsync();

            return Ok(new ApiResponse
            {
                Success = true,
                StatusCode = StatusCodes.Status200OK,
                Message = "Created Product Successfully.",
                Data = _mapper.Map<ProductDTO>(productModel)
            });
        }

        [HttpPut]
        [Route("UpdateProduct/{id:guid}")]
        public async Task<IActionResult> Update([FromRoute] Guid id, ProductUpdateDTO productDTO)
        {
            if(!ModelState.IsValid)
            {
                return BadRequest(new ApiResponse
                {
                    Success = false,
                    Message = "Invalid data",
                    Data = ModelState
                });
            }

            var existingProduct = await _unitOfWork.Products.GetByIdAsync(id);
            if(existingProduct == null)
            {
                return NotFound(new ApiResponse
                {
                    Success = false,
                    StatusCode = StatusCodes.Status404NotFound,
                    Message = "Product not found!",
                });
            }

        
       

            existingProduct.Name = productDTO.Name;
            existingProduct.Description = productDTO.Description;
            existingProduct.Price = productDTO.Price;
            existingProduct.StockQuantity = productDTO.StockQuantity;
            existingProduct.ImageUrls = productDTO.ImageUrls.ToArray();
            existingProduct.CommissionRate = productDTO.CommissionRate;
            existingProduct.IsActive = productDTO.IsActive;

             _unitOfWork.Products.UpdateAsync(existingProduct);
            await _unitOfWork.CompleteAsync();


            return Ok(new ApiResponse
            {
                Success = true,
                StatusCode = StatusCodes.Status200OK,
                Message = "Updated Product Successfully.",
                Data = _mapper.Map<ProductDTO>(existingProduct)
            });
        }

        [HttpGet("GetTopSellingProducts")]
        public async Task<IActionResult> GetTopSellingProducts([FromQuery]int top = 10)
        {
            var orderDetails = await _unitOfWork.OrderDetails.GetAllAsync();

            var topProductsGrouped = orderDetails
                .Where(o => o.ProductId != null)
                .GroupBy(o => o.ProductId.Value)
                .Select(g => new
                {
                    ProductId = g.Key,
                    TotalSold = g.Sum(o => o.Quantity),
                })
                .OrderByDescending(o => o.TotalSold)
                .Take(top)
                .ToList();

            var topProductIds = topProductsGrouped.Select(o => o.ProductId).ToList();

            var products = await _unitOfWork.Products.GetAsync(
                filter: p => topProductIds.Contains(p.ProductId),
                includeOperations: new Func<IQueryable<Product>, IQueryable<Product>>[]
                {
                    q => q.Include(p => p.Brand),
                    q => q.Include(p => p.Category)
                }
              );

            var sortedPRoducts = topProductsGrouped
                .Join(products, g => g.ProductId, p => p.ProductId, (g, p) => new {Product = p, ToTalSold = g.TotalSold})
                .OrderByDescending(x => x.ToTalSold)
                .Select(x => x.Product)
                .ToList();

            var result = _mapper.Map<List<ProductDTO>>(sortedPRoducts);

            return Ok(new ApiResponse
            {
                Success = true,
                Message = "Top selling products retrieved successfully",
                Data = result
            });
        }
    }
}
